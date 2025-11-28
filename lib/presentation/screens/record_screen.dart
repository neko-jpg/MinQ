import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/acr_music_tagging_service.dart';
import 'package:minq/data/services/focus_music_service.dart';
import 'package:minq/data/services/image_moderation_service.dart';
import 'package:minq/data/services/photo_storage_service.dart';
import 'package:minq/domain/log/quest_log.dart';
import 'package:minq/presentation/common/dialogs/discard_changes_dialog.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/common/minq_empty_state.dart';
import 'package:minq/presentation/common/minq_skeleton.dart';
import 'package:minq/presentation/common/quest_icon_catalog.dart';
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
  bool _hasUnsavedChanges = true;

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

  void _markCompleted() {
    if (_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = false);
    }
  }

  Future<void> _handleBackRequest(WidgetRef ref) async {
    if (!_hasUnsavedChanges) {
      _popOrGoHome(ref);
      return;
    }

    final shouldLeave = await showDiscardChangesDialog(
      context,
      message: '記録を保存せずに終了しますか？',
      discardLabel: '終了する',
    );
    if (shouldLeave) {
      setState(() => _hasUnsavedChanges = false);
      _popOrGoHome(ref);
    }
  }

  void _popOrGoHome(WidgetRef ref) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      ref.read(navigationUseCaseProvider).goHome();
    }
  }

  @override
  void dispose() {
    ref.read(focusMusicServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        await _handleBackRequest(ref);
      },
      child: Scaffold(
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
            child: MinqIconButton(
              icon: Icons.close,
              onTap: () => _handleBackRequest(ref),
            ),
          ),
        ),
        body:
            _isLoading
                ? _RecordSkeleton(tokens: tokens)
                : switch (_error) {
                  RecordErrorType.none => _RecordForm(
                    questId: widget.questId,
                    onError: _handleError,
                    onCompleted: _markCompleted,
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
  const _RecordForm({
    required this.questId,
    required this.onError,
    required this.onCompleted,
  });

  final int questId;
  final void Function(RecordErrorType) onError;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final questAsync = ref.watch(questByIdProvider(questId));

    return questAsync.when(
      loading:
          () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
            ),
          ),
      error:
          (error, _) => Center(
            child: Text(
              'クエスト情報の読み込みに失敗しました',
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
          ),
      data: (quest) {
        if (quest == null) {
          return Center(
            child: Text(
              'クエストが見つかりません',
              style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(tokens.spacing(4)),
          children: <Widget>[
            SizedBox(height: tokens.spacing(4)),
            Text(
              'クエスト記録',
              style: tokens.titleLarge.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing(3)),
            _buildQuestInfoCard(tokens, quest),
            SizedBox(height: tokens.spacing(8)),
            const _FocusMusicPanel(),
            SizedBox(height: tokens.spacing(8)),
            Text(
              '証明',
              style: tokens.titleLarge.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: tokens.spacing(4)),
            _buildProofButtons(context, ref, tokens, quest),
          ],
        );
      },
    );
  }

  Widget _buildQuestInfoCard(MinqTheme tokens, quest) {
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
              iconDataForKey(quest.iconKey),
              color: tokens.brandPrimary,
              size: tokens.spacing(8),
            ),
          ),
          SizedBox(width: tokens.spacing(4)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  quest.title,
                  style: tokens.titleMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing(1)),
                Text(
                  '${quest.estimatedMinutes}分',
                  style: tokens.bodyMedium.copyWith(color: tokens.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofButtons(
    BuildContext context,
    WidgetRef ref,
    MinqTheme tokens,
    quest,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 400;
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          children: <Widget>[
            Expanded(
              child: _ProofButton(
                text: '写真を撮る',
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
                text: '自己申告',
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
      FeedbackMessenger.showErrorSnackBar(context, 'サインインしていないため記録できません。');
      onError(RecordErrorType.permissionDenied);
      return;
    }
    try {
      final result = await ref
          .read(photoStorageServiceProvider)
          .captureAndSanitize(ownerUid: uid, questId: questId);
      if (!result.hasFile) {
        FeedbackMessenger.showInfoToast(context, '写真の撮影がキャンセルされました。');
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
        onCompleted();
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
    final success = await controller.recordProgress(
      questId,
      proofType: ProofType.check,
    );

    if (success) {
      onCompleted();
      ref.read(navigationUseCaseProvider).goToCelebration();
      FeedbackManager.questCompleted();
    } else {
      final error = ref.read(questLogControllerProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _FocusMusicPanel extends ConsumerWidget {
  const _FocusMusicPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final PlayerState? playerState = ref
        .watch(focusMusicPlayerStateProvider)
        .maybeWhen(data: (state) => state, orElse: () => null);
    final service = ref.watch(focusMusicServiceProvider);
    final currentTrack = service.currentTrack;
    final isPlaying = playerState?.playing == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '集中BGM',
          style: tokens.titleLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: tokens.spacing(2)),
        Text(
          '習慣を実行しながら流す音楽を選べます。ヘッドホン推奨です。',
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
                    'BGMの停止に失敗しました。',
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
      FeedbackMessenger.showErrorSnackBar(context, 'BGMの再生に失敗しました。');
    }
  }

  Future<void> _identifyTrack(BuildContext context, WidgetRef ref) async {
    final taggingService = ref.read(acrMusicTaggingServiceProvider);
    if (taggingService == null) {
      FeedbackMessenger.showInfoToast(context, 'BGMの識別は現在ご利用いただけません');
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
                          tooltip: 'BGMを自動タグ付け',
                          icon: const Icon(Icons.music_note),
                          onPressed:
                              hasTagging
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
    PhotoModerationVerdict.tooDark => '撮影した写真が非常に暗いようです。パートナーを安心させるために撮り直しますか？',
    PhotoModerationVerdict.tooBright => '撮影した写真がほとんど真っ白です。鮮明にするために撮り直しますか？',
    PhotoModerationVerdict.lowVariance =>
      '画像がぼやけているか、何も映っていないようです。より鮮明な証明のために撮り直しますか？',
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
                  child: const Text('この写真を使用'),
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
      title: 'オフラインです',
      message: '証明はローカルに保存され、再接続時にアップロードされます。',
      actionArea: Column(
        children: [
          MinqPrimaryButton(
            label: '再アップロード',
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
      title: 'カメラへのアクセスが必要です',
      message: '写真の証明を撮影するには、MinQがカメラにアクセスする必要があります。',
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
      message: 'カメラで問題が発生しました。もう一度お試しください。',
      actionArea: Column(
        children: [
          MinqPrimaryButton(
            label: '再試行',
            onPressed: () async => onRetry(),
            expand: false,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onSwitchMode, child: const Text('代わりに自己申告する')),
        ],
      ),
    );
  }
}
