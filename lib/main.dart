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
  // TensorFlow Lite AIサービスは必要に応じて初期化される
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
    // レベルアップイベントリスナー
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
    // レベルアップ画面を表示
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
                  // レベルアップイベントをクリア
                  ref.read(levelUpEventProvider.notifier).state = null;
                },
              ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ref.listenをbuildメソッド内で使用
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

    // クラッシュリカバリダイアログを削除し、サイレントリカバリを実装
    // エラーが発生した場合でも有機的スプラッシュ画面を表示

    return switch (appStartupAsyncValue) {
      AsyncLoading() => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: const OrganicSplashScreen(),
      ),
      AsyncError(:final error) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('初期化エラーが発生しました'),
                const SizedBox(height: 8),
                Text('$error', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(optimizedAppStartupProvider);
                  },
                  child: const Text('再試行'),
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
        // RootBackButtonDispatcherを統合
        backButtonDispatcher: MinqBackButtonDispatcher.instance,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // RTL support for Arabic and other RTL languages
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          // Check if device locale is supported
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == deviceLocale?.languageCode) {
              return supportedLocale;
            }
          }
          // Default to Japanese if no match found
          return const Locale('ja');
        },
        builder: (BuildContext context, Widget? child) {
          // RootBackButtonDispatcherにコンテキストを設定
          MinqBackButtonDispatcher.instance.setContext(context);
          final mediaQuery = MediaQuery.of(context);
          const double minScaleFactor = 1.0;
          const double maxScaleFactor = 2.0;

          TextScaler effectiveTextScaler = mediaQuery.textScaler;
          if (maxScaleFactor > minScaleFactor) {
            final double approxScale = mediaQuery.textScaler.scale(1);
            if (!approxScale.isFinite || approxScale <= 0) {
              assert(() {
                debugPrint(
                  'Falling back to minimum text scale because approxScale was $approxScale',
                );
                return true;
              }());
              effectiveTextScaler = const TextScaler.linear(minScaleFactor);
            } else if (approxScale > maxScaleFactor) {
              assert(() {
                debugPrint(
                  'Clamping text scale down to $maxScaleFactor (was $approxScale)',
                );
                return true;
              }());
              effectiveTextScaler = const TextScaler.linear(maxScaleFactor);
            } else if (approxScale < minScaleFactor) {
              assert(() {
                debugPrint(
                  'Clamping text scale up to $minScaleFactor (was $approxScale)',
                );
                return true;
              }());
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
        home: const OrganicSplashScreen(),
      ),
    };
  }
}
