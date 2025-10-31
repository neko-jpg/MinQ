import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// カスタムバックボタンディスパッチャー
/// F009対応: Androidバックボタンの適切な制御を実装
class MinqBackButtonDispatcher extends RootBackButtonDispatcher {
  MinqBackButtonDispatcher._();
  
  static final MinqBackButtonDispatcher _instance = MinqBackButtonDispatcher._();
  static MinqBackButtonDispatcher get instance => _instance;

  /// 現在のコンテキスト（アプリのルートから設定）
  BuildContext? _context;
  
  /// 最後にバックボタンが押された時刻
  DateTime? _lastBackPress;
  
  /// バックボタンの連続押下を検知する間隔
  static const Duration _backPressThreshold = Duration(seconds: 2);

  /// コンテキストを設定
  void setContext(BuildContext context) {
    _context = context;
  }

  @override
  Future<bool> didPopRoute() async {
    final context = _context;
    if (context == null || !context.mounted) {
      return false;
    }

    final router = GoRouter.of(context);
    
    // 現在のルートを取得
    final routerState = GoRouterState.of(context);
    final currentLocation = routerState.uri.toString();
    
    // ルーターがポップできる場合は通常のポップを実行
    if (router.canPop()) {
      router.pop();
      return true;
    }
    
    // タブ画面以外の場合はホームに戻る
    if (!_isTabRoute(currentLocation)) {
      router.go('/');
      return true;
    }
    
    // ホーム画面の場合は二回押しでアプリ終了
    if (currentLocation == '/') {
      return _handleHomeBackPress(context);
    }
    
    // その他のタブ画面の場合はホームに戻る
    router.go('/');
    return true;
  }

  /// タブルートかどうかを判定
  bool _isTabRoute(String location) {
    const tabRoutes = ['/', '/stats', '/challenges', '/profile'];
    return tabRoutes.contains(location);
  }

  /// ホーム画面でのバックボタン処理
  Future<bool> _handleHomeBackPress(BuildContext context) async {
    final now = DateTime.now();
    
    if (_lastBackPress == null || 
        now.difference(_lastBackPress!) > _backPressThreshold) {
      _lastBackPress = now;
      
      // スナックバーで終了の確認を表示
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('もう一度押すとアプリを終了します'),
              duration: Duration(seconds: 2),
            ),
          );
      }
      return true; // バックを無効化
    }
    
    // 二回目の押下でアプリ終了
    return false; // システムにバック処理を委ねる
  }

  // RootBackButtonDispatcherの基本実装を使用
}