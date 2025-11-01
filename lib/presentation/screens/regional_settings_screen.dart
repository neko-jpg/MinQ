import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/i18n/cultural_adaptation_service.dart';
import 'package:minq/core/i18n/regional_service.dart';
import 'package:minq/core/i18n/timezone_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';
import 'package:minq/presentation/widgets/language_selector_widget.dart';

class RegionalSettingsScreen extends ConsumerStatefulWidget {
  const RegionalSettingsScreen({super.key});

  @override
  ConsumerState<RegionalSettingsScreen> createState() =>
      _RegionalSettingsScreenState();
}

class _RegionalSettingsScreenState
    extends ConsumerState<RegionalSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize timezone service
    TimezoneService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(appLocaleControllerProvider);
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Selection
            const LanguageSelectorWidget(),

            const SizedBox(height: 24),

            // Regional Information
            if (currentLocale != null) ...[
              _buildRegionalInfoCard(currentLocale, l10n, theme, tokens),
              const SizedBox(height: 24),
            ],

            // Cultural Preferences
            if (currentLocale != null) ...[
              _buildCulturalPreferencesCard(currentLocale, l10n, theme, tokens),
              const SizedBox(height: 24),
            ],

            // Timezone Information
            if (currentLocale != null) ...[
              _buildTimezoneCard(currentLocale, l10n, theme, tokens),
              const SizedBox(height: 24),
            ],

            // Format Examples
            if (currentLocale != null) ...[
              _buildFormatExamplesCard(currentLocale, l10n, theme, tokens),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRegionalInfoCard(
    Locale locale,
    AppLocalizations l10n,
    ThemeData theme,
    MinqTheme tokens,
  ) {
    final config = RegionalService.getRegionalConfig(locale);
    final holidays = RegionalService.getHolidays(DateTime.now().year, locale);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: MinqTokens.brandPrimary, size: 24),
                SizedBox(width: MinqTokens.spacing(2)),
                Text('Regional Information', style: MinqTokens.titleMedium),
              ],
            ),
            SizedBox(height: MinqTokens.spacing(4)),

            _buildInfoRow(
              'Currency',
              '${config.currency} (${config.currencySymbol})',
            ),
            _buildInfoRow('Date Format', config.dateFormat),
            _buildInfoRow('Time Format', config.timeFormat),
            _buildInfoRow(
              'Week Starts',
              _getWeekStartName(config.firstDayOfWeek),
            ),
            _buildInfoRow('Holidays This Year', '${holidays.length} holidays'),

            if (holidays.isNotEmpty) ...[
              SizedBox(height: MinqTokens.spacing(3)),
              Text(
                'Upcoming Holidays:',
                style: MinqTokens.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MinqTokens.textPrimary,
                ),
              ),
              SizedBox(height: MinqTokens.spacing(2)),
              ...holidays
                  .take(3)
                  .map(
                    (holiday) => Padding(
                      padding: EdgeInsets.only(bottom: MinqTokens.spacing(1)),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            size: 16,
                            color: MinqTokens.textSecondary,
                          ),
                          SizedBox(width: MinqTokens.spacing(1)),
                          Text(
                            '${RegionalService.formatDate(holiday.date, locale)} - ${holiday.name}',
                            style: MinqTokens.bodySmall.copyWith(
                              color: MinqTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCulturalPreferencesCard(
    Locale locale,
    AppLocalizations l10n,
    ThemeData theme,
    MinqTheme tokens,
  ) {
    final config = RegionalService.getRegionalConfig(locale);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: MinqTokens.brandPrimary, size: 24),
                SizedBox(width: MinqTokens.spacing(2)),
                Text('Cultural Preferences', style: MinqTokens.titleMedium),
              ],
            ),
            SizedBox(height: MinqTokens.spacing(4)),

            // Cultural Colors
            Text(
              'Cultural Colors:',
              style: MinqTokens.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: MinqTokens.textPrimary,
              ),
            ),
            SizedBox(height: MinqTokens.spacing(2)),

            Row(
              children: [
                _buildColorSwatch('Lucky', config.culturalColors.lucky),
                SizedBox(width: MinqTokens.spacing(2)),
                _buildColorSwatch(
                  'Celebration',
                  config.culturalColors.celebration,
                ),
                SizedBox(width: MinqTokens.spacing(2)),
                _buildColorSwatch(
                  'Prosperity',
                  config.culturalColors.prosperity,
                ),
              ],
            ),

            SizedBox(height: MinqTokens.spacing(3)),

            // Cultural Numbers
            if (config.culturalNumbers.lucky.isNotEmpty) ...[
              _buildInfoRow(
                'Lucky Numbers',
                config.culturalNumbers.lucky.join(', '),
              ),
            ],
            if (config.culturalNumbers.unlucky.isNotEmpty) ...[
              _buildInfoRow(
                'Unlucky Numbers',
                config.culturalNumbers.unlucky.join(', '),
              ),
            ],

            SizedBox(height: MinqTokens.spacing(3)),

            // Sample Messages
            Text(
              'Sample Messages:',
              style: MinqTokens.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: MinqTokens.textPrimary,
              ),
            ),
            SizedBox(height: MinqTokens.spacing(2)),

            Container(
              padding: EdgeInsets.all(MinqTokens.spacing(3)),
              decoration: BoxDecoration(
                color: MinqTokens.background,
                borderRadius: MinqTokens.cornerMedium(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Motivational: ${CulturalAdaptationService.getMotivationalMessages(locale).first}',
                    style: MinqTokens.bodySmall.copyWith(
                      color: MinqTokens.textSecondary,
                    ),
                  ),
                  SizedBox(height: MinqTokens.spacing(1)),
                  Text(
                    'Celebration: ${CulturalAdaptationService.getCelebrationMessages(locale).first}',
                    style: MinqTokens.bodySmall.copyWith(
                      color: MinqTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimezoneCard(
    Locale locale,
    AppLocalizations l10n,
    ThemeData theme,
    MinqTheme tokens,
  ) {
    final timezone = TimezoneService.getTimezoneForLocale(locale);
    final currentTime = TimezoneService.nowInTimezone(timezone);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: MinqTokens.brandPrimary,
                  size: 24,
                ),
                SizedBox(width: MinqTokens.spacing(2)),
                Text('Timezone Information', style: MinqTokens.titleMedium),
              ],
            ),
            SizedBox(height: MinqTokens.spacing(4)),

            _buildInfoRow('Timezone', timezone.name),
            _buildInfoRow(
              'Current Time',
              TimezoneService.formatWithTimezone(currentTime),
            ),
            _buildInfoRow(
              'UTC Offset',
              _formatOffset(currentTime.timeZoneOffset),
            ),
            _buildInfoRow(
              'Daylight Saving',
              TimezoneService.isDaylightSavingTime(currentTime)
                  ? 'Active'
                  : 'Inactive',
            ),

            SizedBox(height: MinqTokens.spacing(3)),

            Container(
              padding: EdgeInsets.all(MinqTokens.spacing(3)),
              decoration: BoxDecoration(
                color: MinqTokens.background,
                borderRadius: MinqTokens.cornerMedium(),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: MinqTokens.brandPrimary,
                  ),
                  SizedBox(width: MinqTokens.spacing(2)),
                  Expanded(
                    child: Text(
                      'Notifications and reminders will be scheduled according to your local timezone.',
                      style: MinqTokens.bodySmall.copyWith(
                        color: MinqTokens.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatExamplesCard(
    Locale locale,
    AppLocalizations l10n,
    ThemeData theme,
    MinqTheme tokens,
  ) {
    final now = DateTime.now();
    const sampleAmount = 1234.56;
    const sampleNumber = 1234567;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered,
                  color: MinqTokens.brandPrimary,
                  size: 24,
                ),
                SizedBox(width: MinqTokens.spacing(2)),
                Text('Format Examples', style: MinqTokens.titleMedium),
              ],
            ),
            SizedBox(height: MinqTokens.spacing(4)),

            _buildInfoRow('Date', RegionalService.formatDate(now, locale)),
            _buildInfoRow('Time', RegionalService.formatTime(now, locale)),
            _buildInfoRow(
              'Currency',
              RegionalService.formatCurrency(sampleAmount, locale),
            ),
            _buildInfoRow(
              'Number',
              CulturalAdaptationService.formatNumber(sampleNumber, locale),
            ),
            _buildInfoRow(
              'Greeting',
              CulturalAdaptationService.getTimeBasedGreeting(now, locale),
            ),

            SizedBox(height: MinqTokens.spacing(3)),

            // Text Direction Demo
            Container(
              padding: EdgeInsets.all(MinqTokens.spacing(3)),
              decoration: BoxDecoration(
                color: MinqTokens.background,
                borderRadius: MinqTokens.cornerMedium(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Text Direction:',
                    style: MinqTokens.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: MinqTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: MinqTokens.spacing(2)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(MinqTokens.spacing(2)),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: MinqTokens.textSecondary.withAlpha(
                          (255 * 0.3).round(),
                        ),
                      ),
                      borderRadius: MinqTokens.cornerSmall(),
                    ),
                    child: Text(
                      'Sample text in ${locale.languageCode.toUpperCase()}',
                      textAlign: CulturalAdaptationService.getTextAlignment(
                        locale,
                      ),
                      style: MinqTokens.bodySmall.copyWith(
                        color: MinqTokens.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: MinqTokens.spacing(2)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: MinqTokens.bodyMedium.copyWith(
              color: MinqTokens.textSecondary,
            ),
          ),
          Text(
            value,
            style: MinqTokens.bodyMedium.copyWith(
              color: MinqTokens.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: MinqTokens.textSecondary.withAlpha((255 * 0.3).round()),
            ),
          ),
        ),
        SizedBox(height: MinqTokens.spacing(1)),
        Text(
          label,
          style: MinqTokens.bodySmall.copyWith(color: MinqTokens.textSecondary),
        ),
      ],
    );
  }

  String _getWeekStartName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  String _formatOffset(Duration offset) {
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60);
    final sign = hours >= 0 ? '+' : '';
    return 'UTC$sign$hours:${minutes.abs().toString().padLeft(2, '0')}';
  }
}
