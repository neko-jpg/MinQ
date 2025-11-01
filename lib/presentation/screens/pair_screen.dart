import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/pair/pair.dart';

// Temporary provider for user pair functionality
final userPairProvider = FutureProvider<Pair?>((ref) async {
  // TODO: Replace with real implementation backed by repository data
  return null;
});

class PairScreen extends ConsumerWidget {
  const PairScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ペア機能')),
      body: const Center(child: Text('ペア機能は準備中です')),
    );
  }
}
