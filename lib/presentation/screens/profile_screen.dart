import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/user/user.dart' as minq_user;
import 'package:minq/presentation/theme/minq_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final userAsync = ref.watch(localUserProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: tokens.background,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit profile',
            onPressed: () => context.push('/profile-management'),
          ),
        ],
      ),
      body: userAsync.when(
        data:
            (user) =>
                user == null
                    ? const _EmptyProfileView()
                    : _ProfileContent(user: user),
        error: (_, __) => const _ProfileErrorView(),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final minq_user.User user;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.lg,
        vertical: tokens.spacing.lg,
      ),
      children: [
        _ProfileHeader(user: user),
        SizedBox(height: tokens.spacing.xl),
        _StatsRow(user: user),
        if (user.bio.isNotEmpty) ...[
          SizedBox(height: tokens.spacing.xl),
          _SectionCard(
            title: 'About',
            child: Text(
              user.bio,
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
        SizedBox(height: tokens.spacing.xl),
        _SectionCard(
          title: 'Focus tags',
          child:
              user.focusTags.isEmpty
                  ? Text(
                    'No tags yet. Open the edit screen to add a few focus areas.',
                    style: tokens.typography.bodySmall.copyWith(
                      color: tokens.textMuted,
                    ),
                  )
                  : Wrap(
                    spacing: tokens.spacing.sm,
                    runSpacing: tokens.spacing.sm,
                    children:
                        user.focusTags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: tokens.brandPrimary.withAlpha(
                                  (255 * 0.12).round(),
                                ),
                                labelStyle: tokens.typography.bodySmall
                                    .copyWith(color: tokens.brandPrimary),
                              ),
                            )
                            .toList(),
                  ),
        ),
        SizedBox(height: tokens.spacing.xl),
        _SectionCard(
          title: 'Recent progress',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProgressRow(
                label: 'Current streak',
                value: '${user.currentStreak} days',
                progress: (user.currentStreak / 21).clamp(0.0, 1.0),
              ),
              SizedBox(height: tokens.spacing.md),
              _ProgressRow(
                label: 'Best streak',
                value: '${user.longestStreak} days',
                progress: (user.longestStreak / 30).clamp(0.0, 1.0),
              ),
              SizedBox(height: tokens.spacing.md),
              _ProgressRow(
                label: 'Total points',
                value: '${user.totalPoints} pts',
                progress: (user.totalPoints / 500).clamp(0.0, 1.0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final minq_user.User user;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final initials = _initials(user.displayName);
    final color = _avatarColor(tokens, user.avatarSeed);
    final handle =
        user.handle == null || user.handle!.isEmpty ? null : '@${user.handle}';

    return Column(
      children: [
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, tokens.brandPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: tokens.shadow.soft,
          ),
          child: Center(
            child: Text(
              initials,
              style: tokens.typography.h3.copyWith(
                color: tokens.primaryForeground,
                fontSize: 36,
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        Text(
          user.displayName.isEmpty ? 'Adventurer' : user.displayName,
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (handle != null) ...[
          SizedBox(height: tokens.spacing.xs),
          Text(
            handle,
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ],
    );
  }

  String _initials(String displayName) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return 'M';
    }
    final firstLetters =
        trimmed
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map(_firstLetter)
            .where((letter) => letter.isNotEmpty)
            .toList();
    if (firstLetters.isEmpty) {
      return 'M';
    }
    return firstLetters.join();
  }

  String _firstLetter(String value) {
    final iterator = value.runes.iterator;
    if (!iterator.moveNext()) {
      return '';
    }
    final first = String.fromCharCode(iterator.current);
    return first.toUpperCase();
  }

  Color _avatarColor(MinqTheme tokens, String seed) {
    final palette = <Color>[
      tokens.brandPrimary,
      tokens.accentSecondary,
      tokens.encouragement,
      tokens.serenity,
      tokens.warmth,
    ];
    final index = seed.hashCode.abs() % palette.length;
    return palette[index];
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.user});

  final minq_user.User user;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Level',
            value: user.currentLevel.toString(),
            icon: Icons.workspace_premium_outlined,
          ),
        ),
        SizedBox(width: tokens.spacing.md),
        Expanded(
          child: _StatTile(
            label: 'Points',
            value: user.totalPoints.toString(),
            icon: Icons.bolt_outlined,
          ),
        ),
        SizedBox(width: tokens.spacing.md),
        Expanded(
          child: _StatTile(
            label: 'Best streak',
            value: '${user.longestStreak} days',
            icon: Icons.local_fire_department_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        boxShadow: tokens.shadow.soft,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: tokens.brandPrimary),
          SizedBox(height: tokens.spacing.sm),
          Text(
            value,
            style: tokens.typography.h4.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            label,
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        boxShadow: tokens.shadow.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tokens.typography.h4.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          child,
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.progress,
  });

  final String label;
  final String value;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: tokens.typography.bodySmall.copyWith(
                  color: tokens.textMuted,
                ),
              ),
            ),
            Text(
              value,
              style: tokens.typography.bodyMedium.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radius.sm),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class _EmptyProfileView extends StatelessWidget {
  const _EmptyProfileView();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_empty, size: 48, color: tokens.textMuted),
          SizedBox(height: tokens.spacing.md),
          Text(
            'Could not find local profile data.',
            style: tokens.typography.bodyMedium.copyWith(
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: tokens.accentError),
          SizedBox(height: tokens.spacing.md),
          Text(
            'Unable to load profile. Please try again later.',
            style: tokens.typography.bodyMedium.copyWith(
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
