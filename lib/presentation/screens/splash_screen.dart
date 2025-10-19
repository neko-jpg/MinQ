import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// プレミアムスプラッシュ画面（ChatGPT風アニメーション）
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _textController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  
  String _loadingText = '';
  int _currentStreak = 0;
  
  final List<String> _loadingMessages = [
    'AIを初期化中...',
    'あなたの習慣データを読み込み中...',
    'パーソナライズ機能を準備中...',
    'コミュニティに接続中...',
    'すべて準備完了！',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _simulateLoading();
  }

  void _initializeAnimations() {
    // ロゴアニメーション
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    // 脈動アニメーション
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseOpacity = Tween<double>(begin: 0.8, end: 0.3).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    // パーティクルアニメーション
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // テキストアニメーション
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );
    
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );
  }

  void _startAnimationSequence() {
    // ロゴアニメーション開始
    _logoController.forward();
    
    // 脈動アニメーション（繰り返し）
    Future.delayed(const Duration(milliseconds: 800), () {
      _pulseController.repeat(reverse: true);
    });
    
    // パーティクルアニメーション（繰り返し）
    Future.delayed(const Duration(milliseconds: 1200), () {
      _particleController.repeat();
    });
  }

  void _simulateLoading() async {
    // 触覚フィードバック
    HapticFeedback.lightImpact();
    
    for (int i = 0; i < _loadingMessages.length; i++) {
      await Future.delayed(Duration(milliseconds: 600 + (i * 200)));
      
      if (mounted) {
        setState(() {
          _loadingText = _loadingMessages[i];
          _currentStreak = (i + 1) * 7; // サンプルストリーク
        });
        
        _textController.reset();
        _textController.forward();
        
        // 軽い触覚フィードバック
        if (i < _loadingMessages.length - 1) {
          HapticFeedback.selectionClick();
        }
      }
    }
    
    // 最終的な成功フィードバック
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A0A0A),
                    const Color(0xFF1A1A1A),
                    const Color(0xFF2A2A2A),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                    const Color(0xFFCBD5E1),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // 背景パーティクル
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    animation: _particleController,
                    isDark: isDark,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            
            // メインコンテンツ
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ロゴセクション
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoController,
                      _pulseController,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 脈動エフェクト
                              Transform.scale(
                                scale: _pulseScale.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        primaryColor.withOpacity(_pulseOpacity.value * 0.3),
                                        primaryColor.withOpacity(_pulseOpacity.value * 0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // メインロゴ
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      primaryColor,
                                      primaryColor.withOpacity(0.8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/app_icon.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              primaryColor,
                                              primaryColor.withOpacity(0.8),
                                            ],
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.psychology,
                                          size: 50,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // アプリ名
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'MinQ',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // サブタイトル
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value * 0.8,
                        child: Text(
                          'AI-Powered Habit Tracker',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            letterSpacing: 1,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // ローディングセクション
                  SizedBox(
                    height: 60,
                    child: Column(
                      children: [
                        // ローディングテキスト
                        AnimatedBuilder(
                          animation: _textController,
                          builder: (context, child) {
                            return SlideTransition(
                              position: _textSlide,
                              child: FadeTransition(
                                opacity: _textOpacity,
                                child: Text(
                                  _loadingText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // プログレスインジケーター
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoOpacity.value,
                              child: SizedBox(
                                width: 200,
                                child: LinearProgressIndicator(
                                  backgroundColor: isDark 
                                      ? Colors.grey.shade800 
                                      : Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation(primaryColor),
                                  minHeight: 3,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // ストリーク表示（右上）
            if (_currentStreak > 0)
              Positioned(
                top: 60,
                right: 24,
                child: AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textOpacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$_currentStreak日',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            // 時間帯メッセージ（左上）
            Positioned(
              top: 60,
              left: 24,
              child: AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value * 0.7,
                    child: Text(
                      _getTimeBasedMessage(),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeBasedMessage() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'おはようございます！ 🌅';
    } else if (hour >= 12 && hour < 17) {
      return 'こんにちは！ ☀️';
    } else if (hour >= 17 && hour < 21) {
      return 'こんばんは！ 🌆';
    } else {
      return 'お疲れさまです！ 🌙';
    }
  }
}

/// パーティクルエフェクトペインター
class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDark;
  
  ParticlePainter({
    required this.animation,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // パーティクルの数と位置を計算
    for (int i = 0; i < 20; i++) {
      final progress = (animation.value + i * 0.1) % 1.0;
      final x = (i * 37.0) % size.width;
      final y = size.height * progress;
      
      final opacity = (1.0 - progress) * 0.3;
      paint.color = isDark
          ? Colors.white.withOpacity(opacity)
          : Colors.grey.withOpacity(opacity);
      
      canvas.drawCircle(
        Offset(x, y),
        2.0 * (1.0 - progress),
        paint,
      );
    }
    
    // 追加のキラキラエフェクト
    for (int i = 0; i < 10; i++) {
      final sparkleProgress = (animation.value * 2 + i * 0.2) % 1.0;
      final sparkleX = (i * 73.0) % size.width;
      final sparkleY = (i * 47.0) % size.height;
      
      if (sparkleProgress > 0.8) {
        final sparkleOpacity = (1.0 - sparkleProgress) * 5.0;
        paint.color = isDark
            ? Colors.blue.withOpacity(sparkleOpacity * 0.5)
            : Colors.blue.withOpacity(sparkleOpacity * 0.3);
        
        _drawSparkle(canvas, Offset(sparkleX, sparkleY), paint);
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, Paint paint) {
    final path = Path();
    const size = 4.0;
    
    // 4方向の星形
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.3, center.dy - size * 0.3);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx + size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.3, center.dy + size * 0.3);
    path.lineTo(center.dx - size, center.dy);
    path.lineTo(center.dx - size * 0.3, center.dy - size * 0.3);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// スプラッシュ画面設定ガイド
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
