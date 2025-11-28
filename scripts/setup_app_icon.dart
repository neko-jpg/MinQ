import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// アプリアイコン自動生成スクリプト
/// 
/// 使用方法:
/// dart run scripts/setup_app_icon.dart
/// 
/// このスクリプトは以下を実行します:
/// 1. assets/images/app_icon.png から各プラットフォーム用のアイコンを生成
/// 2. Android用の各サイズのアイコンを生成
/// 3. iOS用の各サイズのアイコンを生成
/// 4. Web用のファビコンを生成
void main() async {
  print('🚀 アプリアイコン自動生成を開始します...');
  
  try {
    // ソースアイコンを読み込み
    final sourceFile = File('assets/images/app_icon.png');
    if (!await sourceFile.exists()) {
      print('❌ エラー: assets/images/app_icon.png が見つかりません');
      exit(1);
    }
    
    final sourceBytes = await sourceFile.readAsBytes();
    final sourceImage = img.decodeImage(sourceBytes);
    
    if (sourceImage == null) {
      print('❌ エラー: アイコン画像を読み込めませんでした');
      exit(1);
    }
    
    print('✅ ソースアイコンを読み込みました (${sourceImage.width}x${sourceImage.height})');
    
    // Android用アイコンを生成
    await generateAndroidIcons(sourceImage);
    
    // iOS用アイコンを生成
    await generateIOSIcons(sourceImage);
    
    // Web用ファビコンを生成
    await generateWebIcons(sourceImage);
    
    print('🎉 アプリアイコンの生成が完了しました！');
    print('');
    print('📱 次のステップ:');
    print('1. Android Studio で android/app/src/main/res を確認');
    print('2. Xcode で ios/Runner/Assets.xcassets を確認');
    print('3. アプリをビルドしてアイコンが正しく表示されることを確認');
    
  } catch (e) {
    print('❌ エラーが発生しました: $e');
    exit(1);
  }
}

/// Android用アイコンを生成
Future<void> generateAndroidIcons(img.Image sourceImage) async {
  print('📱 Android用アイコンを生成中...');
  
  final androidSizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };
  
  for (final entry in androidSizes.entries) {
    final folder = entry.key;
    final size = entry.value;
    
    // フォルダを作成
    final dir = Directory('android/app/src/main/res/$folder');
    await dir.create(recursive: true);
    
    // アイコンをリサイズ
    final resized = img.copyResize(sourceImage, width: size, height: size);
    
    // PNG形式で保存
    final pngBytes = img.encodePng(resized);
    final file = File('${dir.path}/ic_launcher.png');
    await file.writeAsBytes(pngBytes);
    
    print('  ✅ $folder/ic_launcher.png (${size}x${size})');
  }
  
  // 適応型アイコン用の前景画像も生成
  for (final entry in androidSizes.entries) {
    final folder = entry.key;
    final size = entry.value;
    
    final dir = Directory('android/app/src/main/res/$folder');
    
    // 前景用（少し小さめ）
    final foregroundSize = (size * 0.7).round();
    final foreground = img.copyResize(sourceImage, width: foregroundSize, height: foregroundSize);
    
    // 中央に配置するためのキャンバス
    final canvas = img.Image(width: size, height: size);
    img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0)); // 透明背景
    
    final offsetX = (size - foregroundSize) ~/ 2;
    final offsetY = (size - foregroundSize) ~/ 2;
    
    img.compositeImage(canvas, foreground, dstX: offsetX, dstY: offsetY);
    
    final pngBytes = img.encodePng(canvas);
    final file = File('${dir.path}/ic_launcher_foreground.png');
    await file.writeAsBytes(pngBytes);
    
    print('  ✅ $folder/ic_launcher_foreground.png (${size}x${size})');
  }
}

/// iOS用アイコンを生成
Future<void> generateIOSIcons(img.Image sourceImage) async {
  print('🍎 iOS用アイコンを生成中...');
  
  final iosSizes = [
    20, 29, 40, 58, 60, 76, 80, 87, 114, 120, 152, 167, 180, 1024
  ];
  
  // Assets.xcassets/AppIcon.appiconset フォルダを作成
  final dir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
  await dir.create(recursive: true);
  
  // Contents.json を生成
  await generateIOSContentsJson(dir);
  
  for (final size in iosSizes) {
    final resized = img.copyResize(sourceImage, width: size, height: size);
    final pngBytes = img.encodePng(resized);
    
    String filename;
    if (size == 1024) {
      filename = 'Icon-App-1024x1024@1x.png';
    } else {
      filename = 'Icon-App-${size}x$size@1x.png';
    }
    
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(pngBytes);
    
    print('  ✅ $filename (${size}x${size})');
  }
}

/// iOS Contents.json を生成
Future<void> generateIOSContentsJson(Directory dir) async {
  const contentsJson = '''
{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
''';
  
  final file = File('${dir.path}/Contents.json');
  await file.writeAsString(contentsJson);
}

/// Web用ファビコンを生成
Future<void> generateWebIcons(img.Image sourceImage) async {
  print('🌐 Web用ファビコンを生成中...');
  
  final webSizes = [16, 32, 192, 512];
  
  for (final size in webSizes) {
    final resized = img.copyResize(sourceImage, width: size, height: size);
    final pngBytes = img.encodePng(resized);
    
    String filename;
    if (size == 16 || size == 32) {
      filename = 'favicon-${size}x$size.png';
    } else {
      filename = 'Icon-$size.png';
    }
    
    final file = File('web/icons/$filename');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(pngBytes);
    
    print('  ✅ $filename (${size}x${size})');
  }
  
  // favicon.ico も生成（16x16）
  final favicon16 = img.copyResize(sourceImage, width: 16, height: 16);
  final icoBytes = img.encodePng(favicon16); // 簡易版（本来はICO形式）
  final faviconFile = File('web/favicon.png');
  await faviconFile.writeAsBytes(icoBytes);
  
  print('  ✅ favicon.png (16x16)');
}