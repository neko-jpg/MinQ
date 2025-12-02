import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

/// デバイス情報サービス
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// デバイス情報を取得
  Future<DeviceInfo> getDeviceInfo() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return DeviceInfo(
        platform: DevicePlatform.android,
        model: androidInfo.model,
        manufacturer: androidInfo.manufacturer,
        osVersion: androidInfo.version.release,
        isPhysicalDevice: androidInfo.isPhysicalDevice,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return DeviceInfo(
        platform: DevicePlatform.ios,
        model: iosInfo.model,
        manufacturer: 'Apple',
        osVersion: iosInfo.systemVersion,
        isPhysicalDevice: iosInfo.isPhysicalDevice,
      );
    }
    return const DeviceInfo(
      platform: DevicePlatform.unknown,
      model: 'Unknown',
      manufacturer: 'Unknown',
      osVersion: 'Unknown',
      isPhysicalDevice: true,
    );
  }

  /// デバイスサイズカテゴリーを取得
  DeviceSizeCategory getDeviceSizeCategory(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal = _calculateDiagonal(size.width, size.height);

    if (diagonal < 6.0) {
      return DeviceSizeCategory.small;
    } else if (diagonal < 7.0) {
      return DeviceSizeCategory.medium;
    } else if (diagonal < 10.0) {
      return DeviceSizeCategory.large;
    } else {
      return DeviceSizeCategory.tablet;
    }
  }

  /// 対角線の長さを計算（インチ）
  double _calculateDiagonal(double width, double height) {
    final pixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    final widthInches = width / (pixelRatio * 160);
    final heightInches = height / (pixelRatio * 160);
    return sqrt(widthInches * widthInches + heightInches * heightInches);
  }

  /// 低メモリデバイスかチェック
  Future<bool> isLowMemoryDevice() async {
    // TODO: Implement memory check using available API
    // if (Platform.isAndroid) {
    //   final androidInfo = await _deviceInfo.androidInfo;
    //   // 2GB以下を低メモリとみなす
    //   return (androidInfo.totalMemory ?? 0) < 2 * 1024 * 1024 * 1024;
    // }
    return false;
  }

  /// 低速デバイスかチェック
  Future<bool> isLowPerformanceDevice() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      // Android 8.0以下を低速とみなす
      return androidInfo.version.sdkInt < 26;
    }
    return false;
  }
}

/// デバイス情報
class DeviceInfo {
  final DevicePlatform platform;
  final String model;
  final String manufacturer;
  final String osVersion;
  final bool isPhysicalDevice;

  const DeviceInfo({
    required this.platform,
    required this.model,
    required this.manufacturer,
    required this.osVersion,
    required this.isPhysicalDevice,
  });
}

/// デバイスプラットフォーム
enum DevicePlatform {
  android,
  ios,
  unknown,
}

/// デバイスサイズカテゴリー
enum DeviceSizeCategory {
  small,
  medium,
  large,
  tablet,
}

/// セーフエリアヘルパー
class SafeAreaHelper {
  /// セーフエリアのパディングを取得
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// ノッチがあるかチェック
  static bool hasNotch(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top > 24; // 通常のステータスバーより大きい
  }

  /// ホームインジケータがあるかチェック
  static bool hasHomeIndicator(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.bottom > 0;
  }
}

/// 画面回転制御
class OrientationController {
  /// 縦向き固定
  static void lockPortrait() {
    // TODO: SystemChrome.setPreferredOrientations
  }

  /// 横向き固定
  static void lockLandscape() {
    // TODO: SystemChrome.setPreferredOrientations
  }

  /// 回転を許可
  static void allowRotation() {
    // TODO: SystemChrome.setPreferredOrientations
  }
}

/// パフォーマンス最適化設定
class PerformanceConfig {
  final bool enableAnimations;
  final bool enableShadows;
  final bool enableBlur;
  final int imageQuality;

  const PerformanceConfig({
    this.enableAnimations = true,
    this.enableShadows = true,
    this.enableBlur = true,
    this.imageQuality = 100,
  });

  /// 高性能デバイス用
  static const high = PerformanceConfig();

  /// 中性能デバイス用
  static const medium = PerformanceConfig(
    enableBlur: false,
    imageQuality: 85,
  );

  /// 低性能デバイス用
  static const low = PerformanceConfig(
    enableAnimations: false,
    enableShadows: false,
    enableBlur: false,
    imageQuality: 70,
  );
}
