import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// コンテキストアウェアサービス
/// 時間・天気・位置・デバイス状態に基づいてUIを動的に調整
class ContextAwareService {
  static ContextAwareService? _instance;
  static ContextAwareService get instance => _instance ??= ContextAwareService._();
  
  ContextAwareService._();

  Timer? _contextUpdateTimer;
  final ValueNotifier<AppContext> _currentContext = ValueNotifier(AppContext.initial());
  
  ValueListenable<AppContext> get currentContext => _currentContext;

  /// サービスの初期化
  Future<void> initialize() async {
    try {
      log('ContextAwareService: 初期化開始');
      
      // 初期コンテキストを取得
      await _updateContext();
      
      // 定期的にコンテキストを更新（5分ごと）
      _contextUpdateTimer = Timer.periodic(
        const Duration(minutes: 5),
        (_) => _updateContext(),
      );
      
      log('ContextAwareService: 初期化完了');
    } catch (e) {
      log('ContextAwareService: 初期化エラー - $e');
    }
  }

  /// コンテキストの手動更新
  Future<void> refreshContext() async {
    await _updateContext();
  }

  /// サービスの終了
  void dispose() {
    _contextUpdateTimer?.cancel();
    _currentContext.dispose();
  }

  /// コンテキストを更新
  Future<void> _updateContext() async {
    try {
      final timeContext = _getTimeContext();
      final weatherContext = await _getWeatherContext();
      final deviceContext = _getDeviceContext();
      final activityContext = _getActivityContext();
      
      final newContext = AppContext(
        timeOfDay: timeContext.timeOfDay,
        season: timeContext.season,
        dayOfWeek: timeContext.dayOfWeek,
        weather: weatherContext,
        deviceBattery: deviceContext.deviceBattery,
        isCharging: deviceContext.isCharging,
        networkType: deviceContext.networkType,
        activityLevel: activityContext.activityLevel,
        focusMode: activityContext.focusMode,
        lastUpdated: DateTime.now(),
      );
      
      _currentContext.value = newContext;
      log('ContextAwareService: コンテキスト更新完了');
    } catch (e) {
      log('ContextAwareService: コンテキスト更新エラー - $e');
    }
  }

  /// 時間コンテキストを取得
  TimeContext _getTimeContext() {
    final now = DateTime.now();
    final hour = now.hour;
    
    TimeOfDay timeOfDay;
    if (hour >= 5 && hour < 12) {
      timeOfDay = TimeOfDay.morning;
    } else if (hour >= 12 && hour < 17) {
      timeOfDay = TimeOfDay.afternoon;
    } else if (hour >= 17 && hour < 21) {
      timeOfDay = TimeOfDay.evening;
    } else {
      timeOfDay = TimeOfDay.night;
    }
    
    Season season;
    final month = now.month;
    if (month >= 3 && month <= 5) {
      season = Season.spring;
    } else if (month >= 6 && month <= 8) {
      season = Season.summer;
    } else if (month >= 9 && month <= 11) {
      season = Season.autumn;
    } else {
      season = Season.winter;
    }
    
    return TimeContext(
      timeOfDay: timeOfDay,
      season: season,
      dayOfWeek: DayOfWeek.values[now.weekday - 1],
    );
  }

  /// 天気コンテキストを取得
  Future<WeatherContext> _getWeatherContext() async {
    try {
      // 位置情報を取得
      final position = await _getCurrentPosition();
      if (position == null) {
        return WeatherContext.unknown();
      }
      
      // 天気情報を取得（OpenWeatherMap API使用）
      final weatherData = await _fetchWeatherData(position.latitude, position.longitude);
      
      return WeatherContext(
        condition: _parseWeatherCondition(weatherData['weather'][0]['main']),
        temperature: (weatherData['main']['temp'] as num).toDouble(),
        humidity: (weatherData['main']['humidity'] as num).toInt(),
        windSpeed: (weatherData['wind']['speed'] as num).toDouble(),
        visibility: (weatherData['visibility'] as num?)?.toDouble() ?? 10000.0,
      );
    } catch (e) {
      log('ContextAwareService: 天気取得エラー - $e');
      return WeatherContext.unknown();
    }
  }

  /// 現在位置を取得
  Future<Position?> _getCurrentPosition() async {
    try {
      // 位置情報の権限確認
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return null;
      }
      
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      log('ContextAwareService: 位置情報取得エラー - $e');
      return null;
    }
  }

  /// 天気データを取得
  Future<Map<String, dynamic>> _fetchWeatherData(double lat, double lon) async {
    // 注意: 実際の実装では環境変数からAPIキーを取得してください
    const apiKey = 'YOUR_OPENWEATHER_API_KEY';
    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('天気データの取得に失敗しました');
    }
  }

  /// 天気状況を解析
  WeatherCondition _parseWeatherCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return WeatherCondition.sunny;
      case 'clouds':
        return WeatherCondition.cloudy;
      case 'rain':
      case 'drizzle':
        return WeatherCondition.rainy;
      case 'snow':
        return WeatherCondition.snowy;
      case 'thunderstorm':
        return WeatherCondition.stormy;
      case 'mist':
      case 'fog':
        return WeatherCondition.foggy;
      default:
        return WeatherCondition.unknown;
    }
  }

  /// デバイスコンテキストを取得
  DeviceContext _getDeviceContext() {
    // 実際の実装では battery_plus パッケージなどを使用
    return DeviceContext(
      deviceBattery: 0.8, // サンプル値
      isCharging: false,
      networkType: NetworkType.wifi,
    );
  }

  /// アクティビティコンテキストを取得
  ActivityContext _getActivityContext() {
    final hour = DateTime.now().hour;
    
    ActivityLevel activityLevel;
    if (hour >= 6 && hour <= 9) {
      activityLevel = ActivityLevel.high; // 朝の活動時間
    } else if (hour >= 10 && hour <= 16) {
      activityLevel = ActivityLevel.medium; // 日中
    } else if (hour >= 17 && hour <= 20) {
      activityLevel = ActivityLevel.high; // 夕方の活動時間
    } else {
      activityLevel = ActivityLevel.low; // 夜間
    }
    
    return ActivityContext(
      activityLevel: activityLevel,
      focusMode: FocusMode.normal,
    );
  }
}

/// アプリコンテキスト
class AppContext {
  final TimeOfDay timeOfDay;
  final Season season;
  final DayOfWeek dayOfWeek;
  final WeatherContext weather;
  final double deviceBattery;
  final bool isCharging;
  final NetworkType networkType;
  final ActivityLevel activityLevel;
  final FocusMode focusMode;
  final DateTime lastUpdated;

  AppContext({
    required this.timeOfDay,
    required this.season,
    required this.dayOfWeek,
    required this.weather,
    required this.deviceBattery,
    required this.isCharging,
    required this.networkType,
    required this.activityLevel,
    required this.focusMode,
    required this.lastUpdated,
  });

  factory AppContext.initial() {
    return AppContext(
      timeOfDay: TimeOfDay.morning,
      season: Season.spring,
      dayOfWeek: DayOfWeek.monday,
      weather: WeatherContext.unknown(),
      deviceBattery: 1.0,
      isCharging: false,
      networkType: NetworkType.wifi,
      activityLevel: ActivityLevel.medium,
      focusMode: FocusMode.normal,
      lastUpdated: DateTime.now(),
    );
  }

  /// コンテキストに基づくテーマカラーを取得
  Color getPrimaryColor() {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return const Color(0xFF4CAF50); // 爽やかな緑
      case TimeOfDay.afternoon:
        return const Color(0xFF2196F3); // 明るい青
      case TimeOfDay.evening:
        return const Color(0xFFFF9800); // 温かいオレンジ
      case TimeOfDay.night:
        return const Color(0xFF9C27B0); // 落ち着いた紫
    }
  }

  /// コンテキストに基づく背景グラデーションを取得
  LinearGradient getBackgroundGradient() {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFBBDEFB),
          ],
        );
      case TimeOfDay.afternoon:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3E5F5),
            Color(0xFFE1BEE7),
          ],
        );
      case TimeOfDay.evening:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF3E0),
            Color(0xFFFFE0B2),
          ],
        );
      case TimeOfDay.night:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF263238),
            Color(0xFF37474F),
          ],
        );
    }
  }

  /// コンテキストに基づくメッセージを取得
  String getContextualMessage() {
    final messages = <String>[];
    
    // 時間帯メッセージ
    switch (timeOfDay) {
      case TimeOfDay.morning:
        messages.add('おはようございます！今日も素晴らしい一日にしましょう 🌅');
        break;
      case TimeOfDay.afternoon:
        messages.add('お疲れさまです！午後も頑張りましょう ☀️');
        break;
      case TimeOfDay.evening:
        messages.add('お疲れさまでした！今日の成果を振り返りましょう 🌆');
        break;
      case TimeOfDay.night:
        messages.add('今日もお疲れさまでした。ゆっくり休んでください 🌙');
        break;
    }
    
    // 天気メッセージ
    switch (weather.condition) {
      case WeatherCondition.sunny:
        messages.add('今日は良い天気ですね！外での活動にぴったりです');
        break;
      case WeatherCondition.rainy:
        messages.add('雨の日は室内での習慣に集中しましょう');
        break;
      case WeatherCondition.cloudy:
        messages.add('曇り空でも心は晴れやかに！');
        break;
      default:
        break;
    }
    
    return messages.isNotEmpty ? messages.first : 'MinQで素晴らしい習慣を築きましょう！';
  }

  /// 推奨される習慣を取得
  List<String> getRecommendedHabits() {
    final habits = <String>[];
    
    switch (timeOfDay) {
      case TimeOfDay.morning:
        habits.addAll(['朝の瞑想', 'ストレッチ', '読書', '日記']);
        break;
      case TimeOfDay.afternoon:
        habits.addAll(['散歩', '水分補給', '深呼吸', '学習']);
        break;
      case TimeOfDay.evening:
        habits.addAll(['振り返り', '感謝日記', '軽い運動', '整理整頓']);
        break;
      case TimeOfDay.night:
        habits.addAll(['読書', '瞑想', 'ストレッチ', '明日の準備']);
        break;
    }
    
    // 天気に基づく習慣
    switch (weather.condition) {
      case WeatherCondition.sunny:
        habits.addAll(['散歩', 'ジョギング', '外での運動']);
        break;
      case WeatherCondition.rainy:
        habits.addAll(['読書', '瞑想', '室内運動', '学習']);
        break;
      default:
        break;
    }
    
    return habits.take(5).toList();
  }
}

/// 時間コンテキスト
class TimeContext {
  final TimeOfDay timeOfDay;
  final Season season;
  final DayOfWeek dayOfWeek;

  TimeContext({
    required this.timeOfDay,
    required this.season,
    required this.dayOfWeek,
  });
}

/// 天気コンテキスト
class WeatherContext {
  final WeatherCondition condition;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final double visibility;

  WeatherContext({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.visibility,
  });

  factory WeatherContext.unknown() {
    return WeatherContext(
      condition: WeatherCondition.unknown,
      temperature: 20.0,
      humidity: 50,
      windSpeed: 0.0,
      visibility: 10000.0,
    );
  }
}

/// デバイスコンテキスト
class DeviceContext {
  final double deviceBattery;
  final bool isCharging;
  final NetworkType networkType;

  DeviceContext({
    required this.deviceBattery,
    required this.isCharging,
    required this.networkType,
  });
}

/// アクティビティコンテキスト
class ActivityContext {
  final ActivityLevel activityLevel;
  final FocusMode focusMode;

  ActivityContext({
    required this.activityLevel,
    required this.focusMode,
  });
}

/// 列挙型
enum TimeOfDay { morning, afternoon, evening, night }
enum Season { spring, summer, autumn, winter }
enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }
enum WeatherCondition { sunny, cloudy, rainy, snowy, stormy, foggy, unknown }
enum NetworkType { wifi, cellular, none }
enum ActivityLevel { low, medium, high }
enum FocusMode { normal, focus, doNotDisturb }