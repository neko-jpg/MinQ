// This file is kept for backward compatibility.
// It exports all providers from their new locations.

export 'package:minq/core/initialization/app_bootstrap_service.dart';
export 'package:minq/core/network/network_providers.dart';
export 'package:minq/core/providers/core_providers.dart';
export 'package:minq/features/auth/data/auth_providers.dart';
export 'package:minq/features/gamification/data/gamification_providers.dart';
export 'package:minq/features/quest/data/quest_providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/initialization/app_bootstrap_service.dart';

// Re-declare appStartupProvider to use the new service
final appStartupProvider = FutureProvider<void>((ref) async {
  await ref.read(appBootstrapServiceProvider).initialize();
});
