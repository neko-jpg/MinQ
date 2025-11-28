import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minq/presentation/theme/color_tokens.dart';
import 'package:path_provider/path_provider.dart';

/// 画像アップロードサービス
class ImageUploadService {
  final ImagePicker _picker = ImagePicker();

  /// ギャラリーから画像を選択
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('❌ Failed to pick image from gallery: $e');
      return null;
    }
  }

  /// カメラで撮影
  Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('❌ Failed to pick image from camera: $e');
      return null;
    }
  }

  /// 画像をクロップ
  Future<File?> cropImage({
    required File imageFile,
    CropAspectRatio? aspectRatio,
    CropStyle cropStyle = CropStyle.rectangle,
    List<CropAspectRatioPreset>? aspectRatioPresets,
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: aspectRatio,
        cropStyle: cropStyle,
        aspectRatioPresets:
            aspectRatioPresets ??
            [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '画像をクロップ',
            toolbarColor: ColorTokens.light.warning,
            toolbarWidgetColor: ColorTokens.light.onPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: '画像をクロップ', minimumAspectRatio: 1.0),
        ],
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      debugPrint('❌ Failed to crop image: $e');
      return null;
    }
  }

  /// 画像を圧縮
  Future<File?> compressImage({
    required File imageFile,
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final targetPath =
          '${directory.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth ?? 1920,
        minHeight: maxHeight ?? 1920,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint('❌ Failed to compress image: $e');
      return null;
    }
  }

  /// 画像のサイズを取得
  Future<ImageSize?> getImageSize(File imageFile) async {
    try {
      final image = await decodeImageFromList(await imageFile.readAsBytes());
      return ImageSize(width: image.width, height: image.height);
    } catch (e) {
      debugPrint('❌ Failed to get image size: $e');
      return null;
    }
  }

  /// 画像をリサイズ
  Future<File?> resizeImage({
    required File imageFile,
    required int width,
    required int height,
  }) async {
    try {
      final directory = await getTemporaryDirectory();
      final targetPath =
          '${directory.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        minWidth: width,
        minHeight: height,
        quality: 90,
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint('❌ Failed to resize image: $e');
      return null;
    }
  }
}

/// アバターアップロードサービス
class AvatarUploadService {
  final ImageUploadService _imageUploadService;

  AvatarUploadService(this._imageUploadService);

  /// アバターを選択してアップロード
  Future<File?> selectAndPrepareAvatar({
    ImageSource source = ImageSource.gallery,
  }) async {
    // 1. 画像を選択
    File? imageFile;
    if (source == ImageSource.gallery) {
      imageFile = await _imageUploadService.pickFromGallery();
    } else {
      imageFile = await _imageUploadService.pickFromCamera();
    }

    if (imageFile == null) return null;

    // 2. 正方形にクロップ
    final croppedFile = await _imageUploadService.cropImage(
      imageFile: imageFile,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    );

    if (croppedFile == null) return null;

    // 3. リサイズ（512x512）
    final resizedFile = await _imageUploadService.resizeImage(
      imageFile: croppedFile,
      width: 512,
      height: 512,
    );

    if (resizedFile == null) return null;

    // 4. 圧縮
    final compressedFile = await _imageUploadService.compressImage(
      imageFile: resizedFile,
      quality: 85,
    );

    return compressedFile;
  }

  /// サムネイルを生成
  Future<File?> generateThumbnail({
    required File imageFile,
    int size = 128,
  }) async {
    return await _imageUploadService.resizeImage(
      imageFile: imageFile,
      width: size,
      height: size,
    );
  }
}

/// 画像サイズ
class ImageSize {
  final int width;
  final int height;

  const ImageSize({required this.width, required this.height});

  /// アスペクト比
  double get aspectRatio => width / height;

  /// 面積
  int get area => width * height;

  @override
  String toString() => '${width}x$height';
}

/// 画像選択ダイアログ
class ImagePickerDialog {
  /// 画像選択ソースを選択
  static Future<ImageSource?> show(BuildContext context) async {
    return await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('画像を選択'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('ギャラリーから選択'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('カメラで撮影'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          ),
    );
  }
}

/// 画像アップロード設定
class ImageUploadConfig {
  final int maxWidth;
  final int maxHeight;
  final int quality;
  final int maxFileSizeBytes;
  final List<String> allowedExtensions;

  const ImageUploadConfig({
    this.maxWidth = 1920,
    this.maxHeight = 1920,
    this.quality = 85,
    this.maxFileSizeBytes = 5 * 1024 * 1024, // 5MB
    this.allowedExtensions = const ['jpg', 'jpeg', 'png'],
  });

  /// アバター用設定
  static const avatar = ImageUploadConfig(
    maxWidth: 512,
    maxHeight: 512,
    quality: 85,
    maxFileSizeBytes: 2 * 1024 * 1024, // 2MB
  );

  /// カバー画像用設定
  static const cover = ImageUploadConfig(
    maxWidth: 1920,
    maxHeight: 1080,
    quality: 90,
    maxFileSizeBytes: 5 * 1024 * 1024, // 5MB
  );

  /// サムネイル用設定
  static const thumbnail = ImageUploadConfig(
    maxWidth: 256,
    maxHeight: 256,
    quality: 80,
    maxFileSizeBytes: 500 * 1024, // 500KB
  );
}

/// 画像バリデーター
class ImageValidator {
  /// ファイルサイズを検証
  static bool validateFileSize(File file, int maxSizeBytes) {
    final fileSize = file.lengthSync();
    return fileSize <= maxSizeBytes;
  }

  /// 拡張子を検証
  static bool validateExtension(File file, List<String> allowedExtensions) {
    final extension = file.path.split('.').last.toLowerCase();
    return allowedExtensions.contains(extension);
  }

  /// 画像サイズを検証
  static Future<bool> validateImageSize({
    required File file,
    required int maxWidth,
    required int maxHeight,
  }) async {
    try {
      final image = await decodeImageFromList(await file.readAsBytes());
      return image.width <= maxWidth && image.height <= maxHeight;
    } catch (e) {
      return false;
    }
  }

  /// 全ての検証を実行
  static Future<ImageValidationResult> validate({
    required File file,
    required ImageUploadConfig config,
  }) async {
    // ファイルサイズチェック
    if (!validateFileSize(file, config.maxFileSizeBytes)) {
      return ImageValidationResult(
        isValid: false,
        error:
            'ファイルサイズが大きすぎます（最大: ${config.maxFileSizeBytes ~/ (1024 * 1024)}MB）',
      );
    }

    // 拡張子チェック
    if (!validateExtension(file, config.allowedExtensions)) {
      return ImageValidationResult(
        isValid: false,
        error: '対応していないファイル形式です（対応形式: ${config.allowedExtensions.join(", ")}）',
      );
    }

    // 画像サイズチェック
    if (!await validateImageSize(
      file: file,
      maxWidth: config.maxWidth,
      maxHeight: config.maxHeight,
    )) {
      return ImageValidationResult(
        isValid: false,
        error: '画像サイズが大きすぎます（最大: ${config.maxWidth}x${config.maxHeight}）',
      );
    }

    return const ImageValidationResult(isValid: true);
  }
}

/// 画像検証結果
class ImageValidationResult {
  final bool isValid;
  final String? error;

  const ImageValidationResult({required this.isValid, this.error});
}

/// 画像アップロード進捗
class ImageUploadProgress {
  final double progress;
  final ImageUploadStage stage;

  const ImageUploadProgress({required this.progress, required this.stage});

  /// 完了したかどうか
  bool get isComplete => progress >= 1.0;
}

/// 画像アップロードステージ
enum ImageUploadStage {
  /// 選択中
  selecting,

  /// クロップ中
  cropping,

  /// 圧縮中
  compressing,

  /// アップロード中
  uploading,

  /// 完了
  complete,
}

/// 画像キャッシュマネージャー
class ImageCacheManager {
  static final Map<String, File> _cache = {};

  /// キャッシュに追加
  static void add(String key, File file) {
    _cache[key] = file;
  }

  /// キャッシュから取得
  static File? get(String key) {
    return _cache[key];
  }

  /// キャッシュをクリア
  static void clear() {
    _cache.clear();
  }

  /// 特定のキャッシュを削除
  static void remove(String key) {
    _cache.remove(key);
  }
}
