import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 有機的な成長アニメーションを持つスプラッシュ画面
/// 種から芽、葉、完全なアイコンへの4段階の成長を表現
class OrganicSplashScreen extends ConsumerStatefulWidget {
  const OrganicSplashScreen({super.key});

  @override
  ConsumerState<OrganicSplashScreen> createState() => _OrganicSplashScreenState();
}

class _OrganicSplashScreenState extends ConsumerState<OrganicSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterController;
  late AnimationController _backgroundController;

  late Animation<double> _seedPulse;
  late Animation<double> _sproutGrowth;
  late Animation<double> _leafExpansion;
  late Animation<double> _finalScale;
  late Animation<Color?> _backgroundTransition;
  late Animation<double> _iconOpacity;

  GrowthStage _currentStage = GrowthStage.seed;
  bool _initializationComplete = false;
  Timer? _minimumDurationTimer;

  static const Duration _minAnimationDuration = Duration(milliseconds: 1500);
  static const Duration _maxAnimationDuration = Duration(milliseconds: 2000);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startGrowthSequence();
  }

  void _initializeAnimations() {
    // メインアニメーションコントローラー（1.5-2.0秒）
    _masterController = AnimationController(
      duration: _minAnimationDuration,
      vsync: this,
    );

    // 背景色変化用コントローラー
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 種の脈動アニメーション (0.0-0.4s)
    _seedPulse = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.0, 0.27, curve: Curves.easeInOut),
    ));

    // 芽の成長アニメーション (0.4-0.9s)
    _sproutGrowth = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.27, 0.6, curve: Curves.easeOutBack),
    ));

    // 葉っぱの展開アニメーション (0.9-1.3s)
    _leafExpansion = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.6, 0.87, curve: Curves.elasticOut),
    ));

    // 最終スケールアニメーション (1.3-1.5s)
    _finalScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.87, 1.0, curve: Curves.easeOutBack),
    ));

    // アイコンの透明度
    _iconOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _masterController,
      curve: const Interval(0.87, 1.0, curve: Curves.easeOut),
    ));

    // 背景色の変化
    _backgroundTransition = ColorTween(
      begin: const Color(0xFF8B4513), // 土色
      end: const Color(0xFFFFFFFF),   // 白
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // アニメーション進行に応じてステージを更新
    _masterController.addListener(_updateGrowthStage);
  }

  void _updateGrowthStage() {
    final progress = _masterController.value;
    GrowthStage newStage;

    if (progress < 0.27) {
      newStage = GrowthStage.seed;
    } else if (progress < 0.6) {
      newStage = GrowthStage.sprout;
    } else if (progress < 0.87) {
      newStage = GrowthStage.leafGrowth;
    } else {
      newStage = GrowthStage.mature;
    }

    if (newStage != _currentStage) {
      setState(() {
        _currentStage = newStage;
      });

      // 触覚フィードバック
      if (newStage != GrowthStage.seed) {
        HapticFeedback.lightImpact();
      }
    }
  }

  Future<void> _startGrowthSequence() async {
    // 初期化開始の触覚フィードバック
    HapticFeedback.mediumImpact();

    // アニメーションと初期化を並列実行
    final animationFuture = _masterController.forward();
    final backgroundAnimationFuture = _backgroundController.forward();

    // 初期化プロセスの監視はbuildメソッドで行う

    // 最小アニメーション時間を保証
    _minimumDurationTimer = Timer(_minAnimationDuration, () {
      if (_initializationComplete && mounted) {
        _completeAndNavigate();
      }
    });

    await Future.wait([animationFuture, backgroundAnimationFuture]);
  }

  void _watchInitialization() {
    // アプリ初期化の監視をbuildメソッドで行う
    // ここでは何もしない
  }

  void _completeAndNavigate() {
    // 完了の触覚フィードバック
    HapticFeedback.heavyImpact();

    // 遷移は main.dart の MaterialApp.router が自動的に処理
    // ここでは何もしない（クラッシュリカバリダイアログもスキップ）
  }

  @override
  void dispose() {
    _masterController.dispose();
    _backgroundController.dispose();
    _minimumDurationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // アプリ初期化の監視をbuildメソッドで行う
    ref.listen<AsyncValue<void>>(optimizedAppStartupProvider, (previous, next) {
      next.when(
        data: (_) {
          _initializationComplete = true;
          // アニメーションが完了していれば即座に遷移
          if (_masterController.isCompleted && mounted) {
            _completeAndNavigate();
          }
        },
        loading: () {
          // 初期化中は何もしない
        },
        error: (error, stackTrace) {
          // エラーが発生した場合でも遷移を続行
          _initializationComplete = true;
          if (mounted) {
            _completeAndNavigate();
          }
        },
      );
    });

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_masterController, _backgroundController]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: _buildBackgroundGradient(isDark),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // メイン成長アニメーション
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: OrganicGrowthPainter(
                        stage: _currentStage,
                        seedPulse: _seedPulse.value,
                        sproutGrowth: _sproutGrowth.value,
                        leafExpansion: _leafExpansion.value,
                        finalScale: _finalScale.value,
                        iconOpacity: _iconOpacity.value,
                        isDark: isDark,
                        primaryColor: tokens.brandPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // アプリ名（最終段階で表示）
                  AnimatedOpacity(
                    opacity: _currentStage == GrowthStage.mature ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          tokens.brandPrimary,
                          tokens.brandPrimary.withOpacity(0.8),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'MinQ',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // サブタイトル
                  AnimatedOpacity(
                    opacity: _currentStage == GrowthStage.mature ? 0.8 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '習慣の種を育てよう',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  LinearGradient _buildBackgroundGradient(bool isDark) {
    final progress = _backgroundController.value;

    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(const Color(0xFF2D1B0E), const Color(0xFF1A1A1A), progress)!,
          Color.lerp(const Color(0xFF4A2C1A), const Color(0xFF2A2A2A), progress)!,
          Color.lerp(const Color(0xFF654321), const Color(0xFF3A3A3A), progress)!,
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(const Color(0xFF8B4513), const Color(0xFFF8FAFC), progress)!,
          Color.lerp(const Color(0xFFA0522D), const Color(0xFFE2E8F0), progress)!,
          Color.lerp(const Color(0xFFCD853F), const Color(0xFFCBD5E1), progress)!,
        ],
      );
    }
  }
}

/// 成長段階の列挙型
enum GrowthStage {
  seed,      // 種の段階
  sprout,    // 発芽段階
  leafGrowth,// 葉っぱ成長
  mature,    // 成熟したアイコン
}

/// 有機的な成長アニメーションを描画するカスタムペインター
class OrganicGrowthPainter extends CustomPainter {
  final GrowthStage stage;
  final double seedPulse;
  final double sproutGrowth;
  final double leafExpansion;
  final double finalScale;
  final double iconOpacity;
  final bool isDark;
  final Color primaryColor;

  OrganicGrowthPainter({
    required this.stage,
    required this.seedPulse,
    required this.sproutGrowth,
    required this.leafExpansion,
    required this.finalScale,
    required this.iconOpacity,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    switch (stage) {
      case GrowthStage.seed:
        _drawSeed(canvas, center, paint);
        break;
      case GrowthStage.sprout:
        _drawSprout(canvas, center, paint);
        break;
      case GrowthStage.leafGrowth:
        _drawLeafGrowth(canvas, center, paint);
        break;
      case GrowthStage.mature:
        _drawMatureIcon(canvas, center, paint);
        break;
    }
  }

  void _drawSeed(Canvas canvas, Offset center, Paint paint) {
    final radius = 8.0 * seedPulse;

    // 種の影
    paint.color = Colors.black.withOpacity(0.2);
    canvas.drawCircle(center + const Offset(2, 2), radius, paint);

    // 種本体
    paint.color = const Color(0xFF8B4513);
    canvas.drawCircle(center, radius, paint);

    // 種の模様
    paint.color = const Color(0xFF654321);
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius * 0.7, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawSprout(Canvas canvas, Offset center, Paint paint) {
    // 種（小さくなる）
    final seedRadius = 6.0;
    paint.color = const Color(0xFF8B4513);
    canvas.drawCircle(center + const Offset(0, 20), seedRadius, paint);

    // 芽の茎
    final stemHeight = 40.0 * sproutGrowth;
    paint.color = const Color(0xFF228B22);
    paint.strokeWidth = 4.0;
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(center.dx, center.dy + 20);
    stemPath.quadraticBezierTo(
      center.dx - 5, center.dy + 10 - stemHeight * 0.5,
      center.dx, center.dy + 20 - stemHeight,
    );
    canvas.drawPath(stemPath, paint);

    // 小さな葉っぱ
    if (sproutGrowth > 0.5) {
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFF32CD32);

      final leafSize = 8.0 * (sproutGrowth - 0.5) * 2;
      final leafCenter = Offset(center.dx, center.dy + 20 - stemHeight);

      final leafPath = Path();
      leafPath.moveTo(leafCenter.dx, leafCenter.dy);
      leafPath.quadraticBezierTo(
        leafCenter.dx - leafSize, leafCenter.dy - leafSize * 0.5,
        leafCenter.dx - leafSize * 0.5, leafCenter.dy - leafSize,
      );
      leafPath.quadraticBezierTo(
        leafCenter.dx, leafCenter.dy - leafSize * 0.5,
        leafCenter.dx, leafCenter.dy,
      );
      canvas.drawPath(leafPath, paint);
    }
  }

  void _drawLeafGrowth(Canvas canvas, Offset center, Paint paint) {
    // 茎
    paint.color = const Color(0xFF228B22);
    paint.strokeWidth = 6.0;
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(center.dx, center.dy + 25);
    stemPath.quadraticBezierTo(
      center.dx - 5, center.dy,
      center.dx, center.dy - 25,
    );
    canvas.drawPath(stemPath, paint);

    // 展開する葉っぱ
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF32CD32);

    final leafSize = 25.0 * leafExpansion;

    // 左の葉っぱ
    final leftLeafPath = Path();
    leftLeafPath.moveTo(center.dx - 5, center.dy - 10);
    leftLeafPath.quadraticBezierTo(
      center.dx - 5 - leafSize, center.dy - 10 - leafSize * 0.3,
      center.dx - 5 - leafSize * 0.7, center.dy - 10 - leafSize,
    );
    leftLeafPath.quadraticBezierTo(
      center.dx - 5 - leafSize * 0.3, center.dy - 10 - leafSize * 0.5,
      center.dx - 5, center.dy - 10,
    );
    canvas.drawPath(leftLeafPath, paint);

    // 右の葉っぱ
    final rightLeafPath = Path();
    rightLeafPath.moveTo(center.dx + 5, center.dy - 5);
    rightLeafPath.quadraticBezierTo(
      center.dx + 5 + leafSize, center.dy - 5 - leafSize * 0.3,
      center.dx + 5 + leafSize * 0.7, center.dy - 5 - leafSize,
    );
    rightLeafPath.quadraticBezierTo(
      center.dx + 5 + leafSize * 0.3, center.dy - 5 - leafSize * 0.5,
      center.dx + 5, center.dy - 5,
    );
    canvas.drawPath(rightLeafPath, paint);

    // 上の葉っぱ
    final topLeafPath = Path();
    topLeafPath.moveTo(center.dx, center.dy - 25);
    topLeafPath.quadraticBezierTo(
      center.dx - leafSize * 0.3, center.dy - 25 - leafSize,
      center.dx, center.dy - 25 - leafSize * 1.2,
    );
    topLeafPath.quadraticBezierTo(
      center.dx + leafSize * 0.3, center.dy - 25 - leafSize,
      center.dx, center.dy - 25,
    );
    canvas.drawPath(topLeafPath, paint);
  }

  void _drawMatureIcon(Canvas canvas, Offset center, Paint paint) {
    final iconSize = 50.0 * finalScale;

    // アイコンの背景円
    paint.color = primaryColor.withOpacity(iconOpacity);
    canvas.drawCircle(center, iconSize, paint);

    // アイコンの影
    paint.color = Colors.black.withOpacity(0.1 * iconOpacity);
    canvas.drawCircle(center + const Offset(3, 3), iconSize, paint);

    // アイコン内のシンボル（簡単な葉っぱマーク）
    paint.color = Colors.white.withOpacity(iconOpacity);
    paint.style = PaintingStyle.fill;

    final symbolPath = Path();
    symbolPath.moveTo(center.dx, center.dy - iconSize * 0.4);
    symbolPath.quadraticBezierTo(
      center.dx - iconSize * 0.3, center.dy - iconSize * 0.1,
      center.dx - iconSize * 0.2, center.dy + iconSize * 0.2,
    );
    symbolPath.quadraticBezierTo(
      center.dx, center.dy + iconSize * 0.1,
      center.dx + iconSize * 0.2, center.dy + iconSize * 0.2,
    );
    symbolPath.quadraticBezierTo(
      center.dx + iconSize * 0.3, center.dy - iconSize * 0.1,
      center.dx, center.dy - iconSize * 0.4,
    );
    canvas.drawPath(symbolPath, paint);

    // 茎
    paint.strokeWidth = 3.0 * finalScale;
    paint.strokeCap = StrokeCap.round;
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx, center.dy + iconSize * 0.1),
      Offset(center.dx, center.dy + iconSize * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}