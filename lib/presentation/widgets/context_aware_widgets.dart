import 'package:flutter/material.dart' hide TimeOfDay;
import 'package:minq/core/context/context_aware_service.dart';

/// コンテキストアウェアなウィジェット集
class ContextAwareWidgets {
  ContextAwareWidgets._();

  /// コンテキストアウェアなコンテナ
  static Widget container({
    required Widget child,
    EdgeInsets? padding,
    bool adaptToContext = true,
  }) {
    return _ContextAwareContainer(
      padding: padding,
      adaptToContext: adaptToContext,
      child: child,
    );
  }

  /// コンテキストアウェアなカード
  static Widget card({
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
    bool adaptToContext = true,
  }) {
    return _ContextAwareCard(
      margin: margin,
      padding: padding,
      adaptToContext: adaptToContext,
      child: child,
    );
  }

  /// コンテキストアウェアなテキスト
  static Widget text(
    String text, {
    TextStyle? style,
    bool adaptToContext = true,
  }) {
    return _ContextAwareText(
      text,
      style: style,
      adaptToContext: adaptToContext,
    );
  }

  /// コンテキストアウェアなボタン
  static Widget button({
    required String text,
    required VoidCallback? onPressed,
    bool adaptToContext = true,
  }) {
    return _ContextAwareButton(
      text: text,
      onPressed: onPressed,
      adaptToContext: adaptToContext,
    );
  }
}

/// コンテキストアウェアなコンテナ
class _ContextAwareContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool adaptToContext;

  const _ContextAwareContainer({
    required this.child,
    this.padding,
    required this.adaptToContext,
  });

  @override
  Widget build(BuildContext context) {
    if (!adaptToContext) {
      return Container(padding: padding, child: child);
    }

    return ValueListenableBuilder<AppContext>(
      valueListenable: ContextAwareService.instance.currentContext,
      builder: (context, appContext, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          padding: padding,
          decoration: BoxDecoration(
            gradient: appContext.getBackgroundGradient(),
          ),
          child: child,
        );
      },
    );
  }
}

/// コンテキストアウェアなカード
class _ContextAwareCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool adaptToContext;

  const _ContextAwareCard({
    required this.child,
    this.margin,
    this.padding,
    required this.adaptToContext,
  });

  @override
  Widget build(BuildContext context) {
    if (!adaptToContext) {
      return Card(
        margin: margin,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      );
    }

    return ValueListenableBuilder<AppContext>(
      valueListenable: ContextAwareService.instance.currentContext,
      builder: (context, appContext, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          margin: margin ?? const EdgeInsets.all(8),
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getCardColor(appContext, context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: appContext.getPrimaryColor().withAlpha(
                  (255 * 0.1).round(),
                ),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  Color _getCardColor(AppContext appContext, BuildContext context) {
    final baseColor = Theme.of(context).cardColor;
    final primaryColor = appContext.getPrimaryColor();

    // 時間帯に応じてカードの色を微調整
    switch (appContext.timeOfDay) {
      case TimeOfDay.morning:
        return Color.lerp(baseColor, primaryColor, 0.05)!;
      case TimeOfDay.afternoon:
        return baseColor;
      case TimeOfDay.evening:
        return Color.lerp(baseColor, primaryColor, 0.03)!;
      case TimeOfDay.night:
        return Color.lerp(baseColor, Colors.black, 0.1)!;
    }
  }
}

/// コンテキストアウェアなテキスト
class _ContextAwareText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool adaptToContext;

  const _ContextAwareText(
    this.text, {
    this.style,
    required this.adaptToContext,
  });

  @override
  Widget build(BuildContext context) {
    if (!adaptToContext) {
      return Text(text, style: style);
    }

    return ValueListenableBuilder<AppContext>(
      valueListenable: ContextAwareService.instance.currentContext,
      builder: (context, appContext, _) {
        return AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 400),
          style: _getTextStyle(appContext, context),
          child: Text(text),
        );
      },
    );
  }

  TextStyle _getTextStyle(AppContext appContext, BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    final primaryColor = appContext.getPrimaryColor();

    // 時間帯に応じてテキストの色を調整
    Color textColor;
    switch (appContext.timeOfDay) {
      case TimeOfDay.morning:
        textColor = Color.lerp(baseStyle.color, primaryColor, 0.2)!;
        break;
      case TimeOfDay.afternoon:
        textColor = baseStyle.color ?? Colors.black;
        break;
      case TimeOfDay.evening:
        textColor = Color.lerp(baseStyle.color, primaryColor, 0.15)!;
        break;
      case TimeOfDay.night:
        textColor = Color.lerp(baseStyle.color, Colors.white, 0.1)!;
        break;
    }

    return baseStyle.copyWith(color: textColor);
  }
}

/// コンテキストアウェアなボタン
class _ContextAwareButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool adaptToContext;

  const _ContextAwareButton({
    required this.text,
    required this.onPressed,
    required this.adaptToContext,
  });

  @override
  Widget build(BuildContext context) {
    if (!adaptToContext) {
      return ElevatedButton(onPressed: onPressed, child: Text(text));
    }

    return ValueListenableBuilder<AppContext>(
      valueListenable: ContextAwareService.instance.currentContext,
      builder: (context, appContext, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: appContext.getPrimaryColor(),
              foregroundColor: Colors.white,
              elevation: _getElevation(appContext),
              shadowColor: appContext.getPrimaryColor().withAlpha(
                (255 * 0.3).round(),
              ),
            ),
            child: Text(text),
          ),
        );
      },
    );
  }

  double _getElevation(AppContext appContext) {
    // 時間帯に応じてボタンの立体感を調整
    switch (appContext.timeOfDay) {
      case TimeOfDay.morning:
        return 4.0;
      case TimeOfDay.afternoon:
        return 2.0;
      case TimeOfDay.evening:
        return 6.0;
      case TimeOfDay.night:
        return 8.0;
    }
  }
}

/// コンテキスト情報表示ウィジェット
class ContextInfoWidget extends StatelessWidget {
  final bool showWeather;
  final bool showTime;
  final bool showRecommendations;

  const ContextInfoWidget({
    super.key,
    this.showWeather = true,
    this.showTime = true,
    this.showRecommendations = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppContext>(
      valueListenable: ContextAwareService.instance.currentContext,
      builder: (context, appContext, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // コンテキストメッセージ
                Text(
                  appContext.getContextualMessage(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: appContext.getPrimaryColor(),
                  ),
                ),

                const SizedBox(height: 12),

                // 時間情報
                if (showTime)
                  Row(
                    children: [
                      Icon(
                        _getTimeIcon(appContext.timeOfDay),
                        size: 16,
                        color: appContext.getPrimaryColor(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTimeLabel(appContext.timeOfDay),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),

                // 天気情報
                if (showWeather &&
                    appContext.weather.condition !=
                        WeatherCondition.unknown) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _getWeatherIcon(appContext.weather.condition),
                        size: 16,
                        color: appContext.getPrimaryColor(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${appContext.weather.temperature.toInt()}°C ${_getWeatherLabel(appContext.weather.condition)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],

                // 推奨習慣
                if (showRecommendations) ...[
                  const SizedBox(height: 12),
                  Text(
                    '今の時間におすすめ:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children:
                        appContext.getRecommendedHabits().map((habit) {
                          return Chip(
                            label: Text(
                              habit,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: appContext
                                .getPrimaryColor()
                                .withAlpha((255 * 0.1).round()),
                            side: BorderSide(
                              color: appContext.getPrimaryColor().withAlpha(
                                (255 * 0.3).round(),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getTimeIcon(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return Icons.wb_sunny;
      case TimeOfDay.afternoon:
        return Icons.wb_sunny_outlined;
      case TimeOfDay.evening:
        return Icons.wb_twilight;
      case TimeOfDay.night:
        return Icons.nights_stay;
    }
  }

  String _getTimeLabel(TimeOfDay timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return '朝';
      case TimeOfDay.afternoon:
        return '昼';
      case TimeOfDay.evening:
        return '夕方';
      case TimeOfDay.night:
        return '夜';
    }
  }

  IconData _getWeatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny;
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.rainy:
        return Icons.grain;
      case WeatherCondition.snowy:
        return Icons.ac_unit;
      case WeatherCondition.stormy:
        return Icons.flash_on;
      case WeatherCondition.foggy:
        return Icons.foggy;
      case WeatherCondition.unknown:
        return Icons.help_outline;
    }
  }

  String _getWeatherLabel(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return '晴れ';
      case WeatherCondition.cloudy:
        return '曇り';
      case WeatherCondition.rainy:
        return '雨';
      case WeatherCondition.snowy:
        return '雪';
      case WeatherCondition.stormy:
        return '嵐';
      case WeatherCondition.foggy:
        return '霧';
      case WeatherCondition.unknown:
        return '不明';
    }
  }
}

/// コンテキストアウェアなアプリバー
class ContextAwareAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool adaptToContext;

  const ContextAwareAppBar({
    super.key,
    required this.title,
    this.actions,
    this.adaptToContext = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!adaptToContext) {
      return AppBar(title: Text(title), actions: actions);
    }

    return ValueListenableBuilder<AppContext>(
      valueListenable: ContextAwareService.instance.currentContext,
      builder: (context, appContext, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                appContext.getPrimaryColor(),
                appContext.getPrimaryColor().withAlpha((255 * 0.8).round()),
              ],
            ),
          ),
          child: AppBar(
            title: Text(title),
            actions: actions,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
