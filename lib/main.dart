import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/config/flavor.dart';
import 'package:minq/core/i18n/timezone_service.dart';
import 'package:minq/core/initialization/optimal_initialization_service.dart';
import 'package:minq/core/navigation/root_back_button_dispatcher.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/crash_recovery_store.dart';
import 'package:minq/data/services/operations_metrics_service.dart';
import 'package:minq/firebase_options_dev.dart' as dev;
import 'package:minq/firebase_options_prod.dart' as prod;
import 'package:minq/firebase_options_stg.dart' as stg;
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/controllers/progressive_onboarding_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/screens/onboarding/level_up_screen.dart';
import 'package:minq/presentation/screens/organic_splash_screen.dart';
import 'package:minq/presentation/theme/theme.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';
import 'package:minq/presentation/widgets/version_check_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  if (sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
      },
      appRunner: () async {
        await _bootstrapApplication();
      },
    );
    return;
  }

  await _bootstrapApplication();
}

Future<void> _bootstrapApplication() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // TensorFlow Lite AI驛｢・ｧ繝ｻ・ｵ驛｢譎｢・ｽ・ｼ驛｢譎∽ｾｭ邵ｺ蟶ｷ・ｸ・ｺ繝ｻ・ｯ髯滂ｽ｢郢晢ｽｻ繝ｻ・ｦ遶丞｣ｺ繝ｻ髯滂ｽ｢隲帷腸・ｧ驍ｵ・ｺ繝ｻ・ｦ髯具ｽｻ隴弱・・・刹・ｹ隰費ｽｶ繝ｻ繝ｻ・ｹ・ｧ陟暮ｯ会ｽｽ繝ｻ
  GestureBinding.instance.resamplingEnabled = true;

  final SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  final crashRecoveryStore = CrashRecoveryStore(sharedPrefs);
  final operationsMetricsService = OperationsMetricsService(sharedPrefs);
  await operationsMetricsService.recordSessionStart(DateTime.now());

  // Initialize timezone service for regional support
  await TimezoneService.initialize();

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
        operationsMetricsServiceProvider.overrideWithValue(
          operationsMetricsService,
        ),
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
  @override
  void initState() {
    super.initState();
    // 驛｢譎｢・ｽ・ｬ驛｢譎冗函・取刮・ｹ・ｧ繝ｻ・｢驛｢譏ｴ繝ｻ郢晢ｽｻ驛｢・ｧ繝ｻ・､驛｢譎冗函・趣ｽｦ驛｢譎冗樟・取㏍・ｹ・ｧ繝ｻ・ｹ驛｢譎会ｽｿ・ｫ郢晢ｽｻ
    Future.microtask(() {
      _handleLevelUpEvent(ref.read(levelUpEventProvider));
      _handleNotificationNavigation(ref.read(notificationTapStreamProvider));
      _handleDeepLinkNavigation(ref.read(deepLinkStreamProvider));
    });
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
        return AppRoutes.questDetail.replaceFirst(
          ':questId',
          questId.toString(),
        );
      }
    }

    return null;
  }

  void _handleLevelUpEvent(LevelUpEvent? event) {
    if (event != null && mounted) {
      _showLevelUpScreen(event);
    }
  }

  void _showLevelUpScreen(LevelUpEvent event) {
    // 驛｢譎｢・ｽ・ｬ驛｢譎冗函・取刮・ｹ・ｧ繝ｻ・｢驛｢譏ｴ繝ｻ郢晢ｽｻ鬨ｾ蛹・ｽｽ・ｻ鬯ｮ・ｱ繝ｻ・｢驛｢・ｧ陞ｳ螟ｲ・ｽ・｡繝ｻ・ｨ鬩穂ｼ夲ｽｽ・ｺ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context =
          ref.read(routerProvider).routerDelegate.navigatorKey.currentContext;
      if (context != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => LevelUpScreen(
                newLevel: event.newLevel,
                levelInfo: event.levelInfo,
                onContinue: () {
                  // 驛｢譎｢・ｽ・ｬ驛｢譎冗函・取刮・ｹ・ｧ繝ｻ・｢驛｢譏ｴ繝ｻ郢晢ｽｻ驛｢・ｧ繝ｻ・､驛｢譎冗函・趣ｽｦ驛｢譎冗樟繝ｻ蝣､・ｹ・ｧ繝ｻ・ｯ驛｢譎｢・ｽ・ｪ驛｢・ｧ繝ｻ・｢
                  ref.read(levelUpEventProvider.notifier).state = null;
                },
              ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen驛｢・ｧ鬪ｰ蟄嬖ld驛｢譎｢・ｽ・｡驛｢・ｧ繝ｻ・ｽ驛｢譏ｴ繝ｻ郢晢ｽｩ髯ｷﾂ郢晢ｽｻ邵ｲ螳壽割繝ｻ・ｿ鬨ｾ蛹・ｽｽ・ｨ
    ref.listen<LevelUpEvent?>(
      levelUpEventProvider,
      (previous, next) => _handleLevelUpEvent(next),
    );

    ref.listen<AsyncValue<String>>(
      notificationTapStreamProvider,
      (previous, next) => _handleNotificationNavigation(next),
    );

    ref.listen<AsyncValue<Uri>>(
      deepLinkStreamProvider,
      (previous, next) => _handleDeepLinkNavigation(next),
    );

    final appStartupAsyncValue = ref.watch(optimizedAppStartupProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(appLocaleControllerProvider);

    // 驛｢・ｧ繝ｻ・ｯ驛｢譎｢・ｽ・ｩ驛｢譏ｴ繝ｻ邵ｺ蜥擾ｽｹ譎｢・ｽ・･驛｢譎｢・ｽ・ｪ驛｢・ｧ繝ｻ・ｫ驛｢譎√・・取㏍・ｹ謨鳴驛｢・ｧ繝ｻ・､驛｢・ｧ繝ｻ・｢驛｢譎｢・ｽ・ｭ驛｢・ｧ繝ｻ・ｰ驛｢・ｧ髮区ｨ抵ｽ朱ｬｮ・ｯ繝ｻ・､驍ｵ・ｺ陷会ｽｱ・つ遶丞｣ｹ・驛｢・ｧ繝ｻ・､驛｢譎｢・ｽ・ｬ驛｢譎｢・ｽ・ｳ驛｢譎冗樟・取㏍・ｹ・ｧ繝ｻ・ｫ驛｢譎√・・取㏍・ｹ・ｧ髮区ｩｸ・ｽ・ｮ雋・ｽｯ繝ｻ・｣郢晢ｽｻ
    // 驛｢・ｧ繝ｻ・ｨ驛｢譎｢・ｽ・ｩ驛｢譎｢・ｽ・ｼ驍ｵ・ｺ隶吩ｸｻ鬨馴ｨｾ蠅難ｽｺ蛛・ｽｼ・ｰ驍ｵ・ｺ雋・ｽｷ繝ｻ・ｰ繝ｻ・ｴ髯ｷ・ｷ陋ｹ・ｻ邵ｲ蝣､・ｹ・ｧ郢ｧ蝓淞蜑ｰ・ｮ蛹・ｽｺ・ｽ陜趣ｽｪ驛｢・ｧ繝ｻ・ｹ驛｢譎丞ｹｲ・主ｸｷ・ｹ譏ｴ繝ｻ邵ｺ蜥擾ｽｹ譎｢・ｽ・･鬨ｾ蛹・ｽｽ・ｻ鬯ｮ・ｱ繝ｻ・｢驛｢・ｧ陞ｳ螟ｲ・ｽ・｡繝ｻ・ｨ鬩穂ｼ夲ｽｽ・ｺ

        return switch (appStartupAsyncValue) {
      AsyncLoading() => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.system,
        builder: (context, child) {
          MinqTokens.updateFromTheme(Theme.of(context));
          return child ?? const SizedBox.shrink();
        },
        home: const OrganicSplashScreen(),
      ),
      AsyncError(:final error) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.system,
        builder: (context, child) {
          MinqTokens.updateFromTheme(Theme.of(context));
          return child ?? const SizedBox.shrink();
        },
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Failed to initialise the app'),
                const SizedBox(height: 8),
                Text('$error', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(optimizedAppStartupProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      AsyncData() => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        title: 'MinQ',
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.system,
        locale: locale,
        backButtonDispatcher: MinqBackButtonDispatcher.instance,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == deviceLocale?.languageCode) {
              return supportedLocale;
            }
          }
          return const Locale('ja');
        },
        builder: (context, child) {
          MinqTokens.updateFromTheme(Theme.of(context));
          MinqBackButtonDispatcher.instance.setContext(context);
          final mediaQuery = MediaQuery.of(context);
          const double minScaleFactor = 1.0;
          const double maxScaleFactor = 2.0;

          TextScaler effectiveTextScaler = mediaQuery.textScaler;
          if (maxScaleFactor > minScaleFactor) {
            final double approxScale = effectiveTextScaler.scale(1);
            if (!approxScale.isFinite || approxScale <= 0) {
              effectiveTextScaler = const TextScaler.linear(minScaleFactor);
            } else if (approxScale > maxScaleFactor) {
              effectiveTextScaler = const TextScaler.linear(maxScaleFactor);
            } else if (approxScale < minScaleFactor) {
              effectiveTextScaler = const TextScaler.linear(minScaleFactor);
            }
          }

          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: effectiveTextScaler),
            child: VersionCheckWidget(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
      _ => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.system,
        builder: (context, child) {
          MinqTokens.updateFromTheme(Theme.of(context));
          return child ?? const SizedBox.shrink();
        },
        home: const OrganicSplashScreen(),
      ),
    };
  }
}
