import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class ProfileManagementScreen extends ConsumerStatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  ConsumerState<ProfileManagementScreen> createState() =>
      _ProfileManagementScreenState();
}

class _ProfileManagementScreenState
    extends ConsumerState<ProfileManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _handleController = TextEditingController();
  final _bioController = TextEditingController();
  List<String> _selectedTags = <String>[];
  String _avatarSeed = 'seed-01';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = await ref.read(localUserProvider.future);
    if (!mounted || user == null) return;

    setState(() {
      _displayNameController.text = user.displayName;
      _handleController.text = user.handle ?? '';
      _bioController.text = user.bio;
      _avatarSeed = user.avatarSeed.isEmpty ? 'seed-01' : user.avatarSeed;
      _selectedTags = List<String>.from(user.focusTags);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final currentUser = ref.watch(localUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: const Text('Edit profile'),
        backgroundColor: tokens.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing.lg,
              vertical: tokens.spacing.lg,
            ),
            children: [
              _AvatarSelector(
                displayName: currentUser?.displayName ?? '',
                selectedSeed: _avatarSeed,
                onChanged: (seed) => setState(() => _avatarSeed = seed),
              ),
              SizedBox(height: tokens.spacing.xl),
              _SectionContainer(
                title: 'Profile details',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        hintText: 'e.g. Taylor Brooks',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Please enter a display name.';
                        }
                        if (trimmed.length > 30) {
                          return 'Use 30 characters or fewer.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: tokens.spacing.md),
                    TextFormField(
                      controller: _handleController,
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        prefixText: '@',
                        hintText: '3-20 characters, letters, numbers, _',
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) return null;
                        final pattern = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
                        if (!pattern.hasMatch(trimmed)) {
                          return 'Use 3-20 letters, numbers, or _.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: tokens.spacing.md),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Short bio',
                        hintText: 'Share what you are focusing on right now.',
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value != null && value.length > 160) {
                          return 'Use 160 characters or fewer.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.spacing.xl),
              _SectionContainer(
                title: 'Focus tags',
                subtitle: 'Select up to five tags that describe your goals.',
                child: _TagSelector(
                  selected: _selectedTags,
                  onChanged: (tags) => setState(() => _selectedTags = tags),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(uidProvider);
    if (uid == null) {
      _showSnackBar('Unable to resolve the current user.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(userRepositoryProvider)
          .upsertProfile(
            uid,
            displayName: _displayNameController.text.trim(),
            handle: _handleController.text.trim(),
            bio: _bioController.text.trim(),
            avatarSeed: _avatarSeed,
            focusTags: _selectedTags.take(5).toList(),
          );
      if (!mounted) return;
      ref.invalidate(localUserProvider);
      _showSnackBar('Profile saved.');
      context.pop();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar('Saving failed. Please try again later.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
  }
}

class _AvatarSelector extends StatelessWidget {
  const _AvatarSelector({
    required this.displayName,
    required this.selectedSeed,
    required this.onChanged,
  });

  final String displayName;
  final String selectedSeed;
  final ValueChanged<String> onChanged;

  static const List<String> _seeds = [
    'seed-01',
    'seed-02',
    'seed-03',
    'seed-04',
    'seed-05',
    'seed-06',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final initials = _initials(displayName);

    return Column(
      children: [
        Text(
          'Avatar',
          style: tokens.typography.h4.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: tokens.spacing.md),
        Wrap(
          spacing: tokens.spacing.md,
          runSpacing: tokens.spacing.md,
          alignment: WrapAlignment.center,
          children:
              _seeds
                  .map(
                    (seed) => GestureDetector(
                      onTap: () => onChanged(seed),
                      child: _AvatarPreview(
                        seed: seed,
                        isSelected: seed == selectedSeed,
                        initials: initials,
                      ),
                    ),
                  )
                  .toList(),
        ),
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
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.seed,
    required this.isSelected,
    required this.initials,
  });

  final String seed;
  final bool isSelected;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = _colorForSeed(tokens, seed);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, tokens.brandPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isSelected ? tokens.shadow.strong : tokens.shadow.soft,
        border: Border.all(
          color: isSelected ? tokens.primaryForeground : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: tokens.typography.h3.copyWith(
            color: tokens.primaryForeground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Color _colorForSeed(MinqTheme tokens, String seed) {
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

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
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
          if (subtitle != null) ...[
            SizedBox(height: tokens.spacing.xs),
            Text(
              subtitle!,
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.textMuted,
              ),
            ),
          ],
          SizedBox(height: tokens.spacing.md),
          child,
        ],
      ),
    );
  }
}

class _TagSelector extends StatelessWidget {
  const _TagSelector({required this.selected, required this.onChanged});

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  static const List<String> _availableTags = [
    'Productivity',
    'Health',
    'Learning',
    'Reading',
    'Languages',
    'Creative',
    'Fitness',
    'Mindfulness',
    'Home',
    'Career',
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Wrap(
      spacing: tokens.spacing.sm,
      runSpacing: tokens.spacing.sm,
      children:
          _availableTags.map((tag) {
            final isSelected = selected.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (value) {
                final next = List<String>.from(selected);
                if (value) {
                  if (next.length >= 5) return;
                  next.add(tag);
                } else {
                  next.remove(tag);
                }
                onChanged(next);
              },
            );
          }).toList(),
    );
  }
}
