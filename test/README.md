# MinQ Comprehensive Test Suite

This directory contains a comprehensive test suite for the MinQ habit tracking application, providing complete coverage of functionality, performance, and quality assurance.

## 📋 Test Structure

```
test/
├── comprehensive_test_suite.dart    # Main test orchestrator
├── test_runner.dart                 # Test execution and reporting
├── README.md                        # This file
├── core/                           # Core business logic tests
│   ├── accessibility/              # Accessibility system tests
│   ├── analytics/                  # Analytics and insights tests
│   ├── animations/                 # Animation system tests
│   ├── challenges/                 # Challenge functionality tests
│   ├── gamification/               # XP, levels, leagues tests
│   ├── notifications/              # Notification system tests
│   ├── performance/                # Performance optimization tests
│   ├── premium/                    # Premium features tests
│   ├── profile/                    # User profile tests
│   ├── realtime/                   # Real-time communication tests
│   ├── search/                     # Search and filtering tests
│   ├── social/                     # Social and pair features tests
│   └── sync/                       # Offline sync tests
├── presentation/                   # UI and presentation tests
│   ├── theme/                      # Theme system tests
│   ├── widgets/                    # Widget component tests
│   └── screens/                    # Screen-level tests
├── integration/                    # Integration tests
│   ├── offline_sync_integration_test.dart
│   ├── user_journey_integration_test.dart
│   ├── gamification_integration_test.dart
│   └── ai_coach_integration_test.dart
├── e2e/                           # End-to-end tests
│   ├── complete_user_flow_test.dart
│   ├── offline_functionality_test.dart
│   └── performance_benchmark_test.dart
└── features/                      # Feature-specific tests
    └── advanced_features_functionality_test.dart
```

## 🎯 Test Categories

### 1. Unit Tests (Core Logic)
- **Coverage Target**: 80%+
- **Focus**: Business logic, data models, services
- **Examples**: XP calculation, quest validation, sync logic

### 2. Widget Tests (UI Components)
- **Coverage Target**: 70%+
- **Focus**: UI components, user interactions, theme compliance
- **Examples**: Quest cards, navigation, form validation

### 3. Integration Tests (Feature Workflows)
- **Coverage Target**: 60%+
- **Focus**: Cross-component communication, data flow
- **Examples**: Quest creation flow, gamification integration

### 4. E2E Tests (User Journeys)
- **Coverage Target**: Complete user scenarios
- **Focus**: Real user workflows, performance benchmarks
- **Examples**: Onboarding to first achievement, offline functionality

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Comprehensive Test Suite
```bash
flutter test test/comprehensive_test_suite.dart
```

### Run Specific Test Categories
```bash
# Unit tests only
flutter test test/core/

# Widget tests only
flutter test test/presentation/

# Integration tests only
flutter test test/integration/

# E2E tests only
flutter test test/e2e/
```

### Run with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run Performance Benchmarks
```bash
flutter test test/e2e/performance_benchmark_test.dart
```

## 📊 Quality Standards

### Test Coverage Requirements
- **Core Logic**: ≥80% line coverage
- **UI Components**: ≥70% line coverage
- **Integration Flows**: ≥60% line coverage
- **Overall**: ≥75% line coverage

### Performance Benchmarks
- **App Startup**: <3 seconds
- **Memory Usage**: <150MB
- **Navigation**: <300ms per transition
- **Database Operations**: <1 second for complex queries

### Code Quality Standards
- **Critical Issues**: 0 allowed
- **Warnings**: <10 total
- **Maintainability Score**: ≥8.0/10
- **Security Vulnerabilities**: 0 high-severity

## 🧪 Test Implementation Guidelines

### Unit Test Structure
```dart
void main() {
  group('ServiceName', () {
    late ServiceName service;
    late MockDependency mockDependency;

    setUp(() {
      mockDependency = MockDependency();
      service = ServiceName(dependency: mockDependency);
    });

    group('methodName', () {
      test('should return expected result when valid input', () {
        // Arrange
        when(() => mockDependency.method()).thenReturn(expectedValue);

        // Act
        final result = service.methodName();

        // Assert
        expect(result, equals(expectedValue));
        verify(() => mockDependency.method()).called(1);
      });
    });
  });
}
```

### Widget Test Structure
```dart
void main() {
  group('WidgetName', () {
    testWidgets('should display expected content', (tester) async {
      // Arrange
      const testData = TestData();

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: WidgetName(data: testData),
        ),
      );

      // Assert
      expect(find.text('Expected Text'), findsOneWidget);
      expect(find.byType(ExpectedWidget), findsOneWidget);
    });
  });
}
```

### Integration Test Structure
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Feature Integration', () {
    testWidgets('should complete workflow successfully', (tester) async {
      // Setup
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Execute workflow
      await tester.tap(find.byKey(Key('start_button')));
      await tester.pumpAndSettle();

      // Verify results
      expect(find.text('Success'), findsOneWidget);
    });
  });
}
```

## 🔧 Test Utilities

### Mock Services
- `MockNetworkService`: Network connectivity simulation
- `MockDatabaseService`: Database operation mocking
- `MockAIService`: AI response simulation
- `MockAuthService`: Authentication mocking

### Test Helpers
- `TestDataFactory`: Generate test data
- `WidgetTestHelpers`: Common widget test utilities
- `NetworkSimulator`: Network condition simulation
- `PerformanceProfiler`: Performance measurement tools

### Golden Tests
- Theme compliance verification
- Visual regression detection
- Cross-platform UI consistency
- Accessibility compliance

## 📈 Continuous Integration

### Pre-commit Hooks
```bash
# Install pre-commit hooks
dart run husky install

# Hooks include:
# - flutter analyze
# - flutter test
# - flutter format --set-exit-if-changed
```

### CI Pipeline
1. **Static Analysis**: `flutter analyze`
2. **Unit Tests**: `flutter test test/core/`
3. **Widget Tests**: `flutter test test/presentation/`
4. **Integration Tests**: `flutter test test/integration/`
5. **E2E Tests**: `flutter test test/e2e/`
6. **Coverage Report**: Generate and upload coverage
7. **Performance Benchmarks**: Run and compare metrics

### Quality Gates
- All tests must pass
- Coverage targets must be met
- No critical static analysis issues
- Performance benchmarks within limits

## 🐛 Debugging Tests

### Common Issues
1. **Flaky Tests**: Use `pumpAndSettle()` appropriately
2. **Timeout Issues**: Increase timeout for slow operations
3. **Mock Setup**: Ensure all dependencies are properly mocked
4. **Widget Not Found**: Use `find.byKey()` for reliable element location

### Debug Commands
```bash
# Run single test with verbose output
flutter test test/path/to/test.dart --verbose

# Run tests with debugging
flutter test --start-paused

# Profile test performance
flutter test --profile
```

## 📚 Best Practices

### Test Organization
- Group related tests logically
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Keep tests independent and isolated

### Mock Strategy
- Mock external dependencies
- Use real objects for value objects
- Verify interactions when behavior matters
- Stub return values for state verification

### Performance Testing
- Test with realistic data volumes
- Measure actual performance metrics
- Set reasonable performance thresholds
- Monitor performance trends over time

### Accessibility Testing
- Test with screen readers enabled
- Verify keyboard navigation
- Check color contrast ratios
- Test with different text sizes

## 🎉 Success Metrics

The comprehensive test suite ensures:

✅ **High Code Quality**: 80%+ test coverage with zero critical issues
✅ **Performance Assurance**: All benchmarks within acceptable limits
✅ **Regression Prevention**: Automated detection of breaking changes
✅ **Platform Compatibility**: Consistent behavior across all platforms
✅ **Accessibility Compliance**: WCAG AA standards met
✅ **User Experience**: Complete user journeys tested end-to-end

This test suite provides confidence in the MinQ application's quality, reliability, and maintainability for production deployment.