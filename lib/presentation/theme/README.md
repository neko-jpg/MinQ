# Enhanced MinQ Theme System

## Overview

The Enhanced MinQ Theme System extends the original MinqTheme with emotional colors, improved spacing, accessibility features, and animation curves designed to create delightful user experiences that promote habit formation and user engagement.

## Key Features

### 🎨 Emotional Color Palette

The theme now includes colors specifically chosen to evoke positive emotions:

```dart
final theme = MinqTheme.of(context);

// Emotional colors
theme.joyAccent        // Golden yellow for celebrations (#FFD700)
theme.encouragement    // Warm red for motivation (#FF6B6B)
theme.serenity        // Calming teal for peace (#4ECDC4)
theme.warmth          // Orange for friendliness (#FFA726)
```

### 📊 State Colors

Clear visual indicators for different states:

```dart
theme.progressActive    // Active blue for ongoing tasks
theme.progressComplete  // Success green for completed items
theme.progressPending   // Muted gray for waiting states
```

### 🖱️ Interaction Colors

Feedback colors for user interactions:

```dart
theme.tapFeedback      // Light blue for tap responses
theme.hoverState       // Light gray for hover states
```

### ⚠️ Error & Warning Colors

WCAG-compliant colors for alerts:

```dart
theme.accentError      // Clear red for errors
theme.accentWarning    // Amber for warnings
```

## Enhanced Spacing System

### Emotional Spacing

The spacing system is designed to create emotional responses:

```dart
theme.intimateSpace     // 6px - Close, personal spacing
theme.breathingSpace    // 16px - Comfortable, relaxed spacing
theme.respectfulSpace   // 32px - Respectful distance between sections
theme.dramaticSpace     // 48px - Dramatic spacing for emphasis
```

### Padding Helpers

Convenient padding methods:

```dart
Container(
  padding: theme.breathingPadding,  // EdgeInsets.all(16.0)
  child: Text('Comfortable spacing'),
)

Container(
  padding: theme.intimatePadding,   // EdgeInsets.all(6.0)
  child: Text('Close spacing'),
)
```

## Emotional Typography

Typography styles that convey emotion:

```dart
Text('🎉 Achievement unlocked!', style: theme.celebrationText),
Text('💪 Keep going!', style: theme.encouragementText),
Text('💡 Helpful tip', style: theme.guidanceText),
Text('(subtle hint)', style: theme.whisperText),
```

## Animation Curves

Predefined curves for delightful animations:

```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  curve: theme.easeInOutCubic,     // Smooth, natural movement
  // or
  curve: theme.easeOutBack,        // Playful bounce-back
  curve: theme.bounceOut,          // Celebratory bounce
  curve: theme.easeInOutQuart,     // Dramatic easing
)
```

## Accessibility Features

### High Contrast Support

```dart
// Automatically adapts to system high contrast settings
Color textColor = theme.getAccessibleTextColor(context);
Color backgroundColor = theme.getAccessibleBackgroundColor(context);

// Check if high contrast mode is enabled
bool isHighContrast = theme.isHighContrastMode(context);
```

### WCAG Compliance

```dart
// Check color contrast ratios
bool meetsAA = theme.meetsWCAGAA(foregroundColor, backgroundColor);
bool meetsAAA = theme.meetsWCAGAAA(foregroundColor, backgroundColor);

// Calculate exact contrast ratio
double ratio = MinqTheme.calculateContrastRatio(foregroundColor, backgroundColor);
```

### Motion Sensitivity

```dart
// Respects user's motion preferences
Duration animDuration = theme.getAnimationDuration(
  context, 
  Duration(milliseconds: 300)
); // Returns Duration.zero if animations are disabled
```

### Touch Target Size

```dart
// Ensures minimum touch target size for accessibility
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: Size(double.infinity, MinqTheme.minTouchTargetSize), // 44pt
  ),
  child: Text('Accessible Button'),
)
```

## Usage Examples

### Creating Emotional UI Elements

```dart
// Celebration card
Container(
  padding: theme.breathingPadding,
  decoration: BoxDecoration(
    color: theme.joyAccent.withValues(alpha: 0.1),
    borderRadius: theme.cornerLarge(),
    border: Border.all(color: theme.joyAccent.withValues(alpha: 0.3)),
  ),
  child: Column(
    children: [
      Text('🎉 Streak Complete!', style: theme.celebrationText),
      SizedBox(height: theme.intimateSpace),
      Text('You\'ve completed 7 days in a row!', style: theme.bodyMedium),
    ],
  ),
)
```

### Progress Indicators

```dart
// Progress ring with emotional colors
Container(
  width: 100,
  height: 100,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: SweepGradient(
      colors: [
        theme.progressPending,
        theme.progressActive,
        theme.progressComplete,
      ],
    ),
  ),
)
```

### Accessible Error States

```dart
// Error message with proper contrast
Container(
  padding: theme.breathingPadding,
  decoration: BoxDecoration(
    color: theme.accentError.withValues(alpha: 0.1),
    borderRadius: theme.cornerMedium(),
    border: Border.all(color: theme.accentError),
  ),
  child: Row(
    children: [
      Icon(Icons.error, color: theme.accentError),
      SizedBox(width: theme.intimateSpace),
      Expanded(
        child: Text(
          'Please check your input and try again',
          style: theme.bodyMedium.copyWith(color: theme.accentError),
        ),
      ),
    ],
  ),
)
```

### Animated Interactions

```dart
class AnimatedQuestCard extends StatefulWidget {
  @override
  _AnimatedQuestCardState createState() => _AnimatedQuestCardState();
}

class _AnimatedQuestCardState extends State<AnimatedQuestCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    final theme = MinqTheme.of(context);
    
    _controller = AnimationController(
      duration: theme.getAnimationDuration(context, Duration(milliseconds: 200)),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: theme.easeInOutCubic,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: theme.breathingPadding,
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: theme.cornerLarge(),
                boxShadow: theme.shadowSoft,
              ),
              child: Text('Tap me!', style: theme.bodyMedium),
            ),
          );
        },
      ),
    );
  }
}
```

## Dark Mode Support

All colors automatically adapt to dark mode:

```dart
// Light theme
final lightTheme = MinqTheme.light();
print(lightTheme.joyAccent); // #FFD700

// Dark theme  
final darkTheme = MinqTheme.dark();
print(darkTheme.joyAccent); // #FFC107 (slightly muted for dark backgrounds)
```

## Best Practices

1. **Use emotional colors purposefully** - Don't overuse bright colors; save them for meaningful moments
2. **Respect accessibility settings** - Always use the accessibility helper methods
3. **Test contrast ratios** - Use the built-in WCAG compliance checkers
4. **Consider motion sensitivity** - Use `getAnimationDuration()` for all animations
5. **Maintain consistency** - Use the spacing system consistently throughout the app
6. **Test on real devices** - Verify touch targets meet minimum size requirements

## Migration from Original Theme

The enhanced theme is fully backward compatible. Existing code will continue to work, and you can gradually adopt new features:

```dart
// Old way (still works)
Container(
  color: theme.accentSuccess,
  padding: EdgeInsets.all(16),
)

// New way (enhanced)
Container(
  color: theme.progressComplete,
  padding: theme.breathingPadding,
)
```

## Testing

The theme includes comprehensive tests. Run them with:

```bash
flutter test test/enhanced_theme_test.dart
```

## Example App

See `enhanced_theme_example.dart` for a complete demonstration of all theme features.