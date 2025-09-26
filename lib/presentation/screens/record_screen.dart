import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

enum RecordErrorType { none, offline, permissionDenied, cameraFailure }

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, required this.questId});

  final int questId;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  RecordErrorType _error = RecordErrorType.none;
  bool _showHelpBanner = true;

  void _simulateError(RecordErrorType type) {
    setState(() => _error = type);
  }

  Future<void> _requestPermissions() async {
    _simulateError(RecordErrorType.none);
  }

  Future<void> _retryUpload() async {
    _simulateError(RecordErrorType.none);
  }

  Future<void> _openSettings() async {
    _simulateError(RecordErrorType.none);
  }

  Future<void> _openOfflineQueue() async {
    _simulateError(RecordErrorType.none);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'Record',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: <Widget>[
          if (_showHelpBanner)
            Card(
              elevation: 0,
              margin: EdgeInsets.all(tokens.spacing(5)),
              color: tokens.brandPrimary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: tokens.cornerLarge()),
              child: ListTile(
                leading: Icon(Icons.info_outline, color: tokens.brandPrimary),
                title: Text(
                  'Questを完了したら、証拠として写真か自己申告を選択してRecordしよう。',
                  style: tokens.bodySmall
                      .copyWith(color: tokens.textPrimary),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: tokens.textPrimary),
                  onPressed: () => setState(() => _showHelpBanner = false),
                ),
              ),
            ),
          Expanded(
            child: switch (_error) {
              RecordErrorType.none => _RecordForm(
                  questId: widget.questId, onSimulate: _simulateError),
              RecordErrorType.offline => _OfflineRecovery(
                onRetry: _retryUpload,
                onOpenQueue: _openOfflineQueue,
              ),
              RecordErrorType.permissionDenied => _PermissionRecovery(
                onRequest: _requestPermissions,
                onOpenSettings: _openSettings,
              ),
              RecordErrorType.cameraFailure => _CameraRecovery(
                onRetry: _retryUpload,
                onSwitchMode: () => _simulateError(RecordErrorType.none),
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _RecordForm extends ConsumerWidget {
  const _RecordForm({required this.questId, required this.onSimulate});

  final int questId;
  final void Function(RecordErrorType) onSimulate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return ListView(
      padding: EdgeInsets.all(tokens.spacing(5)),
      children: <Widget>[
        SizedBox(height: tokens.spacing(4)),
        Text(
          'Quest',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        SizedBox(height: tokens.spacing(3)),
        _buildQuestInfoCard(tokens),
        SizedBox(height: tokens.spacing(8)),
        Text(
          'Proof',
          style: tokens.titleMedium.copyWith(color: tokens.textPrimary),
        ),
        SizedBox(height: tokens.spacing(4)),
        _buildProofButtons(context, ref, tokens),
        SizedBox(height: tokens.spacing(6)),
        Text(
          'デバッグ: エラーを再現',
          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
        ),
        Wrap(
          spacing: tokens.spacing(2),
          children: <Widget>[
            OutlinedButton(
              onPressed: () => onSimulate(RecordErrorType.offline),
              child: const Text('オフライン'),
            ),
            OutlinedButton(
              onPressed: () => onSimulate(RecordErrorType.permissionDenied),
              child: const Text('権限拒否'),
            ),
            OutlinedButton(
              onPressed: () => onSimulate(RecordErrorType.cameraFailure),
              child: const Text('カメラ失敗'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuestInfoCard(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withValues(alpha: 0.08),
        borderRadius: tokens.cornerLarge(),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: tokens.spacing(14),
            height: tokens.spacing(14),
            decoration: BoxDecoration(
              color: tokens.brandPrimary.withValues(alpha: 0.2),
              borderRadius: tokens.cornerMedium(),
            ),
            child: Icon(
              Icons.spa_outlined,
              color: tokens.brandPrimary,
              size: tokens.spacing(9),
            ),
          ),
          SizedBox(width: tokens.spacing(4)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Meditate',
                style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
              ),
              SizedBox(height: tokens.spacing(1)),
              Text(
                '10 minutes',
                style: tokens.bodySmall.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProofButtons(
      BuildContext context, WidgetRef ref, MinqTheme tokens) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      mainAxisSpacing: tokens.spacing(4),
      crossAxisSpacing: tokens.spacing(4),
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.9,
      children: <Widget>[
        _ProofButton(
          text: 'Capture Photo',
          icon: Icons.photo_camera_outlined,
          isPrimary: true,
          onTap: () async {
            final log = QuestLog()
              ..uid = ref.read(uidProvider) ?? ''
              ..questId = questId
              ..ts = DateTime.now().toUtc()
              ..proofType = ProofType.photo
              ..proofValue = 'path/to/photo.jpg' // Placeholder
              ..synced = false;
            await ref.read(questLogRepositoryProvider).addLog(log);
            context.go('/celebration');
          },
        ),
        _ProofButton(
          text: 'Self-declare',
          icon: Icons.check_circle_outline,
          isPrimary: false,
          onTap: () async {
            final log = QuestLog()
              ..uid = ref.read(uidProvider) ?? ''
              ..questId = questId
              ..ts = DateTime.now().toUtc()
              ..proofType = ProofType.check
              ..synced = false;
            await ref.read(questLogRepositoryProvider).addLog(log);
            context.go('/celebration');
          },
        ),
      ],
    );
  }
}
