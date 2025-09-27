import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/pair/pair.dart';
import 'package:minq/presentation/common/animated_tap.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

final userPairProvider = StreamProvider<Pair?>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return Stream.value(null);
  // TODO: Handle null repository gracefully
  return ref.watch(pairRepositoryProvider)!.getPairStreamForUser(uid);
});

class PairScreen extends ConsumerWidget {
  const PairScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final pairAsync = ref.watch(userPairProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Pair', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: MinqIconButton(icon: Icons.close, onTap: () => context.pop()),
        backgroundColor: tokens.background.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: pairAsync.when(
        data: (pair) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: pair != null
              ? _PairedView(key: ValueKey(pair.id), pairId: pair.id)
              : const _UnpairedView(key: ValueKey('unpaired')), 
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _PairedView extends ConsumerWidget {
  const _PairedView({super.key, required this.pairId});

  final String pairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    // TODO: Handle null repository gracefully
    final pairStream = ref.watch(pairRepositoryProvider)!.getPairStream(pairId);

    return StreamBuilder<DocumentSnapshot>(
      stream: pairStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final pair = Pair.fromSnapshot(snapshot.data!);

        final canHighFive = pair.lastHighfiveAt == null || DateTime.now().difference(pair.lastHighfiveAt!).inHours >= 24;

        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacing(5)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: tokens.spacing(5)),
              CircleAvatar(
                radius: tokens.spacing(16),
                backgroundColor: tokens.brandPrimary.withOpacity(0.12),
                child: Icon(Icons.person_off_outlined, size: tokens.spacing(16), color: tokens.brandPrimary),
              ),
              SizedBox(height: tokens.spacing(4)),
              Text('Anonymous Partner', style: tokens.titleMedium.copyWith(color: tokens.textPrimary)),
              SizedBox(height: tokens.spacing(1)),
              Text('Paired for "${pair.category}" Quest', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
              SizedBox(height: tokens.spacing(8)),
              MinqPrimaryButton(
                label: canHighFive ? 'High Five!' : 'High Five Sent',
                onPressed: canHighFive ? () async {
                  final uid = ref.read(uidProvider);
                  if (uid == null) return;
                  // TODO: Handle null repository gracefully
                  await ref.read(pairRepositoryProvider)!.sendHighFive(pairId, uid);
                } : null,
              ),
              SizedBox(height: tokens.spacing(10)),
              Text('Send a quick message:', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
              SizedBox(height: tokens.spacing(4)),
              Wrap(
                spacing: tokens.spacing(3),
                runSpacing: tokens.spacing(3),
                alignment: WrapAlignment.center,
                children: [
                  _QuickMessageChip(text: "You're doing great!", onTap: () => _sendQuickMessage(ref, pairId, "You're doing great!")),
                  _QuickMessageChip(text: 'Keep it up!', onTap: () => _sendQuickMessage(ref, pairId, 'Keep it up!')),
                  _QuickMessageChip(text: "Let's finish strong.", onTap: () => _sendQuickMessage(ref, pairId, "Let's finish strong.")),
                  _QuickMessageChip(text: 'I completed my goal!', onTap: () => _sendQuickMessage(ref, pairId, 'I completed my goal!')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendQuickMessage(WidgetRef ref, String pairId, String message) async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;
    // TODO: Handle null repository gracefully
    await ref.read(pairRepositoryProvider)!.sendQuickMessage(pairId, uid, message);
  }
}

class _QuickMessageChip extends StatelessWidget {
  const _QuickMessageChip({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ActionChip(
      label: Text(text, style: tokens.bodySmall.copyWith(color: tokens.brandPrimary, fontWeight: FontWeight.w600)),
      onPressed: onTap,
      backgroundColor: tokens.surface,
      side: BorderSide(color: tokens.brandPrimary.withOpacity(0.4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radiusLarge)),
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing(3), vertical: tokens.spacing(2)),
    );
  }
}


class _UnpairedView extends ConsumerStatefulWidget {
  const _UnpairedView({super.key});

  @override
  ConsumerState<_UnpairedView> createState() => _UnpairedViewState();
}

class _UnpairedViewState extends ConsumerState<_UnpairedView> {
  final _inviteCodeController = TextEditingController();
  String _selectedAgeRange = '18-24';
  String _selectedCategory = 'Fitness';

  Future<void> _joinWithInvite() async {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an invite code.')));
      return;
    }
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    // TODO: Handle null repository gracefully
    final pairId = await ref.read(pairRepositoryProvider)!.joinByInvitation(code, uid);
    if (mounted && pairId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid invite code.')));
    }
  }

  Future<void> _findRandomPartner() async {
    final uid = ref.read(uidProvider);
    if (uid == null) return;

    // TODO: Handle null repository gracefully
    final pairId = await ref.read(pairRepositoryProvider)!.requestRandomPair(uid, _selectedCategory);
    if (mounted && pairId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No partner found yet. You have been added to the queue.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ListView(
      padding: EdgeInsets.all(tokens.spacing(6)),
      children: [
        _buildHeader(tokens),
        SizedBox(height: tokens.spacing(8)),
        _buildInviteCodeInput(tokens),
        SizedBox(height: tokens.spacing(6)),
        _buildDivider(tokens),
        SizedBox(height: tokens.spacing(6)),
        _buildRandomMatchForm(tokens),
        SizedBox(height: tokens.spacing(8)),
        MinqPrimaryButton(label: 'Find a Partner', onPressed: _findRandomPartner),
      ],
    );
  }

  Widget _buildHeader(MinqTheme tokens) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: tokens.spacing(10), color: tokens.brandPrimary),
            SizedBox(width: tokens.spacing(2)),
            Icon(Icons.add, size: tokens.spacing(6), color: tokens.textMuted),
            SizedBox(width: tokens.spacing(2)),
            Icon(Icons.help_outline, size: tokens.spacing(10), color: tokens.brandPrimary),
          ],
        ),
        SizedBox(height: tokens.spacing(4)),
        Text('Power Up with a Partner!', style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        SizedBox(height: tokens.spacing(2)),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            children: [
              const TextSpan(text: 'Having an accountability partner increases your chance of success by '),
              TextSpan(text: '95%', style: TextStyle(color: tokens.brandPrimary, fontWeight: FontWeight.bold)),
              const TextSpan(text: '. Stay anonymous and motivated.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInviteCodeInput(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(5)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerXLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Have an invite code?', style: tokens.bodyMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
          SizedBox(height: tokens.spacing(2)),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inviteCodeController,
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    filled: true,
                    fillColor: tokens.background,
                    border: OutlineInputBorder(borderRadius: tokens.cornerLarge(), borderSide: BorderSide(color: tokens.border)),
                    contentPadding: EdgeInsets.symmetric(horizontal: tokens.spacing(4)),
                  ),
                ),
              ),
              SizedBox(width: tokens.spacing(3)),
              ElevatedButton(
                onPressed: _joinWithInvite,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.brandPrimary.withOpacity(0.2),
                  foregroundColor: tokens.brandPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
                  padding: EdgeInsets.symmetric(horizontal: tokens.spacing(4), vertical: tokens.spacing(3.5)),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(MinqTheme tokens) {
    return Row(
      children: [
        Expanded(child: Divider(color: tokens.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing(3)),
          child: Text('OR', style: tokens.bodySmall.copyWith(color: tokens.textMuted, fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Divider(color: tokens.border, thickness: 1)),
      ],
    );
  }

  Widget _buildRandomMatchForm(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(5)),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: tokens.cornerXLarge(),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Get matched randomly', style: tokens.bodyMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
          SizedBox(height: tokens.spacing(4)),
          _buildDropdown(tokens, 'Age Range', ['18-24', '25-34', '35-44', '45+'], _selectedAgeRange, (val) => setState(() => _selectedAgeRange = val!)),
          SizedBox(height: tokens.spacing(4)),
          _buildDropdown(tokens, 'Goal Category', ['Fitness', 'Learning', 'Well-being', 'Productivity'], _selectedCategory, (val) => setState(() => _selectedCategory = val!)),
          SizedBox(height: tokens.spacing(4)),
          Text('Anonymity Guaranteed: Your partner will only know your age range and goal category. All communication happens inside the app.', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
        ],
      ),
    );
  }

  Widget _buildDropdown(MinqTheme tokens, String label, List<String> items, String currentValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tokens.bodySmall.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
        SizedBox(height: tokens.spacing(1)),
        DropdownButtonFormField<String>(
          value: currentValue,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: tokens.background,
            border: OutlineInputBorder(borderRadius: tokens.cornerLarge(), borderSide: BorderSide(color: tokens.border)),
          ),
        ),
      ],
    );
  }
}
