# MinQ Development Roadmap (Comprehensive Plan)

This document outlines the step-by-step execution plan to clear all items in `tasks.md` and achieve the goal of 1 Million Downloads.

---

## Sprint 1: Foundation & Quality (Phase 1) 🏗️
**Focus:** Technical Debt, UI Consistency, Architecture.
**Goal:** Ensure the app is stable, maintainable, and looks professional.

### Step 1.1: UI Modernization
- [ ] **Home Screen Refactor:**
    - Rewrite `home_screen_v2.dart` using `MinqTheme` tokens (Spacing, Typography, Colors).
    - Extract all Japanese strings to `lib/l10n/app_ja.arb`.
    - Implement `AsyncValue` handling (Loading/Error states) for all data sections.
- [ ] **Quest Creation Screen Refactor:**
    - Apply `MinqTheme` to `guided_quest_creation_screen.dart`.
    - Decouple UI from data (remove hardcoded templates).

### Step 1.2: Architectural Cleanup
- [ ] **Decompose `providers.dart`:**
    - Break down the monolithic file into:
        - `lib/core/providers/core_providers.dart` (Logger, Database, etc.)
        - `lib/features/home/providers/home_providers.dart`
        - `lib/features/quest/providers/quest_providers.dart`
- [ ] **Externalize Seed Data:**
    - Move `_templateSeedData` to `assets/data/initial_quests.json`.
    - Create `JsonAssetService` to load this data.

### Step 1.3: Application Layer Setup
- [ ] **Create Controllers:**
    - Implement `QuestController` to handle the complex logic of completing a quest (DB update + Gamification trigger).

---

## Sprint 2: The Core Loop (Phase 2) ⚙️
**Focus:** Making the "Habit Loop" work (Trigger -> Action -> Reward).
**Goal:** Users actually receive points and badges when they finish tasks.

### Step 2.1: Gamification Logic
- [ ] **Implement `GamificationEngine`:**
    - Code the `awardPoints` logic to be robust (offline support).
    - Implement `checkAndAwardBadges` logic (Streak checks).
- [ ] **Connect Home UI:**
    - Wire up the "Complete" button in Home Screen to the new `QuestController`.
    - Ensure UI updates instantly (optimistic update) while backend syncs.

### Step 2.2: Progress & Challenges
- [ ] **Visualization:**
    - Implement Streak calculation logic.
    - Connect the "Flame" icon on Home Screen to real data.

---

## Sprint 3: Growth Engines (Phase 3) 🚀
**Focus:** Viral Features & Retention.
**Goal:** Implement the "1M DL" features.

### Step 3.1: Viral Acquisition
- [ ] **Kizuna Pass (Invite System):**
    - Implement `InviteService` (Generate/Redeem codes).
    - Create UI for "Invite a Friend".
- [ ] **AI Habit DNA:**
    - Implement `HabitDNAAnalysisService` (Mock AI logic initially if needed).
    - Implement `OgpImageGenerator` update to include diagnosis results.

### Step 3.2: Social Retention
- [ ] **Resonance Streak:**
    - Update `PairRepository` to track combined streaks.
    - Implement "Lifeline" UI in the Pair screen.

---

## Sprint 4: Polish & Release (Phase 4 & 5) 📦
**Focus:** Production Readiness.

- [ ] **Notifications:** Finalize FCM integration.
- [ ] **Localization:** Full English/Japanese verification.
- [ ] **Store Prep:** Screenshots, Metadata.

---

## Execution Strategy
1.  **Sequential Execution:** We will follow the order Sprint 1 -> 2 -> 3 -> 4.
2.  **Check-ins:** After each Sprint, we will verify against `tasks.md` and mark items as done.
3.  **Quality Gate:** `flutter analyze` must pass before moving to the next Sprint.
