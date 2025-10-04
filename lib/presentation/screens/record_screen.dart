import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/acr_music_tagging_service.dart';
import 'package:minq/data/services/focus_music_service.dart';
import 'package:minq/data/services/image_moderation_service.dart';
import 'package:minq/data/services/photo_storage_service.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/presentation/controllers/quest_log_controller.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

enum RecordErrorType { none, offline, permissionDenied, cameraFailure }

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key, required this.questId});

  final int questId;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
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

  Future<void> _requestPermissions() async =>
      _handleError(RecordErrorType.none);
  Future<void> _retryUpload() async => _handleError(RecordErrorType.none);
  Future<void> _openSettings() async => _handleError(RecordErrorType.none);
  Future<void> _openOfflineQueue() async => _handleError(RecordErrorType.none);

  @override
  void dispose() {
    ref.read(focusMusicServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          '記録',
          style: tokens.titleMedium.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Center(
          child: MinqIconButton(icon: Icons.close, onTap: () => context.pop()),
        ),
      ),
      body:
          _isLoading
              ? _RecordSkeleton(tokens: tokens)
              : switch (_error) {
                RecordErrorType.none => _RecordForm(
                  questId: widget.questId,
                  onError: _handleError,
                ),
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
                  onSwitchMode: () => _handleError(RecordErrorType.none),
                ),
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
        MinqSkeleton(
          height: tokens.spacing(22),
          borderRadius: tokens.cornerLarge(),
        ),
        SizedBox(height: tokens.spacing(8)),
        const MinqSkeletonLine(width: 110, height: 28),
        SizedBox(height: tokens.spacing(4)),
        Row(
          children: [
            Expanded(
              child: MinqSkeleton(
                height: tokens.spacing(40),
                borderRadius: tokens.cornerLarge(),
              ),
            ),
            SizedBox(width: tokens.spacing(4)),
            Expanded(
              child: MinqSkeleton(
                height: tokens.spacing(40),
                borderRadius: tokens.cornerLarge(),
              ),
            ),
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
        Text(
          'ミニクエスチE,
          style: tokens.titleLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacing(3)),
        _buildQuestInfoCard(tokens),
        SizedBox(height: tokens.spacing(8)),
        const _FocusMusicPanel(),
        SizedBox(height: tokens.spacing(8)),
        Text(
          '証昁E,
          style: tokens.titleLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacing(4)),
        _buildProofButtons(context, ref, tokens),
      ],
    );
  }

  Widget _buildQuestInfoCard(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.brandPrimary.withValues(alpha: 0.1),
        borderRadius: tokens.cornerLarge(),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: tokens.spacing(14),
            height: tokens.spacing(14),
            decoration: BoxDecoration(
              color: tokens.brandPrimary.withValues(alpha: 0.2),
              borderRadius: tokens.cornerLarge(),
            ),
            child: Icon(
              Icons.spa,
              color: tokens.brandPrimary,
              size: tokens.spacing(8),
            ),
          ),
          SizedBox(width: tokens.spacing(4)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '瞑想',
                style: tokens.titleMedium.copyWith(
                  color: tokens.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: tokens.spacing(1)),
              Text(
                '10刁E,
                style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProofButtons(
    BuildContext context,
    WidgetRef ref,
    MinqTheme tokens,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 400;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: <Widget>[
            Expanded(
              child: _ProofButton(
                text: '写真を撮めE,
                icon: Icons.photo_camera,
                isPrimary: true,
                onTap: () => _handlePhotoTap(context, ref),
              ),
            ),
            SizedBox(
              width: isWide ? tokens.spacing(4) : 0,
              height: isWide ? 0 : tokens.spacing(4),
            ),
            Expanded(
              child: _ProofButton(
                text: '自己申呁E,
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
    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      FeedbackMessenger.showErrorSnackBar(
        context,
        'サインインしてぁE��ぁE��め記録できません、E,
      );
      onError(RecordErrorType.permissionDenied);
      return;
    }
    try {
      final result = await ref
          .read(photoStorageServiceProvider)
          .captureAndSanitize(ownerUid: uid, questId: questId);
      if (!result.hasFile) {
        FeedbackMessenger.showInfoToast(
          context,
          '写真の撮影がキャンセルされました、E,
        );
        return;
      }

      final proceed = await _handleModerationWarning(context, result);
      if (!proceed) return;

      final controller = ref.read(questLogControllerProvider.notifier);
      final success = await controller.recordProgress(
        questId, 
        proofValue: result.path, 
        proofType: ProofType.photo,
      );
      
      if (success) {
        onError(RecordErrorType.none);
        ref.read(navigationUseCaseProvider).goToCelebration();
        FeedbackManager.questCompleted();
      } else {
        onError(RecordErrorType.cameraFailure);
      }
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

  Future<void> _handleSelfDeclareTap(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = ref.read(questLogControllerProvider.notifier);
    final success = await controller.recordProgress(questId, proofType: ProofType.check);
    
    if (success) {
      ref.read(navigationUseCaseProvider).goToCelebration();
      FeedbackManager.questCompleted();
    } else {
      final error = ref.read(questLogControllerProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }
}

class _FocusMusicPanel extends ConsumerWidget {
  const _FocusMusicPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final PlayerState? playerState =
        ref.watch(focusMusicPlayerStateProvider).maybeWhen(
              data: (state) => state,
              orElse: () => null,
            );
    final service = ref.watch(focusMusicServiceProvider);
    final currentTrack = service.currentTrack;
    final isPlaying = playerState?.playing == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '雁E��BGM',
          style: tokens.titleLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacing(2)),
        Text(
          '習�Eを実行しながら流す音楽を選べます。�EチE��ホン推奨です、E,
          style: tokens.bodySmall.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing(3)),
        ...FocusMusicService.tracks.map(
          (track) => Padding(
            padding: EdgeInsets.only(bottom: tokens.spacing(2)),
            child: _FocusMusicTile(
              track: track,
              service: service,
              isActive: currentTrack?.id == track.id,
              isPlaying: currentTrack?.id == track.id && isPlaying,
            ),
          ),
        ),
        if (isPlaying)
          Padding(
            padding: EdgeInsets.only(top: tokens.spacing(1)),
            child: MinqSecondaryButton(
              label: '再生を停止',
              icon: Icons.stop,
              onPressed: () async {
                try {
                  await service.stop();
                } catch (error) {
                  FeedbackMessenger.showErrorSnackBar(
                    context,
                    'BGMの停止に失敗しました、E,
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}

class _FocusMusicTile extends ConsumerWidget {
  const _FocusMusicTile({
    required this.track,
    required this.service,
    required this.isActive,
    required this.isPlaying,
  });

  final FocusMusicTrack track;
  final FocusMusicService service;
  final bool isActive;
  final bool isPlaying;

  Future<void> _handleTap(BuildContext context) async {
    try {
      if (isActive && isPlaying) {
        await service.stop();
      } else {
        await service.play(track);
      }
    } catch (error) {
      FeedbackMessenger.showErrorSnackBar(
        context,
        'BGMの再生に失敗しました、E,
      );
    }
  }

  Future<void> _identifyTrack(BuildContext context, WidgetRef ref) async {
    final taggingService = ref.read(acrMusicTaggingServiceProvider);
    if (taggingService == null) {
      FeedbackMessenger.showInfoToast(context, 'BGMの識別は現在ご利用ぁE��だけません');
      return;
    }
    try {
      final result = await taggingService.identifyFromUrl(track.url);
      if (result == null) {
        FeedbackMessenger.showInfoToast(context, '楽曲を特定できませんでした');
        return;
      }
      FeedbackMessenger.showSuccessToast(
        context,
        '${result.title} / ${result.artists.join(', ')}',
      );
    } catch (error) {
      FeedbackMessenger.showErrorSnackBar(context, 'BGMの識別に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final hasTagging = ref.watch(acrMusicTaggingServiceProvider) != null;
    final Color tileColor =
        isActive ? tokens.brandPrimary.withValues(alpha: 0.12) : tokens.surface;
    final borderColor =
        isActive ? tokens.brandPrimary : tokens.border.withValues(alpha: 0.4);

    return Material(
      color: Colors.transparent,
      borderRadius: tokens.cornerLarge(),
      child: InkWell(
        borderRadius: tokens.cornerLarge(),
        onTap: () => _handleTap(context),
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: tokens.cornerLarge(),
            border: Border.all(color: borderColor),
          ),
          padding: EdgeInsets.all(tokens.spacing(4)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: tokens.brandPrimary,
                size: tokens.spacing(7),
              ),
              SizedBox(width: tokens.spacing(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            track.title,
                            style: tokens.titleSmall.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'BGMを�E動タグ付け',
                          icon: const Icon(Icons.music_note),
                          onPressed: hasTagging
                              ? () => _identifyTrack(context, ref)
                              : null,
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      track.description,
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
              SizedBox(width: tokens.spacing(3)),
              FilledButton.tonal(
                onPressed: () => _handleTap(context),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isPlaying ? tokens.brandPrimary : tokens.surface,
                  foregroundColor:
                      isPlaying ? Colors.white : tokens.textPrimary,
                ),
                child: Text(isPlaying ? '停止' : '再生'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _handleModerationWarning(
  BuildContext context,
  PhotoCaptureResult result,
) async {
  if (result.moderationVerdict == PhotoModerationVerdict.ok) return true;

  final tokens = context.tokens;
  final message = switch (result.moderationVerdict) {
    PhotoModerationVerdict.tooDark => '撮影した写真が非常に暗いようです。パートナーを安忁E��せるために撮り直しますか�E�E,
    PhotoModerationVerdict.tooBright => '撮影した写真がほとんど真っ白です。鮮明にするために撮り直しますか�E�E,
    PhotoModerationVerdict.lowVariance =>
      '画像がぼめE��てぁE��か、何も映ってぁE��ぁE��ぁE��す。より鮮明な証明�Eために撮り直しますか�E�E,
    PhotoModerationVerdict.ok => '',
  };

  final proceed =
      await showDialog<bool>(
        context: context,
        builder:
            (BuildContext dialogContext) => AlertDialog(
              title: const Text('写真を確認してください'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('再撮影'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.brandPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('こ�E写真を使用'),
                ),
              ],
            ),
      ) ??
      false;

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
        widget.isPrimary
            ? tokens.brandPrimary
            : tokens.brandPrimary.withValues(alpha: 0.1);
    final Color foreground =
        widget.isPrimary ? Colors.white : tokens.textPrimary;

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
          transitionBuilder:
              (Widget child, Animation<double> animation) =>
                  FadeTransition(opacity: animation, child: child),
          child:
              isProcessing
                  ? SizedBox(
                    key: const ValueKey<String>('progress'),
                    height: tokens.spacing(7),
                    width: tokens.spacing(7),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  )
                  : Column(
                    key: const ValueKey<String>('content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(widget.icon, size: tokens.spacing(10)),
                      SizedBox(height: tokens.spacing(2)),
                      Text(
                        widget.text,
                        style: tokens.titleMedium.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
      title: 'オフラインでぁE,
      message: '証明�Eローカルに保存され、�E接続時にアチE�Eロードされます、E,
      actionArea: Column(
        children: [
          MinqPrimaryButton(
            label: '再アチE�EローチE,
            onPressed: () async => onRetry(),
            expand: false,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onOpenQueue, child: const Text('オフラインキューを表示')),
        ],
      ),
    );
  }
}

class _PermissionRecovery extends StatelessWidget {
  const _PermissionRecovery({
    required this.onRequest,
    required this.onOpenSettings,
  });
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return MinqEmptyState(
      icon: Icons.camera_alt_outlined,
      title: 'カメラへのアクセスが忁E��でぁE,
      message: '写真の証明を撮影するには、MinQがカメラにアクセスする忁E��があります、E,
      actionArea: Column(
        children: [
          MinqPrimaryButton(
            label: 'アクセスを許可',
            onPressed: () async => onRequest(),
            expand: false,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onOpenSettings, child: const Text('設定を開く')),
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
      title: 'カメラエラー',
      message: 'カメラで問題が発生しました。もぁE��度お試しください、E,
      actionArea: Column(
        children: [
          MinqPrimaryButton(
            label: '再試衁E,
            onPressed: () async => onRetry(),
            expand: false,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onSwitchMode, child: const Text('代わりに自己申告すめE)),
        ],
      ),
    );
  }
}
