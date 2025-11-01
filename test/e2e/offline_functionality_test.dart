import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:minq/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Functionality E2E Tests', () {
    testWidgets('Complete offline quest management workflow', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // === SIMULATE GOING OFFLINE ===

      // Simulate network disconnection
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump();

      // Verify offline banner appears
      expect(find.byKey(const Key('offline_banner')), findsOneWidget);
      expect(find.text('You\'re offline'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);

      // === OFFLINE QUEST CREATION ===

      // Create quest while offline
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quest_creation_screen')), findsOneWidget);

      // Verify offline mode indicator in quest creation
      expect(find.byKey(const Key('offline_mode_indicator')), findsOneWidget);
      expect(
        find.text('Creating offline - will sync when connected'),
        findsOneWidget,
      );

      // Fill quest form
      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Offline Morning Routine',
      );
      await tester.enterText(
        find.byKey(const Key('quest_description_field')),
        'Complete morning routine while offline',
      );

      // Select category
      await tester.tap(find.byKey(const Key('category_dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Health'));
      await tester.pumpAndSettle();

      // Save quest offline
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Verify offline save confirmation
      expect(find.text('Quest saved offline'), findsOneWidget);
      expect(find.byKey(const Key('sync_pending_indicator')), findsOneWidget);

      // Verify quest appears in list with offline indicator
      expect(find.byKey(const Key('quest_list_screen')), findsOneWidget);
      expect(find.text('Offline Morning Routine'), findsOneWidget);
      expect(find.byKey(const Key('offline_quest_indicator')), findsOneWidget);

      // === OFFLINE QUEST COMPLETION ===

      // Complete quest while offline
      await tester.tap(find.text('Offline Morning Routine'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('quest_detail_screen')), findsOneWidget);

      // Verify offline completion options
      expect(
        find.byKey(const Key('offline_completion_notice')),
        findsOneWidget,
      );
      expect(find.text('Completion will be saved locally'), findsOneWidget);

      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();

      // Complete with check (no photo upload while offline)
      await tester.tap(find.byKey(const Key('proof_check_button')));
      await tester.pumpAndSettle();

      // Add completion note
      await tester.enterText(
        find.byKey(const Key('completion_note_field')),
        'Completed offline - great morning routine!',
      );

      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();

      // Verify offline XP gain
      expect(find.byKey(const Key('xp_gain_animation')), findsOneWidget);
      expect(find.text('+25 XP'), findsOneWidget);
      expect(find.text('(Offline)'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));

      // === OFFLINE QUEST EDITING ===

      // Create another quest to edit
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Evening Reading',
      );
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Edit quest while offline
      await tester.tap(find.text('Evening Reading'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('edit_quest_button')));
      await tester.pumpAndSettle();

      // Modify quest
      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Evening Reading (Updated Offline)',
      );
      await tester.enterText(
        find.byKey(const Key('quest_description_field')),
        'Read for 30 minutes before bed - updated while offline',
      );

      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Verify offline edit confirmation
      expect(find.text('Quest updated offline'), findsOneWidget);

      // === OFFLINE CHALLENGE PARTICIPATION ===

      // Navigate to challenges
      await tester.tap(find.byKey(const Key('challenges_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('challenges_screen')), findsOneWidget);

      // Verify offline challenge notice
      expect(
        find.byKey(const Key('offline_challenges_notice')),
        findsOneWidget,
      );
      expect(
        find.text('Challenge progress will sync when online'),
        findsOneWidget,
      );

      // Update challenge progress offline
      await tester.tap(find.text('7-Day Fitness Challenge'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('update_progress_button')));
      await tester.pumpAndSettle();

      // Verify offline progress update
      expect(find.text('Progress updated offline'), findsOneWidget);
      expect(
        find.byKey(const Key('offline_progress_indicator')),
        findsOneWidget,
      );

      // === OFFLINE AI COACH INTERACTION ===

      // Navigate to AI Coach
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('ai_coach_screen')), findsOneWidget);

      // Verify offline AI coach notice
      expect(find.byKey(const Key('offline_ai_notice')), findsOneWidget);
      expect(
        find.text('AI Coach is offline - showing cached responses'),
        findsOneWidget,
      );

      // Send message to offline AI coach
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'I need motivation',
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Verify offline fallback response
      expect(find.text('I\'m currently offline'), findsOneWidget);
      expect(find.text('Here are some general tips'), findsOneWidget);
      expect(
        find.byKey(const Key('offline_response_indicator')),
        findsOneWidget,
      );

      // === OFFLINE STATISTICS AND ANALYTICS ===

      // Navigate to statistics
      await tester.tap(find.byKey(const Key('stats_tab')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('stats_screen')), findsOneWidget);

      // Verify offline statistics notice
      expect(find.byKey(const Key('offline_stats_notice')), findsOneWidget);
      expect(
        find.text('Showing local data - will update when online'),
        findsOneWidget,
      );

      // Verify local statistics are displayed
      expect(find.text('2'), findsOneWidget); // Completed quests (offline)
      expect(find.text('50 XP'), findsOneWidget); // Total XP (offline)
      expect(find.text('Level 1'), findsOneWidget); // Current level

      // Verify offline data indicators
      expect(
        find.byKey(const Key('offline_data_indicator')),
        findsAtLeastNWidgets(3),
      );

      // === SYNC QUEUE MANAGEMENT ===

      // Navigate to sync status
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sync_status_tile')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sync_status_screen')), findsOneWidget);

      // Verify pending sync items
      expect(find.text('4 items pending sync'), findsOneWidget);
      expect(find.byKey(const Key('sync_queue_list')), findsOneWidget);

      // Verify sync queue items
      expect(
        find.text('Quest: Offline Morning Routine (Created)'),
        findsOneWidget,
      );
      expect(
        find.text('Quest: Offline Morning Routine (Completed)'),
        findsOneWidget,
      );
      expect(find.text('Quest: Evening Reading (Created)'), findsOneWidget);
      expect(find.text('Quest: Evening Reading (Updated)'), findsOneWidget);

      // === SIMULATE COMING BACK ONLINE ===

      // Simulate network reconnection
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump();

      // Verify offline banner disappears
      expect(find.byKey(const Key('offline_banner')), findsNothing);

      // Verify sync process starts
      expect(
        find.byKey(const Key('sync_in_progress_indicator')),
        findsOneWidget,
      );
      expect(find.text('Syncing offline changes...'), findsOneWidget);

      // Wait for sync to complete
      await tester.pump(const Duration(seconds: 5));

      // Verify sync completion
      expect(find.byKey(const Key('sync_complete_indicator')), findsOneWidget);
      expect(find.text('All changes synced successfully'), findsOneWidget);

      // === VERIFY SYNC RESULTS ===

      // Navigate back to quests
      await tester.tap(find.byKey(const Key('quests_tab')));
      await tester.pumpAndSettle();

      // Verify quests are now synced (no offline indicators)
      expect(find.text('Offline Morning Routine'), findsOneWidget);
      expect(find.text('Evening Reading (Updated Offline)'), findsOneWidget);
      expect(find.byKey(const Key('offline_quest_indicator')), findsNothing);
      expect(find.byKey(const Key('synced_quest_indicator')), findsNWidgets(2));

      // Verify completion status is maintained
      expect(
        find.byKey(const Key('completed_quest_indicator')),
        findsOneWidget,
      );

      // === VERIFY CHALLENGE SYNC ===

      // Check challenge progress sync
      await tester.tap(find.byKey(const Key('challenges_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('7-Day Fitness Challenge'));
      await tester.pumpAndSettle();

      // Verify progress was synced
      expect(
        find.byKey(const Key('synced_progress_indicator')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('offline_progress_indicator')), findsNothing);

      // === VERIFY XP AND STATISTICS SYNC ===

      // Check statistics sync
      await tester.tap(find.byKey(const Key('stats_tab')));
      await tester.pumpAndSettle();

      // Verify statistics are updated and synced
      expect(find.text('2'), findsOneWidget); // Completed quests
      expect(find.text('50 XP'), findsOneWidget); // Total XP
      expect(find.byKey(const Key('offline_data_indicator')), findsNothing);
      expect(
        find.byKey(const Key('synced_data_indicator')),
        findsAtLeastNWidgets(3),
      );

      // === VERIFY AI COACH ONLINE FUNCTIONALITY ===

      // Test AI coach online functionality
      await tester.tap(find.byKey(const Key('ai_coach_tab')));
      await tester.pumpAndSettle();

      // Verify online AI coach notice
      expect(find.byKey(const Key('online_ai_notice')), findsOneWidget);
      expect(find.text('AI Coach is back online!'), findsOneWidget);

      // Send message to online AI coach
      await tester.enterText(
        find.byKey(const Key('ai_chat_input')),
        'I completed quests while offline',
      );
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle();

      // Wait for online AI response
      await tester.pump(const Duration(seconds: 2));

      // Verify contextual online response
      expect(
        find.text('Great job staying productive while offline!'),
        findsOneWidget,
      );
      expect(find.text('I see you completed'), findsOneWidget);

      // === FINAL VERIFICATION ===

      // Verify complete offline-to-online workflow success
      expect(
        find.byKey(const Key('offline_sync_complete_indicator')),
        findsOneWidget,
      );

      // Check sync status one more time
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sync_status_tile')));
      await tester.pumpAndSettle();

      // Verify no pending sync items
      expect(find.text('All data synced'), findsOneWidget);
      expect(find.text('0 items pending sync'), findsOneWidget);
      expect(find.byKey(const Key('sync_queue_empty')), findsOneWidget);
    });

    testWidgets('Offline data persistence across app restarts', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // === SIMULATE OFFLINE STATE ===

      // Go offline
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump();

      // Create quest offline
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Persistent Offline Quest',
      );
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Complete quest offline
      await tester.tap(find.text('Persistent Offline Quest'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('proof_check_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('confirm_completion_button')));
      await tester.pumpAndSettle();

      // Wait for offline completion
      await tester.pump(const Duration(seconds: 3));

      // === SIMULATE APP RESTART ===

      // Restart app while still offline
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // Verify offline state is restored
      expect(find.byKey(const Key('offline_banner')), findsOneWidget);

      // Verify offline quest persisted
      expect(find.text('Persistent Offline Quest'), findsOneWidget);
      expect(
        find.byKey(const Key('completed_quest_indicator')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('offline_quest_indicator')), findsOneWidget);

      // Verify offline XP persisted
      await tester.tap(find.byKey(const Key('stats_tab')));
      await tester.pumpAndSettle();

      expect(find.text('25 XP'), findsOneWidget);
      expect(
        find.byKey(const Key('offline_data_indicator')),
        findsAtLeastNWidgets(1),
      );

      // Verify sync queue persisted
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sync_status_tile')));
      await tester.pumpAndSettle();

      expect(find.text('2 items pending sync'), findsOneWidget);
      expect(
        find.text('Quest: Persistent Offline Quest (Created)'),
        findsOneWidget,
      );
      expect(
        find.text('Quest: Persistent Offline Quest (Completed)'),
        findsOneWidget,
      );

      // === COME BACK ONLINE AFTER RESTART ===

      // Simulate network reconnection
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump();

      // Wait for sync
      await tester.pump(const Duration(seconds: 5));

      // Verify sync completed after restart
      expect(find.text('All data synced'), findsOneWidget);
      expect(find.text('0 items pending sync'), findsOneWidget);

      // Verify data integrity maintained
      await tester.tap(find.byKey(const Key('quests_tab')));
      await tester.pumpAndSettle();

      expect(find.text('Persistent Offline Quest'), findsOneWidget);
      expect(
        find.byKey(const Key('completed_quest_indicator')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('synced_quest_indicator')), findsOneWidget);
    });

    testWidgets('Offline conflict resolution workflow', (tester) async {
      await tester.pumpWidget(app.MinQApp(skipOnboarding: true));
      await tester.pumpAndSettle();

      // === SETUP CONFLICT SCENARIO ===

      // Create quest online first
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Conflict Test Quest',
      );
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Wait for online save
      await tester.pump(const Duration(seconds: 1));

      // Go offline
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump();

      // Edit quest offline
      await tester.tap(find.text('Conflict Test Quest'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('edit_quest_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Conflict Test Quest (Offline Edit)',
      );
      await tester.enterText(
        find.byKey(const Key('quest_description_field')),
        'This was edited while offline',
      );

      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // === SIMULATE REMOTE CHANGES ===

      // Simulate that the quest was also edited remotely while offline
      // This would normally happen through server-side changes

      // Come back online
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump();

      // Wait for sync attempt
      await tester.pump(const Duration(seconds: 3));

      // === CONFLICT RESOLUTION ===

      // Verify conflict detection dialog
      expect(find.byKey(const Key('sync_conflict_dialog')), findsOneWidget);
      expect(find.text('Sync Conflict Detected'), findsOneWidget);
      expect(
        find.text('This quest was modified both locally and remotely'),
        findsOneWidget,
      );

      // Show local version
      expect(find.text('Local Version:'), findsOneWidget);
      expect(find.text('Conflict Test Quest (Offline Edit)'), findsOneWidget);
      expect(find.text('This was edited while offline'), findsOneWidget);

      // Show remote version
      expect(find.text('Remote Version:'), findsOneWidget);
      expect(find.text('Conflict Test Quest (Remote Edit)'), findsOneWidget);
      expect(find.text('This was edited on another device'), findsOneWidget);

      // Verify resolution options
      expect(find.byKey(const Key('use_local_button')), findsOneWidget);
      expect(find.byKey(const Key('use_remote_button')), findsOneWidget);
      expect(find.byKey(const Key('merge_changes_button')), findsOneWidget);

      // Choose to use local version
      await tester.tap(find.byKey(const Key('use_local_button')));
      await tester.pumpAndSettle();

      // Verify conflict resolved
      expect(find.byKey(const Key('sync_conflict_dialog')), findsNothing);
      expect(
        find.text('Conflict resolved - using local version'),
        findsOneWidget,
      );

      // Verify quest shows local version
      expect(find.text('Conflict Test Quest (Offline Edit)'), findsOneWidget);

      // === TEST MERGE OPTION ===

      // Create another conflict scenario for merge testing
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Merge Test Quest',
      );
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Go offline and edit
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump();

      await tester.tap(find.text('Merge Test Quest'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('edit_quest_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('quest_description_field')),
        'Local description added offline',
      );

      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Come back online (simulate remote changes)
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump();

      await tester.pump(const Duration(seconds: 3));

      // Resolve with merge
      expect(find.byKey(const Key('sync_conflict_dialog')), findsOneWidget);

      await tester.tap(find.byKey(const Key('merge_changes_button')));
      await tester.pumpAndSettle();

      // Verify merge editor
      expect(find.byKey(const Key('merge_editor_screen')), findsOneWidget);
      expect(find.text('Merge Changes'), findsOneWidget);

      // Verify both changes are shown
      expect(find.text('Local description added offline'), findsOneWidget);
      expect(find.text('Remote category changed to fitness'), findsOneWidget);

      // Accept merge
      await tester.tap(find.byKey(const Key('accept_merge_button')));
      await tester.pumpAndSettle();

      // Verify merge completed
      expect(find.text('Changes merged successfully'), findsOneWidget);

      // === VERIFY CONFLICT RESOLUTION HISTORY ===

      // Check conflict resolution history
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('sync_status_tile')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('conflict_history_tab')));
      await tester.pumpAndSettle();

      // Verify conflict history is recorded
      expect(find.text('2 conflicts resolved'), findsOneWidget);
      expect(
        find.text('Conflict Test Quest - Used local version'),
        findsOneWidget,
      );
      expect(find.text('Merge Test Quest - Merged changes'), findsOneWidget);
    });
  });
}
