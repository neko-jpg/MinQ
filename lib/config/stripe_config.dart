import 'package:minq/data/services/remote_config_service.dart';

class StripeConfig {
  StripeConfig({required this.portalEndpoint, this.tipEndpoint});

  final Uri portalEndpoint;
  final Uri? tipEndpoint;

  bool get hasTipEndpoint => tipEndpoint != null;

  factory StripeConfig.fromRemoteConfig(RemoteConfigService remoteConfig) {
    final config = StripeConfig.maybeFromRemoteConfig(remoteConfig);
    if (config == null) {
      throw StateError('Stripe endpoints are not configured.');
    }
    if (!config.hasTipEndpoint) {
      throw StateError('Tip jar endpoint is not configured.');
    }
    return config;
  }

  static StripeConfig? maybeFromRemoteConfig(RemoteConfigService remoteConfig) {
    final portalUri = remoteConfig.tryGetUri('stripe_billing_portal_endpoint');
    if (portalUri == null) {
      return null;
    }

    final tipUri = remoteConfig.tryGetUri('tip_jar_endpoint');

    return StripeConfig(
      portalEndpoint: portalUri,
      tipEndpoint: tipUri,
    );
  }
}
