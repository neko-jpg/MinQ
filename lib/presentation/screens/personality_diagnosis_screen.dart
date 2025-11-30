import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/habit_dna/habit_dna_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/habit_dna/habit_archetype.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class PersonalityDiagnosisScreen extends ConsumerStatefulWidget {
  const PersonalityDiagnosisScreen({super.key});

  @override
  ConsumerState<PersonalityDiagnosisScreen> createState() =>
      _PersonalityDiagnosisScreenState();
}

class _PersonalityDiagnosisScreenState
    extends ConsumerState<PersonalityDiagnosisScreen> {
  bool _isLoading = true;
  HabitArchetype? _archetype;
  List<String> _strategies = [];

  @override
  void initState() {
    super.initState();
    _loadDiagnosis();
  }

  Future<void> _loadDiagnosis() async {
    final uid = ref.read(uidProvider);
    if (uid == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final service = ref.read(habitDNAServiceProvider);
      final archetype = await service.determineArchetype(uid);

      if (mounted) {
        setState(() {
          _archetype = archetype;
          if (archetype != null) {
            _strategies = service.getArchetypeStrategies(archetype);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          '習慣DNA診断',
          style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: tokens.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: tokens.textPrimary),
      ),
      body: _buildBody(tokens),
    );
  }

  Widget _buildBody(MinqTheme tokens) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: tokens.brandPrimary),
      );
    }

    if (_archetype == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing(4)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: tokens.textMuted),
              SizedBox(height: tokens.spacing(3)),
              Text(
                'データが不足しています',
                style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: tokens.spacing(2)),
              Text(
                '習慣DNAを解析するには、\n少なくとも10回のクエスト完了が必要です。',
                textAlign: TextAlign.center,
                style: tokens.bodyMedium.copyWith(color: tokens.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildArchetypeCard(tokens, _archetype!),
          SizedBox(height: tokens.spacing(4)),
          Text(
            'あなたへのアドバイス',
            style: tokens.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: tokens.spacing(2)),
          ..._strategies.map((s) => _buildStrategyCard(tokens, s)),
        ],
      ),
    );
  }

  Widget _buildArchetypeCard(MinqTheme tokens, HabitArchetype archetype) {
    return Card(
      elevation: 4,
      shadowColor: tokens.brandPrimary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          children: [
            Text(
              'あなたは...',
              style: tokens.bodyMedium.copyWith(color: tokens.textSecondary),
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              archetype.name,
              style: tokens.displaySmall.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: tokens.spacing(2)),
            Text(
              archetype.description,
              textAlign: TextAlign.center,
              style: tokens.bodyLarge.copyWith(height: 1.5),
            ),
            SizedBox(height: tokens.spacing(3)),
            Wrap(
              spacing: tokens.spacing(2),
              runSpacing: tokens.spacing(2),
              alignment: WrapAlignment.center,
              children:
                  archetype.strengths
                      .map(
                        (s) => Chip(
                          label: Text(s),
                          backgroundColor: tokens.brandPrimary.withOpacity(0.1),
                          labelStyle: TextStyle(color: tokens.brandPrimary),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyCard(MinqTheme tokens, String text) {
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing(2)),
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerMedium()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: tokens.accentSecondary,
              size: 20,
            ),
            SizedBox(width: tokens.spacing(2)),
            Expanded(child: Text(text, style: tokens.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
