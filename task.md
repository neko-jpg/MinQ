# MinQ Enhancement 2025 - Implementation Phase

## Overview
This task list outlines the concrete implementation steps required to bring the scaffolded features of the MinQ Enhancement 2025 plan to life. Each item corresponds to a `TODO` left in the codebase during the initial scaffolding phase.

---

## Phase 1: Core Service Implementation

### 1.1 Gamification Engine (`lib/core/gamification/gamification_engine.dart`)
- [x] Implement badge awarding logic based on user progress (streaks, milestones, etc.).
- [x] Implement rank calculation logic based on user's total points.

### 1.2 Reward System (`lib/core/gamification/reward_system.dart`)
- [x] Implement logic to fetch the reward catalog from Firestore.
- [x] Implement the full reward redemption flow:
  - [x] Check if user has enough points.
  - [x] Deduct points from user.
  - [x] Add reward to user's inventory.
  - [x] Handle potential transaction failures.
- [x] Implement the variable reward generation logic with rarity tiers.

### 1.3 Challenge Service (`lib/core/challenges/challenge_service.dart`)
- [x] Implement logic to create and store daily challenge instances.
- [x] Implement logic to create and store weekly challenge instances.
- [x] Implement logic to fetch challenge progress from Firestore.
- [x] Implement logic to update challenge progress in Firestore.
- [x] Implement challenge completion flow:
  - [x] Mark challenge as complete.
  - [x] Award points and/or badges using the `GamificationEngine`.

### 1.4 Event Manager (`lib/core/challenges/event_manager.dart`)
- [x] Implement logic to save new events to Firestore.
- [x] Implement logic to query for currently active events.
- [x] Implement logic to register a user for an event.

### 1.5 Progress Visualization Service (`lib/core/progress/progress_visualization_service.dart`)
- [x] Implement streak calculation logic by analyzing `quest_logs`.
- [x] Implement milestone detection logic (e.g., 7, 30, 100-day streaks).
- [x] Implement streak-at-risk detection logic.

---

## Phase 2: AI & Health Integration

### 2.1 Gemma AI Service (`lib/core/ai/gemma_ai_service.dart`)
- [x] Implement logic to download and manage the Gemma model file.
- [x] Implement the actual text generation call to the Gemma model with proper error handling.

### 2.2 Health Sync Service (`lib/core/health/health_sync_service.dart`)
- [x] Implement quest auto-updating logic based on fetched health data:
  - [x] Map health data types to quest types.
  - [x] Check if health data meets quest completion thresholds.
  - [x] Mark corresponding quests as complete.

---

## Phase 3: Revolutionary Features Implementation

### 3.1 Mood Tracking Service (`lib/core/mood/mood_tracking_service.dart`)
- [x] Implement logic to save `MoodState` objects to the `moodLogs` collection in Firestore.
- [x] Implement mood-habit correlation analysis:
  - [x] Fetch user's mood logs.
  - [x] Fetch user's quest completion logs.
  - [x] Calculate and store correlation scores.

### 3.2 Habit DNA Service (`lib/core/habit_dna/habit_dna_service.dart`)
- [x] Implement the full archetype determination algorithm by analyzing user behavior patterns.
- [x] Implement logic to return personalized, actionable strategies based on a user's archetype.

### 3.3 Micro-Commitment Service (`lib/core/micro_commitment/micro_commitment_service.dart`)
- [x] Implement logic to create and save quests with a "micro" flag.
- [x] Implement logic to analyze micro-quest consistency and suggest expansion.
- [x] Implement the UI trigger to offer a micro-quest as a fallback for a failed regular quest.

### 3.4 Reverse Accountability Service (`lib/core/pair/reverse_accountability_service.dart`)
- [x] Implement the logic to send a push notification to a user's pair upon quest completion.
- [x] Implement the "resonance bonus" logic: check if both pair members have completed daily quests and award a bonus.
- [x] Implement the UI trigger to prompt a user to send a supportive message to a struggling partner.

### 3.5 Time Capsule Service (`lib/core/time_capsule/time_capsule_service.dart`)
- [x] Implement logic to save a new `TimeCapsule` to Firestore.
- [x] Implement logic to schedule a push notification for the capsule's delivery date.
- [x] Implement the server-side or background function to trigger the `deliverTimeCapsule` method.
- [x] Implement the logic to generate a formatted reflection string comparing past and present self.

### 3.6 Ecosystem Mapping Service (`lib/core/ecosystem/ecosystem_mapping_service.dart`)
- [x] Implement the full ecosystem analysis logic to find and store correlations between habits.
- [x] Implement the keystone habit identification algorithm.
- [x] Implement logic to generate and return contextual optimization suggestions based on the ecosystem map.

---

## Phase 4: UI & UX Implementation

### 4.1 Conversation Starter Widget (`lib/features/pair/presentation/widgets/conversation_starter_widget.dart`)
- [x] Implement logic to fetch conversation starter prompts from a service or remote config.
- [x] Implement the logic to send the selected prompt to the pair chat.

### 4.2 Sticker Picker Widget (`lib/features/pair/presentation/widgets/sticker_picker_widget.dart`)
- [x] Implement logic to fetch sticker packs from a service or asset bundle.
- [x] Implement the logic to send the selected sticker to the pair chat.

### 4.3 Home Screen V2 (`lib/features/home/presentation/screens/home_screen_v2.dart`)
- [x] Connect the AI Encouragement card to the `GemmaAIService`.
- [x] Connect the Streak & Progress section to the `ProgressVisualizationService`.
- [x] Implement the one-tap quest completion logic in the Today's Quests section.
- [x] Connect the Active Challenges section to the `ChallengeService`.

### 4.4 Quest Recommendation Widget (`lib/features/recommendations/presentation/widgets/quest_recommendation_widget.dart`)
- [x] Implement logic to fetch quest recommendations from the appropriate service.
- [x] Implement the logic to add a recommended quest to the user's quest list.

### 4.5 Theme Selection Screen (`lib/features/settings/presentation/screens/theme_selection_screen.dart`)
- [x] Implement logic to persist the selected theme color to user preferences.
- [x] Connect the `selectedColorProvider` to a proper theme management service.

### 4.6 Guided Quest Creation Screen (`lib/features/onboarding/presentation/screens/guided_quest_creation_screen.dart`)
- [x] Implement logic to fetch quest templates from a service.
- [x] Implement navigation to a pre-filled quest creation form.
- [x] Implement navigation to the regular, non-templated quest creation screen.

### 4.7 Voice Input Widget (`lib/features/home/presentation/widgets/voice_input_widget.dart`)
- [x] Implement the logic to parse the recognized speech and complete the corresponding quest.

### 4.8 Pause Mode Screen (`lib/features/settings/presentation/screens/pause_mode_screen.dart`)
- [x] Implement logic to persist the pause mode setting and update the backend state accordingly.

---

## Phase 5: Miscellaneous & Refinements

- [x] **Push Notifications:** Implement a push notification service (e.g., Firebase Cloud Messaging) and integrate it with the `ReEngagementService`, `ReverseAccountabilityService`, and `TimeCapsuleService`.
- [x] **Sentry Integration:** Implement the actual calls to the Sentry service for error and performance monitoring.
- [x] **Fix Integrations:** Resolve the `miinq_integrations` package path issue and integrate its services.
- [x] **Localization:** Implement the actual localization logic in `i18n/formatters.dart`.
- [x] **Age Verification:** Implement email sending for parental consent in `AgeVerificationService`.
- [x] **In-App Purchases:** Implement the actual purchase, restore, and cancellation flows in `MonetizationService` and `SubscriptionService`.
- [x] **In-App Updates & Reviews:** Implement the native platform integrations for in-app updates and reviews.
- [x] **Data Export:** Implement PDF generation and export functionality.