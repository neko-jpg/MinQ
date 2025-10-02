import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/app_theme.dart';
import 'package:minq/config/flavor.dart';
import 'package:minq/firebase_options_dev.dart' as dev;
import 'package:minq/firebase_options_stg.dart' as stg;
import 'package:minq/firebase_options_prod.dart' as prod;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final flavor = Flavor.values.firstWhere(
    (e) => e.toString().split('.').last == flavorString,
  );

  final firebaseInitialized = await _initializeFirebaseIfAvailable(flavor);

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailabilityProvider.overrideWithValue(firebaseInitialized),
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

  @override
  void initState() {
    super.initState();
    // React to notification taps emitted by the native layer.
    _notificationTapSubscription = ref.listenManual<AsyncValue<String>>(
      notificationTapStreamProvider,
      (previous, next) => _handleNotificationNavigation(next),
    );
    _handleNotificationNavigation(_notificationTapSubscription.read());
  }

  @override
  void dispose() {
    _notificationTapSubscription.close();
    super.dispose();
  }

  void _handleNotificationNavigation(AsyncValue<String> notification) {
    notification.whenData((route) {
      if (route.isNotEmpty) {
        ref.read(routerProvider).go(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appStartupAsyncValue = ref.watch(appStartupProvider);
    final initializationError = ref.watch(initializationErrorProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(appLocaleControllerProvider);

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
            maxScaleFactor: 1.3,
          );
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: clampedScaler),
            child: child ?? const SizedBox.shrink(),
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
