import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';
import 'package:minq/presentation/theme/color_tokens.dart';

class PremiumThemesService {
  final PremiumService _premiumService;
  final LocalStorageService _localStorage;

  PremiumThemesService(this._premiumService, this._localStorage);

  Future<bool> canUsePremiumThemes() async {
    return await _premiumService.hasFeature(FeatureType.themes);
  }

  Future<List<PremiumTheme>> getAvailableThemes() async {
    final canUsePremium = await canUsePremiumThemes();
    final allThemes = _getAllThemes();

    if (canUsePremium) {
      return allThemes;
    } else {
      return allThemes.where((theme) => !theme.isPremium).toList();
    }
  }

  Future<PremiumTheme?> getCurrentTheme() async {
    final themeId =
        await _localStorage.getString('selected_theme') ?? 'default';
    return _getThemeById(themeId);
  }

  Future<bool> setTheme(String themeId) async {
    final theme = _getThemeById(themeId);
    if (theme == null) return false;

    if (theme.isPremium && !await canUsePremiumThemes()) {
      return false;
    }

    await _localStorage.setString('selected_theme', themeId);
    return true;
  }

  Future<List<PremiumAnimation>> getAvailableAnimations() async {
    final canUsePremium = await canUsePremiumThemes();
    final allAnimations = _getAllAnimations();

    if (canUsePremium) {
      return allAnimations;
    } else {
      return allAnimations.where((animation) => !animation.isPremium).toList();
    }
  }

  Future<bool> setAnimation(String animationId, bool enabled) async {
    final animation = _getAnimationById(animationId);
    if (animation == null) return false;

    if (animation.isPremium && !await canUsePremiumThemes()) {
      return false;
    }

    await _localStorage.setBool('animation_$animationId', enabled);
    return true;
  }

  Future<bool> isAnimationEnabled(String animationId) async {
    return await _localStorage.getBool('animation_$animationId') ?? true;
  }

  List<PremiumTheme> _getAllThemes() {
    return [
      // Free themes
      const PremiumTheme(
        id: 'default',
        name: 'Default',
        description: 'The classic MinQ theme',
        isPremium: false,
        colorTokens: ColorTokens.light,
        darkColorTokens: ColorTokens.dark,
        category: ThemeCategory.classic,
      ),
      PremiumTheme(
        id: 'minimal',
        name: 'Minimal',
        description: 'Clean and simple design',
        isPremium: false,
        colorTokens: _createMinimalLightTokens(),
        darkColorTokens: _createMinimalDarkTokens(),
        category: ThemeCategory.minimal,
      ),

      // Premium themes
      PremiumTheme(
        id: 'aurora',
        name: 'Aurora',
        description: 'Inspired by the northern lights',
        isPremium: true,
        colorTokens: _createAuroraLightTokens(),
        darkColorTokens: _createAuroraDarkTokens(),
        category: ThemeCategory.nature,
        gradientBackground: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      PremiumTheme(
        id: 'sunset',
        name: 'Sunset',
        description: 'Warm sunset colors',
        isPremium: true,
        colorTokens: _createSunsetLightTokens(),
        darkColorTokens: _createSunsetDarkTokens(),
        category: ThemeCategory.nature,
        gradientBackground: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF9A8B), Color(0xFFFECFEF), Color(0xFFFECFEF)],
        ),
      ),
      PremiumTheme(
        id: 'ocean',
        name: 'Ocean',
        description: 'Deep ocean blues and teals',
        isPremium: true,
        colorTokens: _createOceanLightTokens(),
        darkColorTokens: _createOceanDarkTokens(),
        category: ThemeCategory.nature,
        gradientBackground: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
        ),
      ),
      PremiumTheme(
        id: 'forest',
        name: 'Forest',
        description: 'Lush forest greens',
        isPremium: true,
        colorTokens: _createForestLightTokens(),
        darkColorTokens: _createForestDarkTokens(),
        category: ThemeCategory.nature,
      ),
      PremiumTheme(
        id: 'neon',
        name: 'Neon',
        description: 'Cyberpunk-inspired neon colors',
        isPremium: true,
        colorTokens: _createNeonLightTokens(),
        darkColorTokens: _createNeonDarkTokens(),
        category: ThemeCategory.futuristic,
      ),
      PremiumTheme(
        id: 'pastel',
        name: 'Pastel Dreams',
        description: 'Soft pastel colors',
        isPremium: true,
        colorTokens: _createPastelLightTokens(),
        darkColorTokens: _createPastelDarkTokens(),
        category: ThemeCategory.soft,
      ),
      PremiumTheme(
        id: 'monochrome',
        name: 'Monochrome',
        description: 'Elegant black and white',
        isPremium: true,
        colorTokens: _createMonochromeLightTokens(),
        darkColorTokens: _createMonochromeDarkTokens(),
        category: ThemeCategory.minimal,
      ),
    ];
  }

  List<PremiumAnimation> _getAllAnimations() {
    return [
      // Free animations
      const PremiumAnimation(
        id: 'basic_transitions',
        name: 'Basic Transitions',
        description: 'Simple fade and slide animations',
        isPremium: false,
        category: AnimationCategory.transitions,
      ),

      // Premium animations
      const PremiumAnimation(
        id: 'particle_effects',
        name: 'Particle Effects',
        description: 'Beautiful particle animations',
        isPremium: true,
        category: AnimationCategory.effects,
      ),
      const PremiumAnimation(
        id: 'fluid_animations',
        name: 'Fluid Animations',
        description: 'Smooth, fluid motion effects',
        isPremium: true,
        category: AnimationCategory.transitions,
      ),
      const PremiumAnimation(
        id: 'celebration_effects',
        name: 'Celebration Effects',
        description: 'Special effects for achievements',
        isPremium: true,
        category: AnimationCategory.effects,
      ),
      const PremiumAnimation(
        id: 'micro_interactions',
        name: 'Micro Interactions',
        description: 'Subtle interactive animations',
        isPremium: true,
        category: AnimationCategory.interactions,
      ),
      const PremiumAnimation(
        id: 'loading_animations',
        name: 'Premium Loading',
        description: 'Elegant loading animations',
        isPremium: true,
        category: AnimationCategory.loading,
      ),
    ];
  }

  PremiumTheme? _getThemeById(String id) {
    try {
      return _getAllThemes().firstWhere((theme) => theme.id == id);
    } catch (e) {
      return null;
    }
  }

  PremiumAnimation? _getAnimationById(String id) {
    try {
      return _getAllAnimations().firstWhere((animation) => animation.id == id);
    } catch (e) {
      return null;
    }
  }

  // Theme color token creators
  ColorTokens _createMinimalLightTokens() {
    return ColorTokens.light.copyWith(
      primary: const Color(0xFF6B7280),
      secondary: const Color(0xFF9CA3AF),
      tertiary: const Color(0xFFD1D5DB),
    );
  }

  ColorTokens _createMinimalDarkTokens() {
    return ColorTokens.dark.copyWith(
      primary: const Color(0xFFD1D5DB),
      secondary: const Color(0xFF9CA3AF),
      tertiary: const Color(0xFF6B7280),
    );
  }

  ColorTokens _createAuroraLightTokens() {
    return ColorTokens.light.copyWith(
      primary: const Color(0xFF667EEA),
      secondary: const Color(0xFF764BA2),
      tertiary: const Color(0xFF9F7AEA),
      success: const Color(0xFF48BB78),
      warning: const Color(0xFFED8936),
      error: const Color(0xFFF56565),
    );
  }

  ColorTokens _createAuroraDarkTokens() {
    return ColorTokens.dark.copyWith(
      primary: const Color(0xFF9F7AEA),
      secondary: const Color(0xFF667EEA),
      tertiary: const Color(0xFF764BA2),
      background: const Color(0xFF1A1B3A),
      surface: const Color(0xFF2D2E5F),
    );
  }

  ColorTokens _createSunsetLightTokens() {
    return ColorTokens.light.copyWith(
      primary: const Color(0xFFFF6B6B),
      secondary: const Color(0xFFFFE66D),
      tertiary: const Color(0xFFFF8E53),
      background: const Color(0xFFFFF5F5),
      surface: const Color(0xFFFFFFFF),
    );
  }

  ColorTokens _createSunsetDarkTokens() {
    return ColorTokens.dark.copyWith(
      primary: const Color(0xFFFF8E53),
      secondary: const Color(0xFFFF6B6B),
      tertiary: const Color(0xFFFFE66D),
      background: const Color(0xFF2D1B1B),
      surface: const Color(0xFF3D2B2B),
    );
  }

  ColorTokens _createOceanLightTokens() {
    return ColorTokens.light.copyWith(
      primary: const Color(0xFF0EA5E9),
      secondary: const Color(0xFF06B6D4),
      tertiary: const Color(0xFF14B8A6),
      background: const Color(0xFFF0F9FF),
      surface: const Color(0xFFFFFFFF),
    );
  }

  ColorTokens _createOceanDarkTokens() {
    return ColorTokens.dark.copyWith(
      primary: const Color(0xFF38BDF8),
      secondary: const Color(0xFF22D3EE),
      tertiary: const Color(0xFF2DD4BF),
      background: const Color(0xFF0C1821),
      surface: const Color(0xFF1E293B),
    );
  }

  ColorTokens _createForestLightTokens() {
    return ColorTokens.light.copyWith(
      primary: const Color(0xFF059669),
      secondary: const Color(0xFF10B981),
      tertiary: const Color(0xFF34D399),
      background: const Color(0xFFF0FDF4),
      surface: const Color(0xFFFFFFFF),
    );
  }

  ColorTokens _createForestDarkTokens() {
    return ColorTokens.dark.copyWith(
      primary: const Color(0xFF34D399),
      secondary: const Color(0xFF10B981),
      tertiary: const Color(0xFF059669),
      background: const Color(0xFF0C1F17),
      surface: const Color(0xFF1F2937),
    );
  }

  ColorTokens _createNeonLightTokens() {
    return ColorTokens.light.copyWith(
      primary: const Color(0xFFFF00FF),
      secondary: const Color(0xFF00FFFF),
      tertiary: const Color(0xFFFFFF00),
      background: const Color(0xFF000000),
      surface: const Color(0xFF1A1A1A),
      textPrimary: const Color(0xFFFFFFFF),
    );
  }

  ColorTokens _createNeonDarkTokens() {
    return ColorTokens.dark.copyWith(
      primary: const Color(0xFFFF00FF),
      secondary: const Color(0xFF00FFFF),
      tertiary: const Color(0xFFFFFF00),
      background: const Color(0xFF000000),
      surface: const Color(0xFF0A0A0A),
    );
  }

  ColorTokens _createPastelLightTokens() {
    return ColorTokens.light.copyWith(
      primary: const Color(0xFFFFB3E6),
      secondary: const Color(0xFFB3E5FF),
      tertiary: const Color(0xFFB3FFB3),
      background: const Color(0xFFFFFAFF),
      surface: const Color(0xFFFFFFFF),
    );
  }

  ColorTokens _createPastelDarkTokens() {
    return ColorTokens.dark.copyWith(
      primary: const Color(0xFFFFB3E6),
      secondary: const Color(0xFFB3E5FF),
      tertiary: const Color(0xFFB3FFB3),
      background: const Color(0xFF2A1A2A),
      surface: const Color(0xFF3A2A3A),
    );
  }

  ColorTokens _createMonochromeLightTokens() {
    return ColorTokens.light.copyWith(
      primary: const Color(0xFF000000),
      secondary: const Color(0xFF404040),
      tertiary: const Color(0xFF808080),
      background: const Color(0xFFFFFFFF),
      surface: const Color(0xFFF5F5F5),
    );
  }

  ColorTokens _createMonochromeDarkTokens() {
    return ColorTokens.dark.copyWith(
      primary: const Color(0xFFFFFFFF),
      secondary: const Color(0xFFBFBFBF),
      tertiary: const Color(0xFF808080),
      background: const Color(0xFF000000),
      surface: const Color(0xFF0A0A0A),
    );
  }
}

class PremiumTheme {
  final String id;
  final String name;
  final String description;
  final bool isPremium;
  final ColorTokens colorTokens;
  final ColorTokens darkColorTokens;
  final ThemeCategory category;
  final LinearGradient? gradientBackground;
  final String? previewImageUrl;

  const PremiumTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.isPremium,
    required this.colorTokens,
    required this.darkColorTokens,
    required this.category,
    this.gradientBackground,
    this.previewImageUrl,
  });
}

class PremiumAnimation {
  final String id;
  final String name;
  final String description;
  final bool isPremium;
  final AnimationCategory category;
  final Duration? duration;
  final Curve? curve;

  const PremiumAnimation({
    required this.id,
    required this.name,
    required this.description,
    required this.isPremium,
    required this.category,
    this.duration,
    this.curve,
  });
}

enum ThemeCategory { classic, minimal, nature, futuristic, soft }

enum AnimationCategory { transitions, effects, interactions, loading }

final premiumThemesServiceProvider = Provider<PremiumThemesService>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return PremiumThemesService(premiumService, localStorage);
});

final availableThemesProvider = FutureProvider<List<PremiumTheme>>((ref) {
  final themesService = ref.watch(premiumThemesServiceProvider);
  return themesService.getAvailableThemes();
});

final currentThemeProvider = FutureProvider<PremiumTheme?>((ref) {
  final themesService = ref.watch(premiumThemesServiceProvider);
  return themesService.getCurrentTheme();
});

final availableAnimationsProvider = FutureProvider<List<PremiumAnimation>>((
  ref,
) {
  final themesService = ref.watch(premiumThemesServiceProvider);
  return themesService.getAvailableAnimations();
});
