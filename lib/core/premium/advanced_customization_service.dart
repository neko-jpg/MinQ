import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:minq/presentation/theme/color_tokens.dart';

class AdvancedCustomizationService {
  final PremiumService _premiumService;
  final LocalStorageService _localStorage;

  AdvancedCustomizationService(this._premiumService, this._localStorage);

  Future<bool> canUseAdvancedCustomization() async {
    return await _premiumService.hasAdvancedCustomization();
  }

  // Custom Color Schemes
  Future<List<CustomColorScheme>> getCustomColorSchemes() async {
    if (!await canUseAdvancedCustomization()) return [];

    try {
      final schemesData = await _localStorage.getString('custom_color_schemes');
      if (schemesData == null) return [];

      final List<dynamic> schemesList = jsonDecode(schemesData);
      return schemesList
          .map((json) => CustomColorScheme.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveCustomColorScheme(CustomColorScheme scheme) async {
    if (!await canUseAdvancedCustomization()) return false;

    try {
      final schemes = await getCustomColorSchemes();
      schemes.removeWhere((s) => s.id == scheme.id);
      schemes.add(scheme);

      final schemesJson = jsonEncode(schemes.map((s) => s.toJson()).toList());
      await _localStorage.setString('custom_color_schemes', schemesJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCustomColorScheme(String schemeId) async {
    if (!await canUseAdvancedCustomization()) return false;

    try {
      final schemes = await getCustomColorSchemes();
      schemes.removeWhere((s) => s.id == schemeId);

      final schemesJson = jsonEncode(schemes.map((s) => s.toJson()).toList());
      await _localStorage.setString('custom_color_schemes', schemesJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Custom Layouts
  Future<List<CustomLayout>> getCustomLayouts() async {
    if (!await canUseAdvancedCustomization()) return [];

    try {
      final layoutsData = await _localStorage.getString('custom_layouts');
      if (layoutsData == null) return _getDefaultLayouts();

      final List<dynamic> layoutsList = jsonDecode(layoutsData);
      return layoutsList.map((json) => CustomLayout.fromJson(json)).toList();
    } catch (e) {
      return _getDefaultLayouts();
    }
  }

  Future<bool> saveCustomLayout(CustomLayout layout) async {
    if (!await canUseAdvancedCustomization()) return false;

    try {
      final layouts = await getCustomLayouts();
      layouts.removeWhere((l) => l.id == layout.id);
      layouts.add(layout);

      final layoutsJson = jsonEncode(layouts.map((l) => l.toJson()).toList());
      await _localStorage.setString('custom_layouts', layoutsJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Widget Customization
  Future<Map<String, WidgetCustomization>> getWidgetCustomizations() async {
    if (!await canUseAdvancedCustomization()) return {};

    try {
      final customizationsData = await _localStorage.getString(
        'widget_customizations',
      );
      if (customizationsData == null) return {};

      final Map<String, dynamic> customizationsMap = jsonDecode(
        customizationsData,
      );
      return customizationsMap.map(
        (key, value) => MapEntry(key, WidgetCustomization.fromJson(value)),
      );
    } catch (e) {
      return {};
    }
  }

  Future<bool> saveWidgetCustomization(
    String widgetId,
    WidgetCustomization customization,
  ) async {
    if (!await canUseAdvancedCustomization()) return false;

    try {
      final customizations = await getWidgetCustomizations();
      customizations[widgetId] = customization;

      final customizationsJson = jsonEncode(
        customizations.map((key, value) => MapEntry(key, value.toJson())),
      );
      await _localStorage.setString(
        'widget_customizations',
        customizationsJson,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Dashboard Customization
  Future<DashboardCustomization> getDashboardCustomization() async {
    if (!await canUseAdvancedCustomization()) {
      return DashboardCustomization.defaultCustomization();
    }

    try {
      final customizationData = await _localStorage.getString(
        'dashboard_customization',
      );
      if (customizationData == null) {
        return DashboardCustomization.defaultCustomization();
      }

      final json = jsonDecode(customizationData);
      return DashboardCustomization.fromJson(json);
    } catch (e) {
      return DashboardCustomization.defaultCustomization();
    }
  }

  Future<bool> saveDashboardCustomization(
    DashboardCustomization customization,
  ) async {
    if (!await canUseAdvancedCustomization()) return false;

    try {
      final customizationJson = jsonEncode(customization.toJson());
      await _localStorage.setString(
        'dashboard_customization',
        customizationJson,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Font Customization
  Future<FontCustomization> getFontCustomization() async {
    if (!await canUseAdvancedCustomization()) {
      return FontCustomization.defaultCustomization();
    }

    try {
      final fontData = await _localStorage.getString('font_customization');
      if (fontData == null) {
        return FontCustomization.defaultCustomization();
      }

      final json = jsonDecode(fontData);
      return FontCustomization.fromJson(json);
    } catch (e) {
      return FontCustomization.defaultCustomization();
    }
  }

  Future<bool> saveFontCustomization(FontCustomization customization) async {
    if (!await canUseAdvancedCustomization()) return false;

    try {
      final customizationJson = jsonEncode(customization.toJson());
      await _localStorage.setString('font_customization', customizationJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Animation Preferences
  Future<AnimationPreferences> getAnimationPreferences() async {
    if (!await canUseAdvancedCustomization()) {
      return AnimationPreferences.defaultPreferences();
    }

    try {
      final preferencesData = await _localStorage.getString(
        'animation_preferences',
      );
      if (preferencesData == null) {
        return AnimationPreferences.defaultPreferences();
      }

      final json = jsonDecode(preferencesData);
      return AnimationPreferences.fromJson(json);
    } catch (e) {
      return AnimationPreferences.defaultPreferences();
    }
  }

  Future<bool> saveAnimationPreferences(
    AnimationPreferences preferences,
  ) async {
    if (!await canUseAdvancedCustomization()) return false;

    try {
      final preferencesJson = jsonEncode(preferences.toJson());
      await _localStorage.setString('animation_preferences', preferencesJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  List<CustomLayout> _getDefaultLayouts() {
    return [
      const CustomLayout(
        id: 'compact',
        name: 'Compact',
        description: 'Dense layout with more content per screen',
        cardSpacing: 8.0,
        sectionSpacing: 16.0,
        showAvatars: false,
        showDescriptions: false,
        gridColumns: 2,
      ),
      const CustomLayout(
        id: 'comfortable',
        name: 'Comfortable',
        description: 'Balanced layout with good readability',
        cardSpacing: 12.0,
        sectionSpacing: 24.0,
        showAvatars: true,
        showDescriptions: true,
        gridColumns: 1,
      ),
      const CustomLayout(
        id: 'spacious',
        name: 'Spacious',
        description: 'Generous spacing for easy interaction',
        cardSpacing: 16.0,
        sectionSpacing: 32.0,
        showAvatars: true,
        showDescriptions: true,
        gridColumns: 1,
      ),
    ];
  }
}

class CustomColorScheme {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color success;
  final Color warning;
  final Color error;
  final DateTime createdAt;

  const CustomColorScheme({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.success,
    required this.warning,
    required this.error,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'primary': primary.value,
    'secondary': secondary.value,
    'tertiary': tertiary.value,
    'background': background.value,
    'surface': surface.value,
    'success': success.value,
    'warning': warning.value,
    'error': error.value,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CustomColorScheme.fromJson(Map<String, dynamic> json) =>
      CustomColorScheme(
        id: json['id'],
        name: json['name'],
        primary: Color(json['primary']),
        secondary: Color(json['secondary']),
        tertiary: Color(json['tertiary']),
        background: Color(json['background']),
        surface: Color(json['surface']),
        success: Color(json['success']),
        warning: Color(json['warning']),
        error: Color(json['error']),
        createdAt: DateTime.parse(json['createdAt']),
      );

  ColorTokens toColorTokens() {
    return ColorTokens(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      background: background,
      surface: surface,
      success: success,
      warning: warning,
      error: error,
      // Add other required properties with defaults
      primaryHover: primary,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      surfaceAlt: surface,
      surfaceVariant: surface,
      textPrimary: Colors.black,
      textSecondary: Colors.grey,
      textMuted: Colors.grey.shade400,
      info: Colors.blue,
      focusRing: primary,
      border: Colors.grey.shade300,
      overlay: Colors.black54,
    );
  }
}

class CustomLayout {
  final String id;
  final String name;
  final String description;
  final double cardSpacing;
  final double sectionSpacing;
  final bool showAvatars;
  final bool showDescriptions;
  final int gridColumns;

  const CustomLayout({
    required this.id,
    required this.name,
    required this.description,
    required this.cardSpacing,
    required this.sectionSpacing,
    required this.showAvatars,
    required this.showDescriptions,
    required this.gridColumns,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'cardSpacing': cardSpacing,
    'sectionSpacing': sectionSpacing,
    'showAvatars': showAvatars,
    'showDescriptions': showDescriptions,
    'gridColumns': gridColumns,
  };

  factory CustomLayout.fromJson(Map<String, dynamic> json) => CustomLayout(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    cardSpacing: json['cardSpacing'],
    sectionSpacing: json['sectionSpacing'],
    showAvatars: json['showAvatars'],
    showDescriptions: json['showDescriptions'],
    gridColumns: json['gridColumns'],
  );
}

class WidgetCustomization {
  final bool isVisible;
  final double opacity;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final double elevation;

  const WidgetCustomization({
    required this.isVisible,
    required this.opacity,
    required this.padding,
    required this.borderRadius,
    this.backgroundColor,
    required this.elevation,
  });

  Map<String, dynamic> toJson() => {
    'isVisible': isVisible,
    'opacity': opacity,
    'padding': {
      'left': padding.left,
      'top': padding.top,
      'right': padding.right,
      'bottom': padding.bottom,
    },
    'borderRadius': {
      'topLeft': borderRadius.topLeft.x,
      'topRight': borderRadius.topRight.x,
      'bottomLeft': borderRadius.bottomLeft.x,
      'bottomRight': borderRadius.bottomRight.x,
    },
    'backgroundColor': backgroundColor?.value,
    'elevation': elevation,
  };

  factory WidgetCustomization.fromJson(Map<String, dynamic> json) =>
      WidgetCustomization(
        isVisible: json['isVisible'],
        opacity: json['opacity'],
        padding: EdgeInsets.only(
          left: json['padding']['left'],
          top: json['padding']['top'],
          right: json['padding']['right'],
          bottom: json['padding']['bottom'],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(json['borderRadius']['topLeft']),
          topRight: Radius.circular(json['borderRadius']['topRight']),
          bottomLeft: Radius.circular(json['borderRadius']['bottomLeft']),
          bottomRight: Radius.circular(json['borderRadius']['bottomRight']),
        ),
        backgroundColor:
            json['backgroundColor'] != null
                ? Color(json['backgroundColor'])
                : null,
        elevation: json['elevation'],
      );

  static WidgetCustomization defaultCustomization() => WidgetCustomization(
    isVisible: true,
    opacity: 1.0,
    padding: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(12),
    elevation: 2.0,
  );
}

class DashboardCustomization {
  final List<String> widgetOrder;
  final Map<String, bool> widgetVisibility;
  final int columnsPortrait;
  final int columnsLandscape;
  final double widgetSpacing;

  const DashboardCustomization({
    required this.widgetOrder,
    required this.widgetVisibility,
    required this.columnsPortrait,
    required this.columnsLandscape,
    required this.widgetSpacing,
  });

  Map<String, dynamic> toJson() => {
    'widgetOrder': widgetOrder,
    'widgetVisibility': widgetVisibility,
    'columnsPortrait': columnsPortrait,
    'columnsLandscape': columnsLandscape,
    'widgetSpacing': widgetSpacing,
  };

  factory DashboardCustomization.fromJson(Map<String, dynamic> json) =>
      DashboardCustomization(
        widgetOrder: List<String>.from(json['widgetOrder']),
        widgetVisibility: Map<String, bool>.from(json['widgetVisibility']),
        columnsPortrait: json['columnsPortrait'],
        columnsLandscape: json['columnsLandscape'],
        widgetSpacing: json['widgetSpacing'],
      );

  static DashboardCustomization defaultCustomization() =>
      const DashboardCustomization(
        widgetOrder: [
          'streak_counter',
          'today_progress',
          'weekly_trend',
          'achievements',
          'ai_insights',
        ],
        widgetVisibility: {
          'streak_counter': true,
          'today_progress': true,
          'weekly_trend': true,
          'achievements': true,
          'ai_insights': true,
          'category_breakdown': false,
          'time_patterns': false,
        },
        columnsPortrait: 1,
        columnsLandscape: 2,
        widgetSpacing: 16.0,
      );
}

class FontCustomization {
  final String fontFamily;
  final double scaleFactor;
  final FontWeight headingWeight;
  final FontWeight bodyWeight;
  final double lineHeight;
  final double letterSpacing;

  const FontCustomization({
    required this.fontFamily,
    required this.scaleFactor,
    required this.headingWeight,
    required this.bodyWeight,
    required this.lineHeight,
    required this.letterSpacing,
  });

  Map<String, dynamic> toJson() => {
    'fontFamily': fontFamily,
    'scaleFactor': scaleFactor,
    'headingWeight': headingWeight.index,
    'bodyWeight': bodyWeight.index,
    'lineHeight': lineHeight,
    'letterSpacing': letterSpacing,
  };

  factory FontCustomization.fromJson(Map<String, dynamic> json) =>
      FontCustomization(
        fontFamily: json['fontFamily'],
        scaleFactor: json['scaleFactor'],
        headingWeight: FontWeight.values[json['headingWeight']],
        bodyWeight: FontWeight.values[json['bodyWeight']],
        lineHeight: json['lineHeight'],
        letterSpacing: json['letterSpacing'],
      );

  static FontCustomization defaultCustomization() => const FontCustomization(
    fontFamily: 'System',
    scaleFactor: 1.0,
    headingWeight: FontWeight.w600,
    bodyWeight: FontWeight.w400,
    lineHeight: 1.4,
    letterSpacing: 0.0,
  );
}

class AnimationPreferences {
  final bool enableTransitions;
  final bool enableParticles;
  final bool enableMicroInteractions;
  final double animationSpeed;
  final bool reduceMotion;

  const AnimationPreferences({
    required this.enableTransitions,
    required this.enableParticles,
    required this.enableMicroInteractions,
    required this.animationSpeed,
    required this.reduceMotion,
  });

  Map<String, dynamic> toJson() => {
    'enableTransitions': enableTransitions,
    'enableParticles': enableParticles,
    'enableMicroInteractions': enableMicroInteractions,
    'animationSpeed': animationSpeed,
    'reduceMotion': reduceMotion,
  };

  factory AnimationPreferences.fromJson(Map<String, dynamic> json) =>
      AnimationPreferences(
        enableTransitions: json['enableTransitions'],
        enableParticles: json['enableParticles'],
        enableMicroInteractions: json['enableMicroInteractions'],
        animationSpeed: json['animationSpeed'],
        reduceMotion: json['reduceMotion'],
      );

  static AnimationPreferences defaultPreferences() =>
      const AnimationPreferences(
        enableTransitions: true,
        enableParticles: true,
        enableMicroInteractions: true,
        animationSpeed: 1.0,
        reduceMotion: false,
      );
}

final advancedCustomizationServiceProvider =
    Provider<AdvancedCustomizationService>((ref) {
      final premiumService = ref.watch(premiumServiceProvider);
      final localStorage = ref.watch(localStorageServiceProvider);
      return AdvancedCustomizationService(premiumService, localStorage);
    });

final customColorSchemesProvider = FutureProvider<List<CustomColorScheme>>((
  ref,
) {
  final customizationService = ref.watch(advancedCustomizationServiceProvider);
  return customizationService.getCustomColorSchemes();
});

final customLayoutsProvider = FutureProvider<List<CustomLayout>>((ref) {
  final customizationService = ref.watch(advancedCustomizationServiceProvider);
  return customizationService.getCustomLayouts();
});

final dashboardCustomizationProvider = FutureProvider<DashboardCustomization>((
  ref,
) {
  final customizationService = ref.watch(advancedCustomizationServiceProvider);
  return customizationService.getDashboardCustomization();
});

final fontCustomizationProvider = FutureProvider<FontCustomization>((ref) {
  final customizationService = ref.watch(advancedCustomizationServiceProvider);
  return customizationService.getFontCustomization();
});

final animationPreferencesProvider = FutureProvider<AnimationPreferences>((
  ref,
) {
  final customizationService = ref.watch(advancedCustomizationServiceProvider);
  return customizationService.getAnimationPreferences();
});
