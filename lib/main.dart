import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/config/flavor.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/crash_recovery_store.dart';
import 'package:minq/data/services/operations_metrics_service.dart';
import 'package:minq/firebase_options_dev.dart' as dev;
import 'package:minq/firebase_options_prod.dart' as prod;
import 'package:minq/firebase_options_stg.dart' as stg;
import 'package:minq/presentation/controllers/crash_recovery_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/screens/crash_recovery_screen.dart';
import 'package:minq/presentation/theme/app_theme.dart';
import 'package:minq/presentation/widgets/version_check_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;

  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  final crashRecoveryStore = CrashRecoveryStore(sharedPrefs);
  final operationsMetricsService = OperationsMetricsService(sharedPrefs);
  await operationsMetricsService.recordSessionStart(DateTime.now());

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    unawaited(operationsMetricsService.recordCrash(DateTime.now()));
    unawaited(
      crashRecoveryStore.recordCrash(
        CrashReport(
          message: details.exceptionAsString(),
          stackTrace: details.stack?.toString() ?? '',
          recordedAt: DateTime.now(),
        ),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    unawaited(operationsMetricsService.recordCrash(DateTime.now()));
    unawaited(
      crashRecoveryStore.recordCrash(
        CrashReport(
          message: error.toString(),
          stackTrace: stack.toString(),
          recordedAt: DateTime.now(),
        ),
      ),
    );
    return false;
  };

  assert(() {
    binding.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final totalMillis = timing.totalSpan.inMilliseconds;
        if (totalMillis > 16) {
          MinqLogger.debug(
            'Frame exceeded vsync budget',
            metadata: <String, Object?>{
              'frameTimeMs': totalMillis,
              'buildTimeMs': timing.buildDuration.inMilliseconds,
              'rasterTimeMs': timing.rasterDuration.inMilliseconds,
            },
          );
        }
      }
    });
    return true;
  }());

  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final flavor = Flavor.values.firstWhere(
    (e) => e.toString().split('.').last == flavorString,
  );

  final firebaseInitialized = await _initializeFirebaseIfAvailable(flavor);

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailabilityProvider.overrideWithValue(firebaseInitialized),
        crashRecoveryStoreProvider.overrideWithValue(crashRecoveryStore),
        operationsMetricsServiceProvider.overrideWithValue(operationsMetricsService),
      ],
      child: const MinQApp(),
    ),
  );
}

Future<bool> _initializeFirebaseIfAvailable(Flavor flavor) async {
  try {
    FirebaseOptions options;
    switch (flavor) {
      case Flavor.dev:
        options = dev.DefaultFirebaseOptions.currentPlatform;
        break;
      case Flavor.stg:
        options = stg.DefaultFirebaseOptions.currentPlatform;
        break;
      case Flavor.prod:
        options = prod.DefaultFirebaseOptions.currentPlatform;
        break;
    }
    await Firebase.initializeApp(options: options);
    return true;
  } on UnsupportedError catch (error) {
    debugPrint('Skipping Firebase initialization: $error');
  } catch (error) {
    debugPrint('Failed to initialize Firebase: $error');
  }
  return false;
}

class MinQApp extends ConsumerStatefulWidget {
  const MinQApp({super.key});

  @override
  ConsumerState<MinQApp> createState() => _MinQAppState();
}

class _MinQAppState extends ConsumerState<MinQApp> {
  late final ProviderSubscription<AsyncValue<String>>
      _notificationTapSubscription;
  ProviderSubscription<AsyncValue<Uri>>? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    // React to notification taps emitted by the native layer.
    _notificationTapSubscription = ref.listenManual<AsyncValue<String>>(
      notificationTapStreamProvider,
      (previous, next) => _handleNotificationNavigation(next),
    );
    _handleNotificationNavigation(_notificationTapSubscription.read());

    _deepLinkSubscription = ref.listenManual<AsyncValue<Uri>>(
      deepLinkStreamProvider,
      (previous, next) => _handleDeepLinkNavigation(next),
    );
    _handleDeepLinkNavigation(_deepLinkSubscription?.read());
  }

  @override
  void dispose() {
    _notificationTapSubscription.close();
    _deepLinkSubscription?.close();
    super.dispose();
  }

  void _handleNotificationNavigation(AsyncValue<String> notification) {
    notification.whenData((route) {
      if (route.isNotEmpty) {
        ref.read(routerProvider).go(route);
      }
    });
  }

  void _handleDeepLinkNavigation(AsyncValue<Uri>? deepLink) {
    deepLink?.whenData((uri) {
      final route = _mapDeepLinkToRoute(uri);
      if (route != null) {
        ref.read(routerProvider).go(route);
      }
    });
  }

  String? _mapDeepLinkToRoute(Uri uri) {
    if (uri.scheme != 'app') {
      return null;
    }

    if (uri.host == 'quest' && uri.pathSegments.isNotEmpty) {
      final questId = int.tryParse(uri.pathSegments.first);
      if (questId != null) {
        return AppRoutes.questDetail
            .replaceFirst(':questId', questId.toString());
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appStartupAsyncValue = ref.watch(appStartupProvider);
    final initializationError = ref.watch(initializationErrorProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(appLocaleControllerProvider);
    final crashRecoveryState = ref.watch(crashRecoveryControllerProvider);

    if (crashRecoveryState.needsRecovery) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const CrashRecoveryScreen(),
      );
    }

    if (initializationError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Startup Error: $initializationError'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(appStartupProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return switch (appStartupAsyncValue) {
      AsyncLoading() => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      AsyncError(:final error) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('Startup Error: $error'))),
      ),
      AsyncData() => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: 'MinQ',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        locale: locale ?? const Locale('ja'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ja')],
        builder: (BuildContext context, Widget? child) {
          final mediaQuery = MediaQuery.of(context);
          final clampedScaler = mediaQuery.textScaler.clamp(
            minScaleFactor: 1.0,
            maxScaleFactor: 2.0,
          );
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: clampedScaler),
            child: VersionCheckWidget(
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
      ),
      _ => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: Text('Initializing...'))),
      ),
    };
  }
}
