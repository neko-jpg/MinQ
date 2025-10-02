# 画像リサイズ Cloud Function

## 概要
Firebase Storageにアップロードされた画像を自動的にリサイズして、複数のサイズを生成します。

## 実装

### functions/src/imageResize.ts

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as path from 'path';
import * as os from 'os';
import * as fs from 'fs';
import * as sharp from 'sharp';

const storage = admin.storage();

export const generateThumbnails = functions.storage
  .object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    const contentType = object.contentType;
    const bucket = storage.bucket(object.bucket);

    // 画像ファイルでない場合はスキップ
    if (!contentType || !contentType.startsWith('image/')) {
      console.log('Not an image file');
      return null;
    }

    // すでにリサイズ済みの画像はスキップ
    if (filePath && filePath.includes('_thumb_')) {
      console.log('Already a thumbnail');
      return null;
    }

    // ファイル名とディレクトリを取得
    const fileName = path.basename(filePath!);
    const fileDir = path.dirname(filePath!);
    const tempFilePath = path.join(os.tmpdir(), fileName);

    // ファイルをダウンロード
    await bucket.file(filePath!).download({ destination: tempFilePath });
    console.log('Image downloaded to', tempFilePath);

    // 複数のサイズを生成
    const sizes = [
      { name: 'thumb_small', width: 150, height: 150 },
      { name: 'thumb_medium', width: 300, height: 300 },
      { name: 'thumb_large', width: 600, height: 600 },
    ];

    const uploadPromises = sizes.map(async (size) => {
      const thumbFileName = `${size.name}_${fileName}`;
      const thumbFilePath = path.join(os.tmpdir(), thumbFileName);

      // リサイズ
      await sharp(tempFilePath)
        .resize(size.width, size.height, {
          fit: 'cover',
          position: 'center',
        })
        .jpeg({ quality: 80 })
        .toFile(thumbFilePath);

      console.log('Thumbnail created at', thumbFilePath);

      // アップロード
      const thumbPath = path.join(fileDir, thumbFileName);
      await bucket.upload(thumbFilePath, {
        destination: thumbPath,
        metadata: {
          contentType: 'image/jpeg',
          metadata: {
            originalName: fileName,
            size: size.name,
          },
        },
      });

      console.log('Thumbnail uploaded to', thumbPath);

      // 一時ファイルを削除
      fs.unlinkSync(thumbFilePath);

      return thumbPath;
    });

    await Promise.all(uploadPromises);

    // 元の一時ファイルを削除
    fs.unlinkSync(tempFilePath);

    console.log('All thumbnails generated successfully');
    return null;
  });

export const optimizeImage = functions.storage
  .object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    const contentType = object.contentType;
    const bucket = storage.bucket(object.bucket);

    // 画像ファイルでない場合はスキップ
    if (!contentType || !contentType.startsWith('image/')) {
      return null;
    }

    // すでに最適化済みの場合はスキップ
    if (filePath && filePath.includes('_optimized_')) {
      return null;
    }

    const fileName = path.basename(filePath!);
    const fileDir = path.dirname(filePath!);
    const tempFilePath = path.join(os.tmpdir(), fileName);
    const optimizedFileName = `optimized_${fileName}`;
    const optimizedFilePath = path.join(os.tmpdir(), optimizedFileName);

    // ファイルをダウンロード
    await bucket.file(filePath!).download({ destination: tempFilePath });

    // 画像を最適化
    await sharp(tempFilePath)
      .jpeg({ quality: 85, progressive: true })
      .png({ compressionLevel: 9 })
      .webp({ quality: 85 })
      .toFile(optimizedFilePath);

    // アップロード
    const uploadPath = path.join(fileDir, optimizedFileName);
    await bucket.upload(optimizedFilePath, {
      destination: uploadPath,
      metadata: {
        contentType: contentType,
        metadata: {
          originalName: fileName,
          optimized: 'true',
        },
      },
    });

    // 一時ファイルを削除
    fs.unlinkSync(tempFilePath);
    fs.unlinkSync(optimizedFilePath);

    console.log('Image optimized successfully');
    return null;
  });

export const generateWebP = functions.storage
  .object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    const contentType = object.contentType;
    const bucket = storage.bucket(object.bucket);

    // 画像ファイルでない場合はスキップ
    if (!contentType || !contentType.startsWith('image/')) {
      return null;
    }

    // すでにWebPの場合はスキップ
    if (contentType === 'image/webp') {
      return null;
    }

    const fileName = path.basename(filePath!);
    const fileDir = path.dirname(filePath!);
    const tempFilePath = path.join(os.tmpdir(), fileName);
    const webpFileName = `${path.parse(fileName).name}.webp`;
    const webpFilePath = path.join(os.tmpdir(), webpFileName);

    // ファイルをダウンロード
    await bucket.file(filePath!).download({ destination: tempFilePath });

    // WebPに変換
    await sharp(tempFilePath)
      .webp({ quality: 85 })
      .toFile(webpFilePath);

    // アップロード
    const uploadPath = path.join(fileDir, webpFileName);
    await bucket.upload(webpFilePath, {
      destination: uploadPath,
      metadata: {
        contentType: 'image/webp',
        metadata: {
          originalName: fileName,
        },
      },
    });

    // 一時ファイルを削除
    fs.unlinkSync(tempFilePath);
    fs.unlinkSync(webpFilePath);

    console.log('WebP image generated successfully');
    return null;
  });
```

### package.json

```json
{
  "name": "functions",
  "scripts": {
    "build": "tsc",
    "serve": "npm run build && firebase emulators:start --only functions",
    "shell": "npm run build && firebase functions:shell",
    "start": "npm run shell",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log"
  },
  "engines": {
    "node": "18"
  },
  "main": "lib/index.js",
  "dependencies": {
    "firebase-admin": "^11.8.0",
    "firebase-functions": "^4.3.1",
    "sharp": "^0.32.1"
  },
  "devDependencies": {
    "@types/node": "^18.16.0",
    "typescript": "^5.0.0"
  }
}
```

## Flutter側の実装

```dart
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 画像をアップロード（自動的にリサイズされる）
  Future<String> uploadImage(File imageFile, String userId) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('users/$userId/images/$fileName');

    // アップロード
    await ref.putFile(imageFile);

    // 元画像のURLを取得
    final url = await ref.getDownloadURL();

    // サムネイルが生成されるまで待機（オプション）
    await Future.delayed(const Duration(seconds: 2));

    return url;
  }

  /// サムネイルURLを取得
  String getThumbnailUrl(String originalUrl, ThumbnailSize size) {
    final uri = Uri.parse(originalUrl);
    final path = uri.path;
    final fileName = path.split('/').last;
    final dir = path.substring(0, path.lastIndexOf('/'));

    final sizePrefix = switch (size) {
      ThumbnailSize.small => 'thumb_small',
      ThumbnailSize.medium => 'thumb_medium',
      ThumbnailSize.large => 'thumb_large',
    };

    final thumbnailPath = '$dir/${sizePrefix}_$fileName';
    return uri.replace(path: thumbnailPath).toString();
  }

  /// WebP URLを取得
  String getWebPUrl(String originalUrl) {
    final uri = Uri.parse(originalUrl);
    final path = uri.path;
    final pathWithoutExt = path.substring(0, path.lastIndexOf('.'));
    final webpPath = '$pathWithoutExt.webp';
    return uri.replace(path: webpPath).toString();
  }
}

enum ThumbnailSize {
  small,
  medium,
  large,
}
```

## 使用例

```dart
// 画像をアップロード
final imageUrl = await _imageUploadService.uploadImage(imageFile, userId);

// サムネイルを表示
CachedNetworkImage(
  imageUrl: _imageUploadService.getThumbnailUrl(
    imageUrl,
    ThumbnailSize.medium,
  ),
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// WebPをサポートしている場合
final webpUrl = _imageUploadService.getWebPUrl(imageUrl);
```

## デプロイ

```bash
cd functions
npm install
npm run deploy
```

## 注意事項
- Cloud Functionsの実行時間とメモリに注意
- 大きな画像は処理に時間がかかる
- ストレージ容量に注意
- 課金に注意
