import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:minq/data/services/image_moderation_service.dart';

class PhotoStorageService {
  PhotoStorageService({
    ImagePicker? imagePicker,
    this.quality = 85,
    Uuid? uuid,
    Future<Directory> Function()? documentsDirectoryBuilder,
    ImageModerationService? moderationService,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _uuid = uuid ?? const Uuid(),
        _documentsDirectoryBuilder =
            documentsDirectoryBuilder ?? getApplicationDocumentsDirectory,
        _moderationService = moderationService ?? const ImageModerationService();

  final ImagePicker _imagePicker;
  final int quality;
  final Uuid _uuid;
  final Future<Directory> Function() _documentsDirectoryBuilder;
  final ImageModerationService _moderationService;

  Future<PhotoCaptureResult> captureAndSanitize({
    required String ownerUid,
    required int questId,
  }) async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: quality,
      );
      if (file == null) {
        return PhotoCaptureResult.empty();
      }

      final sanitized = await _sanitizeAndPersist(
        file,
        ownerUid: ownerUid,
        questId: questId,
      );
      return PhotoCaptureResult(
        path: sanitized.path,
        bytes: sanitized.bytes,
        moderationVerdict: sanitized.verdict,
      );
    } on PlatformException catch (error) {
      throw PhotoCaptureException.fromPlatform(error);
    } on Exception catch (error) {
      throw PhotoCaptureException(PhotoCaptureFailure.cameraFailure, error);
    }
  }

  Future<_SanitizedPhoto> _sanitizeAndPersist(
    XFile original, {
    required String ownerUid,
    required int questId,
  }) async {
    final Uint8List rawBytes = await original.readAsBytes();
    final decoded = img.decodeImage(rawBytes);
    if (decoded == null) {
      throw PhotoCaptureException(
        PhotoCaptureFailure.cameraFailure,
        Exception('Unable to decode captured image'),
      );
    }

    final verdict = _moderationService.evaluate(decoded);

    final sanitizedBytes = Uint8List.fromList(
      img.encodeJpg(decoded, quality: quality),
    );

    final directory = await _ensurePhotoDirectory(ownerUid);
    final hashedName = _uuid.v5(
      Uuid.NAMESPACE_URL,
      '$ownerUid-$questId-${DateTime.now().toUtc().toIso8601String()}-${sanitizedBytes.length}',
    );
    final sanitizedPath = p.join(directory.path, '$hashedName.jpg');
    final sanitizedFile = File(sanitizedPath);
    await sanitizedFile.writeAsBytes(sanitizedBytes, flush: true);

    await File(original.path).delete();

    return _SanitizedPhoto(
      path: sanitizedPath,
      bytes: sanitizedBytes.length,
      verdict: verdict,
    );
  }

  Future<Directory> _ensurePhotoDirectory(String ownerUid) async {
    final root = await _documentsDirectoryBuilder();
    final dir = Directory(p.join(root.path, 'proof_photos', ownerUid));
    if (!(await dir.exists())) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}

class PhotoCaptureResult {
  const PhotoCaptureResult({
    required this.path,
    required this.bytes,
    required this.moderationVerdict,
  });

  final String path;
  final int bytes;
  final PhotoModerationVerdict moderationVerdict;

  static PhotoCaptureResult empty() => const PhotoCaptureResult(
        path: '',
        bytes: 0,
        moderationVerdict: PhotoModerationVerdict.ok,
      );

  bool get hasFile => path.isNotEmpty;
}

enum PhotoCaptureFailure { permissionDenied, cameraFailure }

class PhotoCaptureException implements Exception {
  PhotoCaptureException(this.reason, [this.cause]);

  factory PhotoCaptureException.fromPlatform(PlatformException exception) {
    if (exception.code == 'camera_access_denied' ||
        exception.code == 'camera_access_restricted') {
      return PhotoCaptureException(PhotoCaptureFailure.permissionDenied, exception);
    }
    return PhotoCaptureException(PhotoCaptureFailure.cameraFailure, exception);
  }

  final PhotoCaptureFailure reason;
  final Object? cause;

  @override
  String toString() => 'PhotoCaptureException(reason: $reason, cause: $cause)';
}

class _SanitizedPhoto {
  _SanitizedPhoto({
    required this.path,
    required this.bytes,
    required this.verdict,
  });

  final String path;
  final int bytes;
  final PhotoModerationVerdict verdict;
}