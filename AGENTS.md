# AGENTS.md

This file defines the **governing laws** for all AI agents and developers working on the MinQ repository. Adherence to these guidelines is mandatory to ensure code quality, scalability, and stability.

## 1. Project Overview & Philosophy
*   **Identity:** MinQ is a "3-tap habit formation app" focusing on simplicity, anonymity, and psychological depth (Habit DNA).
*   **Core Value:** Simplicity for the user, Robustness in the backend.
*   **Language:**
    *   **Code:** English (Class names, variables, methods).
    *   **Comments/Docs:** Japanese (Preferred for complex logic explanations).
    *   **Filenames:** English (snake_case). **NEVER use non-ASCII characters in filenames** (Environment Constraint).

## 2. Architecture: "Feature-First" with Riverpod
The codebase is transitioning to a **Feature-First** architecture. New code MUST follow this structure.

### Directory Structure
```
lib/
├── core/                  # Global utilities, theme, initialization
├── domain/                # Pure entities, business rules (No Flutter UI, No Data Impl)
├── data/                  # Repositories (Impl), Data Sources (API/DB)
│   ├── repositories/
│   │   ├── interfaces/    # Repository Interfaces (e.g., i_quest_repository.dart)
│   │   └── ...            # Concrete Implementations
├── features/              # Feature-Specific Code
│   ├── [feature_name]/    # e.g., 'quest', 'pair', 'onboarding'
│   │   ├── presentation/  # Widgets, Screens, Controllers
│   │   ├── providers/     # Feature-specific Riverpod providers
│   │   └── ...
└── l10n/                  # Localization (.arb files)
```

### Layer Rules
1.  **Domain Layer:** MUST NOT import `presentation` or `data` (except for interfaces defined in domain, if any).
2.  **Data Layer:** Depends on `domain`. Implements interfaces.
3.  **Presentation Layer:** Depends on `domain` and `providers`. MUST NOT interact with `data` (Repositories) directly; use Providers/Controllers.

## 3. State Management (Riverpod)
*   **Providers:** Use `riverpod_generator` (@riverpod) or `StateNotifierProvider` / `AsyncNotifierProvider` for complex state.
*   **Avoid:** `StateProvider` for complex business logic.
*   **Naming:** Suffix providers with `Provider` (e.g., `questListProvider`).
*   **Access:** Use `ref.watch` in `build()` and `ref.read` in callbacks.

## 4. Coding Standards & Best Practices

### A. Dependencies (Strict)
*   **Versioning:** **NEVER** use `any` in `pubspec.yaml`. All dependencies must be pinned to a specific version (e.g., `^1.2.3`) to prevent build rot.
*   **New Packages:** Do not add heavy dependencies without strong justification.

### B. Linting & Quality
*   **Linter:** The project uses strict `flutter_lints`.
*   **Prints:** **NO `print()` statements**. Use `AppLogger` (`lib/core/logging/app_logger.dart`) for logging.
    *   `AppLogger().info(...)`
    *   `AppLogger().error(...)`
*   **Unused Code:** Remove unused imports and variables immediately.
*   **To-Dos:** Use `// TODO: ` comments for technical debt, but do not leave commented-out code blocks (delete them).

### C. Data Models
*   **Immutability:** Use `freezed` for all Domain Entities and State classes.
*   **Serialization:** Use `json_serializable` (via freezed) for JSON parsing.

### D. Async & Performance
*   **UI Safety:** Check `mounted` or store `context` appropriately before using `BuildContext` across async gaps.
*   **Streams:** Always manage stream subscriptions (use `StreamBuilder` or Riverpod's `StreamProvider`).

## 5. Testing Strategy
*   **Unit Tests:** Required for all **Repositories** (Mocking Data Source) and **StateNotifiers** (Logic).
*   **Widget Tests:** Required for complex UI interactions.
*   **Command:** `flutter test` should always pass before submission.

## 6. Git & Version Control
*   **Commit Messages:** Follow Conventional Commits (`feat:`, `fix:`, `docs:`, `refactor:`).
*   **Scope:** Keep commits small and atomic.

## 7. Specific Known Issues (Memory)
*   **Legacy Code:** Some older UI components in `lib/presentation` (not `lib/features`) may still need migration to the Feature-First structure.

## 8. Command Reference
*   **Generate Code:** `flutter pub run build_runner build --delete-conflicting-outputs`
*   **Analyze:** `flutter analyze`
*   **Test:** `flutter test`
