import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:minq/data/services/image_moderation_service.dart';
import 'package:minq/data/services/photo_storage_service.dart';
import 'package:path/path.dart' as p;

class _FakeImagePicker extends ImagePicker {
  _FakeImagePicker(this._file);

  final XFile _file;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    return _file;
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('photo_service_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('sanitizes photos and hashes filenames', () async {
    final image = img.Image(width: 2, height: 2);
    image.fill(0xFF42A5F5);
    final originalBytes = img.encodeJpg(image);

    final originalFile = File(p.join(tempDir.path, 'original.jpg'));
    await originalFile.writeAsBytes(originalBytes);

    final picker = _FakeImagePicker(XFile(originalFile.path));
    final service = PhotoStorageService(
      imagePicker: picker,
      documentsDirectoryBuilder: () async => tempDir,
    );

    final result = await service.captureAndSanitize(
      ownerUid: 'user123',
      questId: 7,
    );

    expect(result.hasFile, isTrue);
    expect(File(result.path).existsSync(), isTrue);
    expect(result.path, isNot(contains('original.jpg')));
    expect(result.path, contains('proof_photos/user123'));
    expect(await File(result.path).length(), greaterThan(0));
    expect(originalFile.existsSync(), isFalse);
    expect(result.moderationVerdict, PhotoModerationVerdict.ok);
  });

  test('flags extremely dark images for moderation', () async {
    final image = img.Image(width: 16, height: 16);
    image.fill(0xFF000000);
    final originalBytes = img.encodeJpg(image);

    final originalFile = File(p.join(tempDir.path, 'dark.jpg'));
    await originalFile.writeAsBytes(originalBytes);

    final picker = _FakeImagePicker(XFile(originalFile.path));
    final service = PhotoStorageService(
      imagePicker: picker,
      documentsDirectoryBuilder: () async => tempDir,
      moderationService: const ImageModerationService(),
    );

    final result = await service.captureAndSanitize(
      ownerUid: 'user123',
      questId: 8,
    );

    expect(result.moderationVerdict, PhotoModerationVerdict.tooDark);
  });
}
