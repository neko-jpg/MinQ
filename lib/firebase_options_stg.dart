import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform =>
      throw UnsupportedError(
        'Firebase is not configured for stg. Run `flutterfire configure` to generate '
        'firebase_options_stg.dart.',
      );
}
