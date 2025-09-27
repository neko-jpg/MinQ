import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/data/services/photo_storage_service.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/data/services/image_moderation_service.dart';

enum RecordErrorType { none, offline, permissionDenied, cameraFailure }

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, required this.questId});

  final int questId;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  RecordErrorType _error = RecordErrorType.none;
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

  void _handleError(RecordErrorType type) {
    if (type != RecordErrorType.none) {
      MinqLogger.error(
        'record_flow_error',
        metadata: {'type': type.name, 'questId': widget.questId},
      );
    }
    setState(() => _error = type);
  }

  Future<void> _requestPermissions() async => _handleError(RecordErrorType.none);
  Future<void> _retryUpload() async => _handleError(RecordErrorType.none);
  Future<void> _openSettings() async => _handleError(RecordErrorType.none);
  Future<void> _openOfflineQueue() async => _handleError(RecordErrorType.none);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text('Record', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Center(
          child: MinqIconButton(
            icon: Icons.close,
            onTap: () => context.pop(),
          ),
        ),
      ),
      body: _isLoading
          ? _RecordSkeleton(tokens: tokens)
          : switch (_error) {
              RecordErrorType.none => _RecordForm(questId: widget.questId, onError: _handleError),
              RecordErrorType.offline => _OfflineRecovery(onRetry: _retryUpload, onOpenQueue: _openOfflineQueue),
              RecordErrorType.permissionDenied => _PermissionRecovery(onRequest: _requestPermissions, onOpenSettings: _openSettings),
              RecordErrorType.cameraFailure => _CameraRecovery(onRetry: _retryUpload, onSwitchMode: () => _handleError(RecordErrorType.none)),
            },
    );
  }
}

class _RecordSkeleton extends StatelessWidget {
  const _RecordSkeleton({required this.tokens});

  final MinqTheme tokens;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      children: <Widget>[
        const MinqSkeletonLine(width: 140, height: 28),
        SizedBox(height: tokens.spacing(3)),
        MinqSkeleton(height: tokens.spacing(22), borderRadius: tokens.cornerLarge()),
        SizedBox(height: tokens.spacing(8)),
        const MinqSkeletonLine(width: 110, height: 28),
        SizedBox(height: tokens.spacing(4)),
        Row(
          children: [
            Expanded(child: MinqSkeleton(height: tokens.spacing(40), borderRadius: tokens.cornerLarge())),
            SizedBox(width: tokens.spacing(4)),
            Expanded(child: MinqSkeleton(height: tokens.spacing(40), borderRadius: tokens.cornerLarge())),
          ],
        ),
      ],
    );
  }
}

class _RecordForm extends ConsumerWidget {
  const _RecordForm({required this.questId, required this.onError});

  final int questId;
  final void Function(RecordErrorType) onError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return ListView(
      padding: EdgeInsets.all(tokens.spacing(4)),
      children: <Widget>[
        SizedBox(height: tokens.spacing(4)),
        Text('Mini-Quest', style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        SizedBox(height: tokens.spacing(3)),
        _buildQuestInfoCard(tokens),
        SizedBox(height: tokens.spacing(8)),
        Text('Proof', style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
        SizedBox(height: tokens.spacing(4)),
        _buildProofButtons(context, ref, tokens),
      ],
    );
  }

  Widget _buildQuestInfoCard(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withOpacity(0.1),
        borderRadius: tokens.cornerLarge(),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: tokens.spacing(14),
            height: tokens.spacing(14),
            decoration: BoxDecoration(
              color: tokens.brandPrimary.withOpacity(0.2),
              borderRadius: tokens.cornerLarge(),
            ),
            child: Icon(Icons.spa, color: tokens.brandPrimary, size: tokens.spacing(8)),
          ),
          SizedBox(width: tokens.spacing(4)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Meditate', style: tokens.titleMedium.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
              SizedBox(height: tokens.spacing(1)),
              Text('10 minutes', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProofButtons(BuildContext context, WidgetRef ref, MinqTheme tokens) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 400;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: <Widget>[
            Expanded(
              child: _ProofButton(
                text: 'Take Photo',
                icon: Icons.photo_camera,
                isPrimary: true,
                onTap: () => _handlePhotoTap(context, ref),
              ),
            ),
            SizedBox(width: isWide ? tokens.spacing(4) : 0, height: isWide ? 0 : tokens.spacing(4)),
            Expanded(
              child: _ProofButton(
                text: 'Self-Declare',
                icon: Icons.check_circle,
                isPrimary: false,
                onTap: () => _handleSelfDeclareTap(context, ref),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePhotoTap(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Unable to record without a signed-in user.')));
      onError(RecordErrorType.permissionDenied);
      return;
    }
    try {
      final result = await ref.read(photoStorageServiceProvider).captureAndSanitize(ownerUid: uid, questId: questId);
      if (!result.hasFile) {
        messenger.showSnackBar(const SnackBar(content: Text('Photo capture cancelled.')));
        return;
      }

      final proceed = await _handleModerationWarning(context, result);
      if (!proceed) return;

      final log = QuestLog()
        ..uid = uid
        ..questId = questId
        ..ts = DateTime.now().toUtc()
        ..proofType = ProofType.photo
        ..proofValue = result.path
        ..synced = false;
      await ref.read(questLogRepositoryProvider).addLog(log);
      onError(RecordErrorType.none);
      if (context.mounted) context.go('/celebration');
    } on PhotoCaptureException catch (error) {
      switch (error.reason) {
        case PhotoCaptureFailure.permissionDenied:
          onError(RecordErrorType.permissionDenied);
          break;
        case PhotoCaptureFailure.cameraFailure:
          onError(RecordErrorType.cameraFailure);
          break;
      }
    } catch (_) {
      onError(RecordErrorType.cameraFailure);
    }
  }

  Future<void> _handleSelfDeclareTap(BuildContext context, WidgetRef ref) async {
    final log = QuestLog()
      ..uid = ref.read(uidProvider) ?? ''
      ..questId = questId
      ..ts = DateTime.now().toUtc()
      ..proofType = ProofType.check
      ..synced = false;
    await ref.read(questLogRepositoryProvider).addLog(log);
    if (context.mounted) context.go('/celebration');
  }
}

Future<bool> _handleModerationWarning(BuildContext context, PhotoCaptureResult result) async {
  if (result.moderationVerdict == PhotoModerationVerdict.ok) return true;

  final tokens = context.tokens;
  final message = switch (result.moderationVerdict) {
    PhotoModerationVerdict.tooDark => 'The captured photo looks very dark. Retake to keep your partner reassured?',
    PhotoModerationVerdict.tooBright => 'The captured photo is almost entirely bright. Would you like to retake it for clarity?',
    PhotoModerationVerdict.lowVariance => 'The image appears blurry or blank. Retake to provide clearer proof?',
    PhotoModerationVerdict.ok => '',
  };

  final proceed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Check your photo'),
      content: Text(message),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Retake')),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: tokens.brandPrimary, foregroundColor: Colors.white),
          child: const Text('Use photo'),
        ),
      ],
    ),
  ) ?? false;

  if (!proceed) {
    try {
      final file = File(result.path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Ignore cleanup errors.
    }
  }
  return proceed;
}

class _ProofButton extends StatefulWidget {
  const _ProofButton({required this.text, required this.icon, required this.isPrimary, required this.onTap});

  final String text;
  final IconData icon;
  final bool isPrimary;
  final AsyncCallback onTap;

  @override
  State<_ProofButton> createState() => _ProofButtonState();
}

class _ProofButtonState extends State<_ProofButton> with AsyncActionState<_ProofButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final Color background = widget.isPrimary ? tokens.brandPrimary : tokens.brandPrimary.withOpacity(0.1);
    final Color foreground = widget.isPrimary ? Colors.white : tokens.textPrimary;

    return SizedBox(
      height: 160,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
          elevation: 0,
        ),
        onPressed: isProcessing ? null : () => runGuarded(widget.onTap),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(opacity: animation, child: child),
          child: isProcessing
              ? SizedBox(
                  key: const ValueKey<String>('progress'),
                  height: tokens.spacing(7),
                  width: tokens.spacing(7),
                  child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(foreground)),
                )
              : Column(
                  key: const ValueKey<String>('content'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(widget.icon, size: tokens.spacing(10)),
                    SizedBox(height: tokens.spacing(2)),
                    Text(widget.text, style: tokens.titleMedium.copyWith(color: foreground, fontWeight: FontWeight.bold)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OfflineRecovery extends StatelessWidget {
  const _OfflineRecovery({required this.onRetry, required this.onOpenQueue});
  final VoidCallback onRetry;
  final VoidCallback onOpenQueue;

  @override
  Widget build(BuildContext context) {
    return MinqEmptyState(
      icon: Icons.wifi_off,
      title: 'You are offline',
      message: 'Your proof will be saved locally and uploaded when you reconnect.',
      actionArea: Column(
        children: [
          MinqPrimaryButton(label: 'Retry Upload', onPressed: () async => onRetry(), expand: false),
          SizedBox(height: 8),
          TextButton(onPressed: onOpenQueue, child: const Text('View Offline Queue')),
        ],
      ),
    );
  }
}

class _PermissionRecovery extends StatelessWidget {
  const _PermissionRecovery({required this.onRequest, required this.onOpenSettings});
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return MinqEmptyState(
      icon: Icons.camera_alt_outlined,
      title: 'Camera Access Needed',
      message: 'To capture photo proof, MinQ needs access to your camera.',
      actionArea: Column(
        children: [
          MinqPrimaryButton(label: 'Grant Access', onPressed: () async => onRequest(), expand: false),
          SizedBox(height: 8),
          TextButton(onPressed: onOpenSettings, child: const Text('Open Settings')),
        ],
      ),
    );
  }
}

class _CameraRecovery extends StatelessWidget {
  const _CameraRecovery({required this.onRetry, required this.onSwitchMode});
  final VoidCallback onRetry;
  final VoidCallback onSwitchMode;

  @override
  Widget build(BuildContext context) {
    return MinqEmptyState(
      icon: Icons.error_outline,
      title: 'Camera Error',
      message: 'There was an issue with the camera. Please try again.',
      actionArea: Column(
        children: [
          MinqPrimaryButton(label: 'Try Again', onPressed: () async => onRetry(), expand: false),
          SizedBox(height: 8),
          TextButton(onPressed: onSwitchMode, child: const Text('Self-Declare Instead')),
        ],
      ),
    );
  }
}