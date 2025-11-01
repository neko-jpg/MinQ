import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Temporary provider for user pair functionality
final userPairProvider = FutureProvider<List<String>>((ref) async {
  // Return empty list for now - this should be implemented properly
  return <String>[];
});

class PairScreen extends ConsumerWidget {
  const PairScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ペア機能'),
      ),
      body: const Center(
        child: Text('ペア機能は準備中です'),
      ),
    );
  }
}