# Implementation Plan

Convert the feature design into a series of prompts for a code-generation LLM that will implement each step with incremental progress. Make sure that each prompt builds on the previous prompts, and ends with wiring things together. There should be no hanging or orphaned code that isn't integrated into a previous step. Focus ONLY on tasks that involve writing, modifying, or testing code.

- [x] 1. Remove Gemma AI remnants and establish clean foundation





  - Remove all references to gemma_ai_provider.dart and gemma_ai_service.dart from the codebase
  - Update main.dart to remove Gemma AI imports and provider registrations
  - Clean up any remaining Gemma AI references in other service files
  - Verify no "gemma" strings remain in active code files
  - Run `flutter analyze` to check for any compilation errors
  - Execute `flutter test` to ensure no existing tests are broken
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 2. Implement TensorFlow Lite AI service integration





  - Create new TensorFlow Lite AI service to replace Gemma AI functionality
  - Implement local AI processing for habit insights and recommendations
  - Add proper error handling and fallback mechanisms for AI operations
  - Integrate the new AI service with existing AI-dependent features
  - Run `flutter analyze` to verify no static analysis issues
  - Execute `flutter test` to run all tests including new AI service tests
  - Write and execute unit tests for the new AI service
  - Test AI service integration with mock data
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

- [x] 3. Create comprehensive error handling and logging system





  - Implement custom exception hierarchy (MinqException, AIServiceException, DatabaseException, NetworkException)
  - Replace all print statements with secure logging using proper logging libraries
  - Add retry mechanisms with exponential backoff for network operations
  - Implement graceful error recovery strategies throughout the app
  - Run `flutter analyze` to check for any static analysis warnings
  - Execute `flutter test` to run all tests including error handling tests
  - Write unit tests for custom exception classes and error handling
  - Test retry mechanisms and logging functionality
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [　] 4. Establish design token system and theme consistency



  - Create comprehensive MinqDesignTokens class with colors, typography, spacing, radius, and elevation
  - Update all UI components to use design tokens instead of hardcoded values
  - Implement proper light/dark mode support with WCAG AA contrast ratios
  - Ensure consistent theme application across all screens and components
  - Run `flutter analyze` to verify no compilation issues with theme changes
  - Execute `flutter test` to run all tests including theme-related tests
  - Test theme switching functionality and color contrast ratios
  - Verify all UI components render correctly with new design tokens
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 16.1, 16.2, 16.3, 16.4, 16.5_
-

- [x] 5. Redesign bottom navigation from 6 tabs to 4 tabs




  - Modify shell_screen.dart to reduce navigation items from 6 to 4 (Home, Progress, Challenges, Profile)
  - Update navigation routing to handle the new 4-tab structure
  - Move Settings functionality to Profile screen with hamburger menu
  - Ensure all features remain accessible within 2 taps from main navigation
  - Update navigation icons and labels for better accessibility (minimum 44pt touch targets)
  - Run `flutter analyze` to check for navigation-related issues
  - Execute `flutter test` to run all tests including navigation tests
  - Test all navigation flows and ensure no broken routes
  - Verify touch targets meet accessibility requirements
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 20.1, 20.2, 20.3, 20.4, 20.5_


- [x] 6. Implement enhanced splash screen with organic growth animation


  - Create new OrganicSplashScreen with 4-stage growth animation (seed → sprout → leaf → full icon)
  - Implement performance-optimized animation system with hardware acceleration
  - Add adaptive animation complexity based on device capabilities
  - Integrate real initialization progress with animation timing (1.5-2.0 seconds)
  - Remove crash recovery dialog and implement silent background recovery
  - Run `flutter analyze` to verify animation code quality
  - Execute `flutter test` to run all tests including animation tests
  - Test splash screen performance on different device configurations
  - Measure and verify startup time is within 1.5-2.0 second target
  - Test animation smoothness and memory usage
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 8.1, 8.2, 8.3, 8.4, 8.5, 11.1, 11.2, 11.3, 11.4, 11.5, 19.1, 19.2, 19.3, 19.4, 19.5_

- [ ] 7. Redesign settings screen and implement profile management

  - Reorganize settings screen with clear sections and larger buttons (minimum 44pt touch targets)
  - Create comprehensive profile management system with tag management and goal setting
  - Implement AI coach preferences (speed, personality customization)
  - Add theme toggle (light/dark mode) with prominent placement
  - Move advanced settings to hamburger menu structure
  - Run `flutter analyze` to check for UI-related static analysis issues
  - Execute `flutter test` to run all tests including settings and profile tests
  - Test all settings functionality and profile management features
  - Verify button sizes meet accessibility requirements
  - Test theme switching and preference persistence
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 8. Transform AI Concierge from chat to data insights dashboard





  - Remove chat-based AI interaction components
  - Create new AI insights dashboard with habit analytics and trends
  - Implement personalized recommendations based on actual user data
  - Add progress visualization and failure prediction alerts
  - Integrate real-time data updates for dashboard insights
  - Run `flutter analyze` to verify dashboard implementation
  - Execute `flutter test` to run all tests including dashboard tests
  - Test dashboard with real and mock user data
  - Verify data visualization components render correctly
  - Test real-time updates and recommendation accuracy
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
-

- [x] 9. Optimize database performance and fix memory leaks




  - Implement proper Isar database lifecycle management with dispose methods
  - Add database initialization progress feedback for UI
  - Optimize Firestore operations with proper retry logic and conflict resolution
  - Remove unused database schemas to reduce storage overhead
  - Implement proper connection cleanup to prevent memory leaks
  - Run `flutter analyze` to check for database-related issues
  - Execute `flutter test` to run all tests including database tests
  - Test database operations and verify proper cleanup
  - Monitor memory usage and check for leaks
  - Test retry logic and error handling for database operations
  - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_



- [x] 10. Fix layout issues and implement responsive design










  - Resolve all bottom overflow and RenderFlex errors across screens
  - Implement proper scrolling and responsive layouts for content that exceeds screen boundaries
  - Fix conflicts with system UI elements (navigation buttons, status bar)
  - Ensure proper layout in both portrait and landscape orientations
  - Add proper constraints and flexible layouts where needed
  - Run `flutter analyze` to identify any remaining layout warnings
  - Execute `flutter test` to run all tests including layout tests
  - Test all screens for overflow issues and responsive behavior
  - Verify layouts work correctly in both orientations
  - Test on different screen sizes and resolutions
  - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5_

- [x] 11. Implement comprehensive internationalization (i18n)




  - Extract all hardcoded Japanese strings to .arb files
  - Set up flutter_localizations and intl package integration
  - Create localized strings for all UI text, error messages, and AI responses
  - Implement language switching functionality without app restart
  - Add support for RTL languages and cultural adaptations
  - Run `flutter analyze` to verify i18n implementation
  - Execute `flutter test` to run all tests including internationalization tests
  - Test language switching functionality
  - Verify all strings are properly localized
  - Test RTL language support and layout adaptation
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_
-

- [x] 12. Enhance accessibility and implement WCAG AA compliance




  - Add semantic labels for all interactive elements and images
  - Ensure all buttons meet minimum 44pt touch target requirements
  - Implement proper color contrast ratios (4.5:1 minimum) throughout the app
  - Add support for screen readers with appropriate focus management
  - Implement reduced motion alternatives for users with motion sensitivity
  - Run `flutter analyze` to check for accessibility-related issues
  - Execute `flutter test` to run all tests including accessibility tests
  - Test with screen reader functionality (TalkBack/VoiceOver)
  - Verify color contrast ratios meet WCAG AA standards
  - Test touch target sizes and focus management
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [x] 13. Implement comprehensive gamification system




  - Create polished gamification engine with points, levels, and badge systems
  - Add smooth animations for achievement notifications and level progression
  - Implement satisfying visual and haptic feedback for user actions
  - Ensure gamification feels integrated rather than tacked-on with consistent design
  - Focus gamification on habit formation goals rather than meaningless points
  - Run `flutter analyze` to verify gamification code quality
  - Execute `flutter test` to run all tests including gamification tests
  - Test point calculation and level progression logic
  - Verify animations and haptic feedback work correctly
  - Test badge system and achievement notifications
  - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_




- [ ] 14. Optimize app startup performance and prevent crashes

  - Implement parallel initialization of critical services to reduce startup time
  - Add proper error handling for initialization failures with retry options
  - Optimize memory usage during startup to prevent out-of-memory crashes
  - Implement detailed crash logging without exposing sensitive data
  - Add startup progress feedback and graceful handling of initialization delays
  - Run `flutter analyze` to check for startup-related issues
  - Execute `flutter test` to run all tests including startup tests
  - Test app startup performance and measure timing


  - Test error handling and recovery mechanisms
  - Monitor memory usage during startup
  - _Requirements: 19.1, 19.2, 19.3, 19.4, 19.5_

- [x] 15. Polish UI components and implement micro-interactions












  - Replace basic circular button shapes with refined designs including shadows and gradients
  - Implement smooth micro-interactions and animations throughout the app
  - Add proper visual hierarchy and consistent spacing using design tokens
  - Ensure all UI components look professional rather than wireframe-like
  - Implement smooth transitions between screens and states
  - Run `flutter analyze` to verify UI component implementations
  - Execute `flutter test` to run all tests including UI component tests
  - Test all micro-interactions and animations for smoothness
  - Verify visual hierarchy and spacing consistency
  - Test transitions between different screens and states
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_



- [x] 16. Final integration and cleanup



  - Integrate all implemented features and ensure proper communication between components
  - Remove any remaining legacy code or unused imports
  - Verify all navigation flows work correctly with the new 4-tab structure
  - Ensure AI insights dashboard properly displays real user data
  - Validate that crash recovery dialog is completely removed and silent recovery works
  - Run comprehensive `flutter analyze` across entire codebase
  - Execute full test suite to ensure no regressions
  - _Requirements: All requirements final validation_

- [x] 17. Replace mock data with real user data throughout the app




  - Remove FakeQuestRepository and replace with real Isar/Firestore data integration
  - Update statistics screen to display actual user data instead of hardcoded values
  - Replace all dummy/sample data in UI components with real data from repositories
  - Ensure AI insights dashboard shows actual user habit patterns and analytics
  - Update progress charts and visualizations to use real completion data
  - Run `flutter analyze` to verify data integration
  - Execute `flutter test` to run all tests including data integration tests
  - Test all screens with real user data and empty states
  - Verify data consistency across different screens and components
  - _Requirements: 2.2, 2.3, 8.2, 8.3, 8.4, 13.1, 13.2, 13.3_

- [x] 18. Drastically reduce settings screen complexity and button count





  - Remove excessive settings options that overwhelm users (reduce from 20+ to 8-10 essential options)
  - Consolidate related settings into logical groups with clear hierarchy
  - Move advanced/developer options to hidden or separate advanced section
  - Increase button sizes to minimum 44pt touch targets for better accessibility
  - Simplify navigation by removing redundant or rarely-used features from main settings
  - Run `flutter analyze` to verify settings screen changes
  - Execute `flutter test` to run all tests including settings screen tests
  - Test settings screen usability and ensure all essential functions remain accessible
  - Verify button sizes meet accessibility standards
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 14.2_

-

- [x] 19. Final integration and cleanup


  - Integrate all implemented features and ensure proper communication between components
  - Remove any remaining legacy code or unused imports
  - Verify all navigation flows work correctly with the new 4-tab structure
  - Ensure AI insights dashboard properly displays real user data
  - Validate that crash recovery dialog is completely removed and silent recovery works
  - Run comprehensive `flutter analyze` across entire codebase
  - Execute comprehensive `flutter test` to run full test suite and ensure no regressions
  - _Requirements: All requirements final validation_

- [x] 20. Remove unused gemma_ai_provider import from main.dart





  - Remove the unused import 'package:minq/data/providers/gemma_ai_provider.dart' from main.dart
  - Clean up any other unused imports throughout the codebase
  - Verify no compilation errors after removing unused imports
  - Run `flutter analyze` to confirm clean import structure
  - Execute `flutter test` to ensure no tests are broken by import changes
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
-

- [x] 21. Consolidate and activate unused advanced features




  - Integrate implemented but unused features (Guild, Battle, TimeCapsule, MoodTracking, PersonalityDiagnosis, WeeklyReport)
  - Add proper navigation routes and UI integration for advanced features
  - Remove "Coming Soon" placeholders and connect features to real functionality
  - Ensure premium features (SubscriptionManager, StreakRecoveryPurchase) are properly integrated
  - Test all advanced features work with real data instead of mock implementations
  - Run `flutter analyze` to verify feature integration
  - Execute `flutter test` to run all tests including advanced feature tests
  - Test navigation to all advanced feature screens
  - Verify premium feature access controls work correctly
  - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_

- [x] 22. Fix hardcoded Japanese strings throughout codebase




  - Extract all remaining hardcoded Japanese strings found in validation files and UI components
  - Move hardcoded strings like 'こんにちは', 'モーニングルーティン', etc. to .arb files
  - Replace direct Japanese text in error messages, UI labels, and test strings
  - Ensure all user-facing text uses AppLocalizations
  - Run `flutter analyze` to verify internationalization compliance
  - Execute `flutter test` to run all tests including internationalization tests
  - Test language switching with all extracted strings
  - Verify no hardcoded Japanese text remains in production code
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

- [x] 23. Final testing and bug fixes





  - Perform comprehensive testing across all implemented features
  - Fix any remaining bugs or issues discovered during testing
  - Verify app startup time is within 1.5-2.0 second target range
  - Ensure all UI components are polished and professional-looking
  - Validate that all accessibility requirements are met
  - Run final `flutter analyze` and resolve any remaining issues
  - Execute final comprehensive `flutter test` and fix any failing tests
  - Perform final performance and memory usage validation
  - _Requirements: Final quality assurance for all 20 requirements_