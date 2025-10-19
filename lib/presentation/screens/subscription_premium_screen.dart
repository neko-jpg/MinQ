import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/monetization/subscription_manager.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class SubscriptionPremiumScreen extends ConsumerStatefulWidget {
  const SubscriptionPremiumScreen({super.key});

  @override
  ConsumerState<SubscriptionPremiumScreen> createState() => _SubscriptionPremiumScreenState();
}

class _SubscriptionPremiumScreenState extends ConsumerState<SubscriptionPremiumScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedPlanIndex = 1; // デフォルトで年額プランを選択
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final subscriptionManager = ref.watch(subscriptionManagerProvider);
    final currentStatus = ref.watch(subscriptionStatusProvider);
    
    // プレミアムプランのみを表示
    final premiumPlans = SubscriptionManager.availablePlans
        .where((plan) => plan.id.contains('premium'))
        .toList();

    return Scaffold(
      backgroundColor: tokens.background,
      body: CustomScrollView(
        slivers: [
          // ヒーローセクション
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: tokens.brandPrimary,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      tokens.brandPrimary,
                      tokens.brandPrimary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(tokens.spacing(6)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            size: tokens.spacing(20),
                            color: Colors.white,
                          ),
                          SizedBox(height: tokens.spacing(4)),
                          Text(
                            'MinQ Premium',
                            style: tokens.typeScale.h1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: tokens.spacing(2)),
                          Text(
                            '習慣形成を次のレベルへ',
                            style: tokens.typeScale.h4.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 機能一覧
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'プレミアム機能',
                    style: tokens.typeScale.h3.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(4)),
                  ...premiumPlans.first.features.map((feature) => 
                    _buildFeatureItem(tokens, feature),
                  ).toList(),
                ],
              ),
            ),
          ),
          
          // プラン選択
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'プランを選択',
                    style: tokens.typeScale.h3.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(4)),
                  ...premiumPlans.asMap().entries.map((entry) {
                    final index = entry.key;
                    final plan = entry.value;
                    return _buildPlanCard(tokens, plan, index);
                  }).toList(),
                ],
              ),
            ),
          ),
          
          // 購入ボタン
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(6)),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tokens.brandPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: tokens.cornerLarge(),
                        ),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'プレミアムを開始',
                              style: tokens.typeScale.h4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: tokens.spacing(3)),
                  TextButton(
                    onPressed: _handleRestore,
                    child: Text(
                      '購入を復元',
                      style: tokens.typeScale.bodyMedium.copyWith(
                        color: tokens.brandPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  Text(
                    '• いつでもキャンセル可能\n• 自動更新（設定で変更可能）\n• 購入後すぐに全機能利用可能',
                    style: tokens.typeScale.bodySmall.copyWith(
                      color: tokens.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(MinqTheme tokens, String feature) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing(3)),
      child: Row(
        children: [
          Container(
            width: tokens.spacing(6),
            height: tokens.spacing(6),
            decoration: BoxDecoration(
              color: tokens.accentSuccess.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: tokens.spacing(4),
              color: tokens.accentSuccess,
            ),
          ),
          SizedBox(width: tokens.spacing(3)),
          Expanded(
            child: Text(
              feature,
              style: tokens.typeScale.bodyLarge.copyWith(
                color: tokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(MinqTheme tokens, SubscriptionPlan plan, int index) {
    final isSelected = _selectedPlanIndex == index;
    final isYearly = plan.id == SubscriptionManager.premiumYearlyId;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: Container(
        margin: EdgeInsets.only(bottom: tokens.spacing(3)),
        padding: EdgeInsets.all(tokens.spacing(4)),
        decoration: BoxDecoration(
          color: isSelected ? tokens.brandPrimary.withOpacity(0.1) : tokens.surface,
          border: Border.all(
            color: isSelected ? tokens.brandPrimary : tokens.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: tokens.cornerLarge(),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: index,
              groupValue: _selectedPlanIndex,
              onChanged: (value) => setState(() => _selectedPlanIndex = value!),
              activeColor: tokens.brandPrimary,
            ),
            SizedBox(width: tokens.spacing(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: tokens.typeScale.h4.copyWith(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isYearly) ...[
                        SizedBox(width: tokens.spacing(2)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.spacing(2),
                            vertical: tokens.spacing(1),
                          ),
                          decoration: BoxDecoration(
                            color: tokens.accentSuccess,
                            borderRadius: tokens.cornerSmall(),
                          ),
                          child: Text(
                            '30%お得',
                            style: tokens.typeScale.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: tokens.spacing(1)),
                  Text(
                    plan.description,
                    style: tokens.typeScale.bodyMedium.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${plan.price}',
                  style: tokens.typeScale.h4.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isYearly)
                  Text(
                    '月額¥${(plan.price / 12).round()}',
                    style: tokens.typeScale.bodySmall.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      final subscriptionManager = ref.read(subscriptionManagerProvider);
      final selectedPlan = SubscriptionManager.availablePlans
          .where((plan) => plan.id.contains('premium'))
          .toList()[_selectedPlanIndex];
      
      final success = await subscriptionManager.startSubscription(selectedPlan.id);
      
      if (success && mounted) {
        // サブスクリプション状態を更新
        ref.invalidate(subscriptionStatusProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プレミアムプランを開始しました！'),
            backgroundColor: Colors.green,
          ),
        );
        
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('購入に失敗しました。もう一度お試しください。'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    try {
      final subscriptionManager = ref.read(subscriptionManagerProvider);
      await subscriptionManager.restoreSubscriptions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('購入を復元しました'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('復元に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}