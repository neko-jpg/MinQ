import 'package:minq/data/services/remote_config_service.dart';

class StripeConfig {
  StripeConfig({required this.portalEndpoint});

  final Uri portalEndpoint;

  factory StripeConfig.fromRemoteConfig(RemoteConfigService remoteConfig) {
    final raw = remoteConfig.stripeBillingPortalEndpoint;
    if (raw.isEmpty) {
      throw StateError('Stripe billing portal endpoint is not configured.');
    }
    final uri = Uri.parse(raw);
    if (!uri.hasScheme) {
      throw FormatException('Invalid Stripe billing portal endpoint: $raw');
    }
    return StripeConfig(portalEndpoint: uri);
  }
}
