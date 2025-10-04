import 'package:flutter/material.dart';

/// 繧ｹ繝励Λ繝・す繝･逕ｻ髱｢・医Λ繧､繝・繝繝ｼ繧ｯ蟇ｾ蠢懶ｼ・
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 繝ｭ繧ｴ
            Image.asset(
              isDark
                  ? 'assets/images/logo_dark.png'
                  : 'assets/images/logo_light.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                // 繝輔か繝ｼ繝ｫ繝舌ャ繧ｯ: 繝・く繧ｹ繝医Ο繧ｴ
                return Text(
                  'MinQ',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: tokens.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // 繝ｭ繝ｼ繝・ぅ繝ｳ繧ｰ繧､繝ｳ繧ｸ繧ｱ繝ｼ繧ｿ繝ｼ
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(tokens.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 繧ｹ繝励Λ繝・す繝･逕ｻ髱｢險ｭ螳壹ぎ繧､繝・
/// 
/// Android:
/// - android/app/src/main/res/drawable/launch_background.xml
/// - android/app/src/main/res/drawable-night/launch_background.xml
/// 
/// iOS:
/// - ios/Runner/Assets.xcassets/LaunchImage.imageset/
/// - LaunchScreen.storyboard
class SplashScreenConfig {
  const SplashScreenConfig._();

  /// Android launch_background.xml (Light)
  static const String androidLightXml = '''
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_background_light"/>
    <item>
        <bitmap
            android:gravity="center"
            android:src="@drawable/splash_logo"/>
    </item>
</layer-list>
''';

  /// Android launch_background.xml (Dark)
  static const String androidDarkXml = '''
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@color/splash_background_dark"/>
    <item>
        <bitmap
            android:gravity="center"
            android:src="@drawable/splash_logo_dark"/>
    </item>
</layer-list>
''';

  /// Android colors.xml
  static const String androidColorsXml = '''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="splash_background_light">#FFFFFF</color>
    <color name="splash_background_dark">#1A1A1A</color>
</resources>
''';
}
