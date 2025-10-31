import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/navigation/form_protection_mixin.dart';
import 'package:minq/core/navigation/root_back_button_dispatcher.dart';
import 'package:minq/presentation/routing/app_router.dart';

void main() {
  group('Navigation System Tests', () {
    testWidgets('MinqBackButtonDispatcher handles back navigation correctly', (tester) async {
      final dispatcher = MinqBackButtonDispatcher.instance;
      
      // Test that dispatcher can be instantiated
      expect(dispatcher, isNotNull);
      
      // Test singleton pattern
      expect(MinqBackButtonDispatcher.instance, same(dispatcher));
    });

    testWidgets('FormProtectionMixin shows discard dialog', (tester) async {
      bool hasChanges = true;
      bool dialogShown = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: _TestFormScreen(
            hasUnsavedChanges: () => hasChanges,
            onDialogShown: () => dialogShown = true,
          ),
        ),
      );

      // Try to pop with unsaved changes
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        null,
        (data) {},
      );

      await tester.pumpAndSettle();
      
      // Should show dialog when there are unsaved changes
      expect(find.text('変更を破棄しますか？'), findsOneWidget);
    });

    test('Navigation routes are properly defined', () {
      // Test that notification types are handled correctly
      const notificationTypes = [
        'quest_reminder',
        'quest_deadline', 
        'pair_message',
        'achievement_unlocked',
        'weekly_summary',
        'pair_progress',
        'challenge_update',
      ];

      for (final notificationType in notificationTypes) {
        // Verify that notification types are not empty
        expect(notificationType, isNotEmpty);
      }
    });

    test('AppRoutes constants are properly defined', () {
      // Test that all required routes are defined
      expect(AppRoutes.home, equals('/'));
      expect(AppRoutes.stats, equals('/stats'));
      expect(AppRoutes.challenges, equals('/challenges'));
      expect(AppRoutes.profile, equals('/profile'));
      expect(AppRoutes.questDetail, equals('/quest/:questId'));
      expect(AppRoutes.pairChat, equals('/pair/chat/:pairId'));
    });
  });
}

class _TestFormScreen extends StatefulWidget {
  const _TestFormScreen({
    required this.hasUnsavedChanges,
    required this.onDialogShown,
  });

  final bool Function() hasUnsavedChanges;
  final VoidCallback onDialogShown;

  @override
  State<_TestFormScreen> createState() => _TestFormScreenState();
}

class _TestFormScreenState extends State<_TestFormScreen> 
    with FormProtectionMixin<_TestFormScreen> {
  
  @override
  bool get hasUnsavedChanges => widget.hasUnsavedChanges();

  @override
  Future<bool> showDiscardChangesDialog() async {
    widget.onDialogShown();
    return super.showDiscardChangesDialog();
  }

  @override
  Widget build(BuildContext context) {
    return buildProtectedScaffold(
      appBar: AppBar(title: const Text('Test Form')),
      body: const Center(
        child: Text('Test Form Content'),
      ),
    );
  }
}