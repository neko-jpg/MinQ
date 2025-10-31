Finding F012 — オフライン検知プロバイダーの欠如

Severity: P2

Area: Offline

Files: lib/presentation/widgets/offline_banner.dart, lib/presentation/widgets/network_dependent_widget.dart 他

Symptom (現象): オフラインバナーやNetworkDependentWidgetで// TODO: NetworkStatusServiceとコメントされているのみで、実際にネットワーク状態を監視してUIを切り替える処理が存在しない。そのため、オフライン時でもオンライン用の機能が表示されたままになる。
github.com

Likely Root Cause (推定原因): ネットワーク状況を検知するサービスの実装が後回しになっている。connectivity_plusなどの外部パッケージの導入が未決定だった可能性が高い。

Concrete Fix (修正案):

connectivity_plusまたはinternet_connection_checkerを利用してリアルタイムにネットワーク状態をストリーム提供するNetworkStatusServiceを実装する。

Riverpodプロバイダーを作成し、オフラインかどうかをConsumerWidgetから購読できるようにする。

OfflineBannerやNetworkDependentWidgetはこのプロバイダーを監視し、オフライン時にバナー表示や機能制限UIへ切り替える。showOfflineSnackBarもnetworkStatusProviderの状態に応じて呼び出す。

Tests (テスト): ウィジェットテストNetworkDependentWidget_displays_offline_variantでネットワーク状態をモックし、オンライン時とオフライン時のUI切り替えを検証する。統合テストで機内モード時に操作を行った場合にオフラインバナーが表示されることを確認する。

Impact/Effort/Confidence: I=4, E=2 days, C=4

Patch (≤30 lines, unified diff if possible):

実装例（抜粋）：

final networkStatusProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final connectivity = Connectivity();
  await for (final status in connectivity.onConnectivityChanged) {
    yield status != ConnectivityResult.none;
  }
});

// OfflineBanner
Widget build(BuildContext context, WidgetRef ref) {
  final isOnline = ref.watch(networkStatusProvider).maybeWhen(data: (v) => v, orElse: () => true);
  if (!isOnline) return _buildOfflineBanner(context);
  return const SizedBox.shrink();
}