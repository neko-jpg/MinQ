import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:package_info_plus/package_info_plus.dart';

import 'package:minq/core/logging/app_logger.dart';

/// バージョン互換性チェックサービス

class VersionCheckService {
  final FirebaseRemoteConfig? _remoteConfig;

  final AppLogger _logger;

  VersionCheckService(this._remoteConfig, this._logger);

  /// 現在のアプリバージョンが最小サポートバージョンを満たしているか確認

  Future<VersionCheckResult> checkVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final currentVersion = packageInfo.version;

      final remoteConfig = _remoteConfig;

      if (remoteConfig == null) {
        _logger.info(
          'Skipping version check because Firebase Remote Config is unavailable.',
        );

        return VersionCheckResult.supported(currentVersion);
      }

      await remoteConfig.fetchAndActivate();

      final minSupportedVersion = remoteConfig.getString(
        'min_supported_version',
      );

      final recommendedVersion = remoteConfig.getString('recommended_version');

      final forceUpdateEnabled = remoteConfig.getBool('force_update_enabled');

      _logger.info(
        'Version check: current=$currentVersion, min=$minSupportedVersion, recommended=$recommendedVersion',
      );

      if (minSupportedVersion.isEmpty) {
        return VersionCheckResult.supported(currentVersion);
      }

      final isSupported =
          _compareVersions(currentVersion, minSupportedVersion) >= 0;

      final isRecommended =
          recommendedVersion.isEmpty ||
          _compareVersions(currentVersion, recommendedVersion) >= 0;

      if (!isSupported && forceUpdateEnabled) {
        return VersionCheckResult.forceUpdate(
          currentVersion: currentVersion,

          minVersion: minSupportedVersion,
        );
      }

      if (!isRecommended) {
        return VersionCheckResult.updateAvailable(
          currentVersion: currentVersion,

          recommendedVersion: recommendedVersion,
        );
      }

      return VersionCheckResult.supported(currentVersion);
    } catch (e, stack) {
      _logger.error('Version check failed', e, stack);

      // ?G???[????T?|?[?g???????????i???[?U?[???????????j

      return VersionCheckResult.error();
    }
  }

  /// バージョン文字列を比較（例: "1.2.3" vs "1.2.0"）

  /// 戻り値: 正=currentが新しい, 0=同じ, 負=currentが古い

  int _compareVersions(String current, String target) {
    final currentParts =
        current.split('.').map(int.tryParse).whereType<int>().toList();

    final targetParts =
        target.split('.').map(int.tryParse).whereType<int>().toList();

    final maxLength =
        currentParts.length > targetParts.length
            ? currentParts.length
            : targetParts.length;

    for (var i = 0; i < maxLength; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;

      final targetPart = i < targetParts.length ? targetParts[i] : 0;

      if (currentPart != targetPart) {
        return currentPart - targetPart;
      }
    }

    return 0;
  }
}

/// バージョンチェック結果

sealed class VersionCheckResult {
  const VersionCheckResult();

  factory VersionCheckResult.supported(String currentVersion) =
      VersionSupported;

  factory VersionCheckResult.updateAvailable({
    required String currentVersion,

    required String recommendedVersion,
  }) = VersionUpdateAvailable;

  factory VersionCheckResult.forceUpdate({
    required String currentVersion,

    required String minVersion,
  }) = VersionForceUpdate;

  factory VersionCheckResult.error() = VersionCheckError;
}

class VersionSupported extends VersionCheckResult {
  final String currentVersion;

  const VersionSupported(this.currentVersion);
}

class VersionUpdateAvailable extends VersionCheckResult {
  final String currentVersion;

  final String recommendedVersion;

  const VersionUpdateAvailable({
    required this.currentVersion,

    required this.recommendedVersion,
  });
}

class VersionForceUpdate extends VersionCheckResult {
  final String currentVersion;

  final String minVersion;

  const VersionForceUpdate({
    required this.currentVersion,

    required this.minVersion,
  });
}

class VersionCheckError extends VersionCheckResult {
  const VersionCheckError();
}

/// Provider

final versionCheckServiceProvider = Provider<VersionCheckService>((ref) {
  FirebaseRemoteConfig? remoteConfig;
  try {
    remoteConfig = FirebaseRemoteConfig.instance;
  } catch (_) {
    remoteConfig = null;
  }
  final logger = AppLogger();
  return VersionCheckService(remoteConfig, logger);
});

final versionCheckProvider = FutureProvider<VersionCheckResult>((ref) async {
  final service = ref.watch(versionCheckServiceProvider);

  return service.checkVersion();
});
