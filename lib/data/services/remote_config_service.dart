import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/config/feature_flags.dart';

/// A Riverpod [StateNotifier] that exposes the current [FeatureFlags].
class FeatureFlagsNotifier extends StateNotifier<FeatureFlags> {
  FeatureFlagsNotifier(this._remoteConfig) : super(const FeatureFlags());

  final FirebaseRemoteConfig? _remoteConfig;
  StreamSubscription<RemoteConfigUpdate>? _updateSubscription;
  bool _initialised = false;

  /// Fetches the latest configuration and starts listening for updates.
  Future<void> ensureLoaded() async {
    if (_initialised) {
      return;
    }
    _initialised = true;

    if (_remoteConfig == null) {
      return;
    }

    await _remoteConfig!.setDefaults(FeatureFlags.defaults());
    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(hours: 1),
    ));

    await _fetchAndActivate();

    _updateSubscription = _remoteConfig!.onConfigUpdated.listen((_) async {
      await _remoteConfig!.activate();
      _updateFromRemoteConfig();
    });
  }

  Future<void> _fetchAndActivate() async {
    try {
      await _remoteConfig!.fetchAndActivate();
    } catch (error, stackTrace) {
      debugPrint('Remote Config fetch failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      await _remoteConfig!.activate();
    } finally {
      _updateFromRemoteConfig();
    }
  }

  void _updateFromRemoteConfig() {
    if (_remoteConfig == null) {
      return;
    }
    state = FeatureFlags.fromRemoteConfig(_remoteConfig!);
  }

  @override
  void dispose() {
    _updateSubscription?.cancel();
    super.dispose();
  }
}
