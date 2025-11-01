import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/providers/regional_providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Widget that demonstrates regional and cultural features
class RegionalDemoWidget extends ConsumerWidget {
  const RegionalDemoWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final isRTL = ref.watch(isRTLProvider);
    final greeting = ref.watch(greetingProvider);
    final currentTime = ref.watch(currentTimeProvider);
    final upcomingHolidays = ref.watch(upcomingHolidaysProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with cultural greeting
            Row(
              children: [
                Icon(
                  ref.watch(culturalIconProvider('luck')),
                  color: ref.watch(culturalColorProvider('lucky')),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    greeting,
                    style: theme.textTheme.titleMedium,
                    textAlign: ref.watch(textAlignmentProvider),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Current time in local timezone
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Time:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  Text(
                    ref.watch(timeFormatterProvider(currentTime)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Sample currency formatting
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sample Price:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  Text(
                    ref.watch(currencyFormatterProvider(99.99)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ref.watch(culturalColorProvider('prosperity')),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Number formatting demo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Large Number:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  Text(
                    ref.watch(numberFormatterProvider(1234567)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Cultural colors demonstration
            Text(
              'Cultural Colors:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                _buildColorDemo(ref, 'Lucky', 'lucky'),
                const SizedBox(width: 8),
                _buildColorDemo(ref, 'Celebration', 'celebration'),
                const SizedBox(width: 8),
                _buildColorDemo(ref, 'Prosperity', 'prosperity'),
              ],
            ),

            const SizedBox(height: 16),

            // Lucky/Unlucky numbers
            _buildNumbersDemo(ref, theme, tokens),

            const SizedBox(height: 16),

            // Upcoming holidays
            if (upcomingHolidays.isNotEmpty) ...[
              Text(
                'Upcoming Holidays:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: tokens.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              ...upcomingHolidays.map(
                (holiday) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 16,
                        color: ref.watch(culturalColorProvider('celebration')),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${ref.watch(dateFormatterProvider(holiday.getDateForYear(DateTime.now().year)))} - ${holiday.name}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Motivational message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ref
                    .watch(culturalColorProvider('lucky'))
                    .withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: ref
                      .watch(culturalColorProvider('lucky'))
                      .withAlpha((255 * 0.3).round()),
                ),
              ),
              child: Text(
                ref.watch(motivationalMessagesProvider).first,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: ref.watch(textAlignmentProvider),
              ),
            ),

            // RTL indicator
            if (isRTL) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(
                    (255 * 0.1).round(),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.format_textdirection_r_to_l,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'RTL Layout Active',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorDemo(WidgetRef ref, String label, String concept) {
    final color = ref.watch(culturalColorProvider(concept));

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withAlpha((255 * 0.3).round()),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildNumbersDemo(WidgetRef ref, ThemeData theme, MinqTheme tokens) {
    final culturalNumbers = ref.watch(culturalNumbersProvider);

    if (culturalNumbers.lucky.isEmpty && culturalNumbers.unlucky.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cultural Numbers:',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: tokens.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        if (culturalNumbers.lucky.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: ref.watch(culturalColorProvider('lucky')),
              ),
              const SizedBox(width: 4),
              Text(
                'Lucky: ${culturalNumbers.lucky.join(', ')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
        ],

        if (culturalNumbers.unlucky.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.warning,
                size: 16,
                color: ref.watch(culturalColorProvider('unlucky')),
              ),
              const SizedBox(width: 4),
              Text(
                'Unlucky: ${culturalNumbers.unlucky.join(', ')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
