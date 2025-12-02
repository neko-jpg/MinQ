import 'dart:ui';

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
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
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

    _pulseScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // パーティクルアニメーション
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // テキストアニメーション
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
  }

  void _startAnimationSequence() {
    // ロゴアニメーション開始
    _logoController.forward();

    // 脈動アニメーション（繰り返し）
    Future.delayed(const Duration(milliseconds: 800), () {
      _pulseController.repeat();
    });

    // パーティクルアニメーション（繰り返し）
    Future.delayed(const Duration(milliseconds: 500), () {
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
            colors:
                isDark
                    ? [
                      const Color(0xFF0F172A), // Slate 900
                      const Color(0xFF1E293B), // Slate 800
                      const Color(0xFF334155), // Slate 700
                    ]
                    : [
                      const Color(0xFFF8FAFC), // Slate 50
                      const Color(0xFFE2E8F0), // Slate 200
                      const Color(0xFFCBD5E1), // Slate 300
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
                    primaryColor: primaryColor,
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
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        primaryColor.withOpacity(
                                          _pulseOpacity.value * 0.4,
                                        ),
                                        primaryColor.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // メインロゴ（グラスモーフィズム風）
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 10,
                                    sigmaY: 10,
                                  ),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          primaryColor.withOpacity(0.9),
                                          primaryColor.withOpacity(0.7),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.4),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.psychology,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // アプリ名
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Column(
                          children: [
                            Text(
                              'MinQ',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                                letterSpacing: 1.5,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AI-Powered Habit Tracker',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.black54,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 80),

                  // ローディングセクション
                  SizedBox(
                    height: 80,
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
                                    fontSize: 14,
                                    color:
                                        isDark
                                            ? Colors.white60
                                            : Colors.black45,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // プログレスインジケーター
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _logoOpacity.value,
                              child: SizedBox(
                                width: 160,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    backgroundColor:
                                        isDark
                                            ? Colors.white10
                                            : Colors.black12,
                                    valueColor: AlwaysStoppedAnimation(
                                      primaryColor,
                                    ),
                                    minHeight: 4,
                                  ),
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
  final Color primaryColor;

  ParticlePainter({
    required this.animation,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // パーティクルの数と位置を計算
    for (int i = 0; i < 25; i++) {
      final progress = (animation.value + i * 0.04) % 1.0;
      final x = (i * 37.0 * 13.0) % size.width;
      final y =
          size.height * ((i * 17.0) % 100 / 100.0 + progress) % size.height;

      final opacity = (1.0 - progress) * 0.4;
      paint.color = primaryColor.withOpacity(opacity);

      final radius = (i % 3 + 1) * 1.5 * (1.0 - progress);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
