import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/animations/animation_system.dart';
import 'package:minq/core/animations/particle_system.dart';
import 'package:minq/core/animations/micro_interactions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AnimationSystem', () {
    late AnimationSystem animationSystem;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      animationSystem = AnimationSystem.instance;
    });

    test('should initialize with default settings', () async {
      await animationSystem.initialize();

      expect(animationSystem.animationsEnabled, isTrue);
      expect(animationSystem.reducedMotion, isFalse);
      expect(animationSystem.hapticFeedbackEnabled, isTrue);
      expect(animationSystem.soundEffectsEnabled, isTrue);
    });

    test('should update animation settings', () async {
      await animationSystem.initialize();

      await animationSystem.updateAnimationSettings(
        animationsEnabled: false,
        reducedMotion: true,
        hapticFeedbackEnabled: false,
        soundEffectsEnabled: false,
      );

      expect(animationSystem.animationsEnabled, isFalse);
      expect(animationSystem.reducedMotion, isTrue);
      expect(animationSystem.hapticFeedbackEnabled, isFalse);
      expect(animationSystem.soundEffectsEnabled, isFalse);
    });

    test('should return zero duration when animations disabled', () async {
      await animationSystem.initialize();
      await animationSystem.updateAnimationSettings(animationsEnabled: false);

      const defaultDuration = Duration(milliseconds: 500);
      final actualDuration = animationSystem.getDuration(defaultDuration);

      expect(actualDuration, equals(Duration.zero));
    });

    test('should return linear curve when reduced motion enabled', () async {
      await animationSystem.initialize();
      await animationSystem.updateAnimationSettings(reducedMotion: true);

      const defaultCurve = Curves.easeInOut;
      final actualCurve = animationSystem.getCurve(defaultCurve);

      expect(actualCurve, equals(Curves.linear));
    });

    test('should return original duration when animations enabled', () async {
      await animationSystem.initialize();
      await animationSystem.updateAnimationSettings(animationsEnabled: true);

      const defaultDuration = Duration(milliseconds: 500);
      final actualDuration = animationSystem.getDuration(defaultDuration);

      expect(actualDuration, equals(defaultDuration));
    });

    test('should return original curve when reduced motion disabled', () async {
      await animationSystem.initialize();
      await animationSystem.updateAnimationSettings(reducedMotion: false);

      const defaultCurve = Curves.easeInOut;
      final actualCurve = animationSystem.getCurve(defaultCurve);

      expect(actualCurve, equals(defaultCurve));
    });
  });

  group('ParticleConfig', () {
    test('should create XP gain particle config', () {
      final config = ParticleConfig.xpGain();

      expect(config.particleCount, equals(30));
      expect(config.colors.length, greaterThan(0));
      expect(config.shapes.contains(ParticleShape.star), isTrue);
      expect(config.fadeOut, isTrue);
    });

    test('should create level up particle config', () {
      final config = ParticleConfig.levelUp();

      expect(config.particleCount, equals(100));
      expect(config.gravity, isTrue);
      expect(config.emissionType, equals(ParticleEmissionType.fountain));
      expect(config.shapes.contains(ParticleShape.star), isTrue);
    });

    test('should create success particle config', () {
      final config = ParticleConfig.success();

      expect(config.particleCount, equals(40));
      expect(config.shapes.contains(ParticleShape.heart), isTrue);
      expect(config.emissionType, equals(ParticleEmissionType.burst));
    });

    test('should create celebration particle config', () {
      final config = ParticleConfig.celebration();

      expect(config.particleCount, equals(80));
      expect(config.colors.length, greaterThan(4));
      expect(config.gravity, isTrue);
      expect(config.emissionType, equals(ParticleEmissionType.continuous));
    });
  });

  group('Particle', () {
    test('should update position and velocity', () {
      final particle = Particle(
        position: const Offset(0, 0),
        velocity: const Offset(10, 10),
        size: 5.0,
        color: const Color(0xFF000000),
        life: 1.0,
        maxLife: 1.0,
        shape: ParticleShape.circle,
      );

      final config = ParticleConfig.xpGain();
      particle.update(0.1, config);

      expect(particle.position.dx, equals(1.0));
      expect(particle.position.dy, equals(1.0));
      expect(particle.life, equals(0.9));
    });

    test('should apply gravity when enabled', () {
      final particle = Particle(
        position: const Offset(0, 0),
        velocity: const Offset(0, 0),
        size: 5.0,
        color: const Color(0xFF000000),
        life: 1.0,
        maxLife: 1.0,
        shape: ParticleShape.circle,
      );

      final config = ParticleConfig.levelUp();
      particle.update(0.1, config);

      expect(particle.velocity.dy, greaterThan(0));
    });

    test('should calculate opacity based on life', () {
      final particle = Particle(
        position: const Offset(0, 0),
        velocity: const Offset(0, 0),
        size: 5.0,
        color: const Color(0xFF000000),
        life: 0.5,
        maxLife: 1.0,
        shape: ParticleShape.circle,
      );

      expect(particle.opacity, equals(0.5));
    });

    test('should be alive when life > 0', () {
      final particle = Particle(
        position: const Offset(0, 0),
        velocity: const Offset(0, 0),
        size: 5.0,
        color: const Color(0xFF000000),
        life: 0.1,
        maxLife: 1.0,
        shape: ParticleShape.circle,
      );

      expect(particle.isAlive, isTrue);
    });

    test('should be dead when life <= 0', () {
      final particle = Particle(
        position: const Offset(0, 0),
        velocity: const Offset(0, 0),
        size: 5.0,
        color: const Color(0xFF000000),
        life: 0.0,
        maxLife: 1.0,
        shape: ParticleShape.circle,
      );

      expect(particle.isAlive, isFalse);
    });
  });

  group('FABAction', () {
    test('should create FAB action with required properties', () {
      final action = FABAction(icon: Icons.add, label: 'Add', onPressed: () {});

      expect(action.icon, equals(Icons.add));
      expect(action.label, equals('Add'));
      expect(action.onPressed, isNotNull);
    });
  });

  group('SwipeAction', () {
    test('should create swipe action with required properties', () {
      final action = SwipeAction(
        icon: Icons.delete,
        label: 'Delete',
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () {},
      );

      expect(action.icon, equals(Icons.delete));
      expect(action.label, equals('Delete'));
      expect(action.backgroundColor, equals(Colors.red));
      expect(action.foregroundColor, equals(Colors.white));
      expect(action.onPressed, isNotNull);
    });
  });
}
