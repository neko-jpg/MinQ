import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/data/logging/minq_logger.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _simulateError(RecordErrorType type) {
    if (type != RecordErrorType.none) {
      MinqLogger.error(
        'record_flow_error',
        metadata: {'type': type.name, 'questId': widget.questId},
      );
    }
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
      body: _isLoading
          ? _RecordSkeleton(tokens: tokens)
          : Column(
              children: <Widget>[
                if (_showHelpBanner)
                  Card(
                    elevation: 0,
                    margin: EdgeInsets.all(tokens.spacing(5)),
                    color: tokens.brandPrimary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: tokens.cornerLarge()),
                    child: ListTile(
                      leading:
                          Icon(Icons.info_outline, color: tokens.brandPrimary),
                      title: Text(
                        'Questを完了したら、証拠として写真か自己申告を選択してRecordしよう。',
                        style: tokens.bodySmall
                            .copyWith(color: tokens.textPrimary),
                      ),
                      subtitle: Text(
                        'カメラ許可は証跡撮影のみに使用され、通知許可はリマインダー配信のためだけに使われます。',
                        style:
                            tokens.labelSmall.copyWith(color: tokens.textMuted),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.close, color: tokens.textPrimary),
                        onPressed: () =>
                            setState(() => _showHelpBanner = false),
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
                        onSwitchMode: () =>
                            _simulateError(RecordErrorType.none),
                      ),
                  },
                ),
              ],
            ),
    );
  }
}

class _RecordSkeleton extends StatelessWidget {
  const _RecordSkeleton({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.spacing(5)),
      children: <Widget>[
        MinqSkeleton(
          height: tokens.spacing(12),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(5)),
        const MinqSkeletonLine(width: 140, height: 22),
        SizedBox(height: tokens.spacing(3)),
        MinqSkeleton(
          height: tokens.spacing(18),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(6)),
        const MinqSkeletonLine(width: 110, height: 22),
        SizedBox(height: tokens.spacing(4)),
        const MinqSkeletonList(itemCount: 2, itemHeight: 56),
        SizedBox(height: tokens.spacing(5)),
        const MinqSkeletonLine(width: 200, height: 18),
        SizedBox(height: tokens.spacing(3)),
        const MinqSkeletonList(itemCount: 3, itemHeight: 44),
      ],
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

class _ProofButton extends StatefulWidget {
  const _ProofButton({
    required this.text,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final bool isPrimary;
  final AsyncCallback onTap;

  @override
  State<_ProofButton> createState() => _ProofButtonState();
}

class _ProofButtonState extends State<_ProofButton>
    with AsyncActionState<_ProofButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final Color background =
        widget.isPrimary ? tokens.brandPrimary : tokens.surface;
    final Color foreground =
        widget.isPrimary ? tokens.surface : tokens.textPrimary;
    final BorderSide borderSide = widget.isPrimary
        ? BorderSide.none
        : BorderSide(color: tokens.brandPrimary.withValues(alpha: 0.24));

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: tokens.spacing(18),
        minWidth: tokens.spacing(18),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          minimumSize: Size(double.infinity, tokens.spacing(18)),
          padding: EdgeInsets.symmetric(
            vertical: tokens.spacing(4),
            horizontal: tokens.spacing(4),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: tokens.cornerLarge(),
            side: borderSide,
          ),
          elevation: widget.isPrimary ? 4 : 0,
          shadowColor: widget.isPrimary
              ? tokens.brandPrimary.withValues(alpha: 0.32)
              : Colors.transparent,
        ),
        onPressed: isProcessing
            ? null
            : () => runGuarded(() async {
                  await widget.onTap();
                }),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: isProcessing
              ? SizedBox(
                  key: const ValueKey<String>('progress'),
                  height: tokens.spacing(6),
                  width: tokens.spacing(6),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                )
              : Column(
                  key: const ValueKey<String>('content'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(widget.icon, size: tokens.spacing(9)),
                    SizedBox(height: tokens.spacing(3)),
                    Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: tokens.bodyMedium.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
