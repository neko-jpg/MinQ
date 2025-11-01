import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minq/core/initialization/lazy_initialization.dart';
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
import 'package:minq/presentation/theme/minq_tokens.dart';

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

  void _handleBackRequest(WidgetRef ref) {
    if (!_hasUnsavedChanges) {
      _popOrGoHome(ref);
      return;
    }

    showDiscardChangesDialog(
      context,
      message: '記録を保存せずに終了しますか？',
      discardLabel: '終了する',
    ).then((shouldLeave) {
      if (shouldLeave == true) {
        setState(() => _hasUnsavedChanges = false);
        _popOrGoHome(ref);
      }
    });
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
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _handleBackRequest(ref);
      },
      child: Scaffold(
        backgroundColor: MinqTokens.background,
        appBar: AppBar(
          title: Text(
            '記録',
            style: MinqTokens.titleMedium.copyWith(
              color: MinqTokens.textPrimary,
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
                ? const _RecordSkeleton()
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
  const _RecordSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(MinqTokens.spacing(3)),
      children: <Widget>[
        const MinqSkeletonLine(width: 140, height: 28),
        SizedBox(height: MinqTokens.spacing(2)),
        MinqSkeleton(height: 176, borderRadius: MinqTokens.cornerLarge()),
        SizedBox(height: MinqTokens.spacing(6)),
        const MinqSkeletonLine(width: 110, height: 28),
        SizedBox(height: MinqTokens.spacing(3)),
        Row(
          children: [
            Expanded(
              child: MinqSkeleton(
                height: 320,
                borderRadius: MinqTokens.cornerLarge(),
              ),
            ),
            SizedBox(width: MinqTokens.spacing(3)),
            Expanded(
              child: MinqSkeleton(
                height: 320,
                borderRadius: MinqTokens.cornerLarge(),
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
    final questAsync = ref.watch(questByIdProvider(questId));

    return questAsync.when(
      loading:
          () => Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(MinqTokens.brandPrimary),
            ),
          ),
      error:
          (error, _) => Center(
            child: Text(
              'クエスト情報の読み込みに失敗しました',
              style: MinqTokens.bodyMedium.copyWith(
                color: MinqTokens.textSecondary,
              ),
            ),
          ),
      data: (quest) {
        if (quest == null) {
          return Center(
            child: Text(
              'クエストが見つかりません',
              style: MinqTokens.bodyMedium.copyWith(
                color: MinqTokens.textSecondary,
              ),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(MinqTokens.spacing(3)),
          children: <Widget>[
            SizedBox(height: MinqTokens.spacing(3)),
            Text(
              'クエスト記録',
              style: MinqTokens.titleLarge.copyWith(
                color: MinqTokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MinqTokens.spacing(2)),
            _buildQuestInfoCard(quest),
            SizedBox(height: MinqTokens.spacing(6)),
            const _FocusMusicPanel(),
            SizedBox(height: MinqTokens.spacing(6)),
            Text(
              '証明',
              style: MinqTokens.titleLarge.copyWith(
                color: MinqTokens.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MinqTokens.spacing(3)),
            _buildProofButtons(context, ref, quest),
          ],
        );
      },
    );
  }

  Widget _buildQuestInfoCard(quest) {
    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(3)),
      decoration: BoxDecoration(
        color: MinqTokens.brandPrimary.withAlpha(25),
        borderRadius: MinqTokens.cornerLarge(),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: MinqTokens.brandPrimary.withAlpha(51),
              borderRadius: MinqTokens.cornerLarge(),
            ),
            child: Icon(
              iconDataForKey(quest.iconKey),
              color: MinqTokens.brandPrimary,
              size: 32,
            ),
          ),
          SizedBox(width: MinqTokens.spacing(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  quest.title,
                  style: MinqTokens.titleMedium.copyWith(
                    color: MinqTokens.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: MinqTokens.spacing(1)),
                Text(
                  '${quest.estimatedMinutes}分',
                  style: MinqTokens.bodyMedium.copyWith(
                    color: MinqTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofButtons(BuildContext context, WidgetRef ref, quest) {
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
              width: isWide ? MinqTokens.spacing(3) : 0,
              height: isWide ? 0 : MinqTokens.spacing(3),
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
    final messenger = ScaffoldMessenger.of(context);
    final navigation = ref.read(navigationUseCaseProvider);
    final uid = ref.read(uidProvider);
    if (uid == null || uid.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('サインインしていないため記録できません。')),
      );
      onError(RecordErrorType.permissionDenied);
      return;
    }
    try {
      final result = await ref
          .read(photoStorageServiceProvider)
          .captureAndSanitize(ownerUid: uid, questId: questId);
      if (!context.mounted) return;
      if (!result.hasFile) {
        messenger.showSnackBar(
          const SnackBar(content: Text('写真の撮影がキャンセルされました。')),
        );
        return;
      }

      final proceed = await _handleModerationWarning(context, result);
      // ignore: use_build_context_synchronously
      if (!proceed || !context.mounted) return;

      final controller = ref.read(questLogControllerProvider.notifier);
      final success = await controller.recordProgress(
        questId,
        proofValue: result.path,
        proofType: ProofType.photo,
      );

      if (success) {
        onError(RecordErrorType.none);
        onCompleted();
        navigation.goToCelebration();
        unawaited(FeedbackManager.questCompleted());
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
    final messenger = ScaffoldMessenger.of(context);
    final navigation = ref.read(navigationUseCaseProvider);
    final success = await controller.recordProgress(
      questId,
      proofType: ProofType.check,
    );

    if (success) {
      onCompleted();
      navigation.goToCelebration();
      unawaited(FeedbackManager.questCompleted());
    } else {
      if (!context.mounted) return;
      final error = ref.read(questLogControllerProvider).error;
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}

class _FocusMusicPanel extends ConsumerWidget {
  const _FocusMusicPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          style: MinqTokens.titleLarge.copyWith(
            color: MinqTokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: MinqTokens.spacing(1)),
        Text(
          '習慣を実行しながら流す音楽を選べます。ヘッドホン推奨です。',
          style: MinqTokens.bodyMedium.copyWith(
            color: MinqTokens.textSecondary,
          ),
        ),
        SizedBox(height: MinqTokens.spacing(2)),
        ...FocusMusicService.tracks.map(
          (track) => Padding(
            padding: EdgeInsets.only(bottom: MinqTokens.spacing(1)),
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
            padding: EdgeInsets.only(top: MinqTokens.spacing(1)),
            child: MinqSecondaryButton(
              label: '再生を停止',
              icon: Icons.stop,
              onPressed: () async {
                try {
                  await service.stop();
                } catch (error) {
                  if (!context.mounted) return;
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
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (isActive && isPlaying) {
        await service.stop();
      } else {
        await service.play(track);
      }
    } catch (error) {
      messenger.showSnackBar(const SnackBar(content: Text('BGMの再生に失敗しました。')));
    }
  }

  Future<void> _identifyTrack(BuildContext context, WidgetRef ref) async {
    final taggingService = ref.read(acrMusicTaggingServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    if (taggingService == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('BGMの識別は現在ご利用いただけません')),
      );
      return;
    }
    try {
      final result = await taggingService.identifyFromUrl(track.url);
      if (!context.mounted) return;
      if (result == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('楽曲を特定できませんでした')));
        return;
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.title} / ${result.artists.join(", ")}'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('BGMの識別に失敗しました')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTagging = ref.watch(acrMusicTaggingServiceProvider) != null;
    final Color tileColor =
        isActive ? MinqTokens.brandPrimary.withAlpha(30) : MinqTokens.surface;
    final borderColor =
        isActive
            ? MinqTokens.brandPrimary
            : Colors.grey.shade300.withAlpha(102);

    return Material(
      color: Colors.transparent,
      borderRadius: MinqTokens.cornerLarge(),
      child: InkWell(
        borderRadius: MinqTokens.cornerLarge(),
        onTap: () => _handleTap(context),
        child: Container(
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: MinqTokens.cornerLarge(),
            border: Border.all(color: borderColor),
          ),
          padding: EdgeInsets.all(MinqTokens.spacing(3)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: MinqTokens.brandPrimary,
                size: 28,
              ),
              SizedBox(width: MinqTokens.spacing(2)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            track.title,
                            style: MinqTokens.bodyMedium.copyWith(
                              color: MinqTokens.textPrimary,
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
                    SizedBox(height: MinqTokens.spacing(1)),
                    Text(
                      track.description,
                      style: MinqTokens.bodySmall.copyWith(
                        color: MinqTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: MinqTokens.spacing(2)),
              FilledButton.tonal(
                onPressed: () => _handleTap(context),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isPlaying ? MinqTokens.brandPrimary : MinqTokens.surface,
                  foregroundColor:
                      isPlaying ? Colors.white : MinqTokens.textPrimary,
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
  if (result.moderationVerdict == PhotoModerationVerdict.ok ||
      !context.mounted) {
    return true;
  }

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
                    backgroundColor: MinqTokens.brandPrimary,
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
      await file.delete();
    } on FileSystemException {
      // Ignore if the file doesn't exist
    } catch (_) {
      // Ignore other cleanup errors.
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
    final Color background =
        widget.isPrimary
            ? MinqTokens.brandPrimary
            : MinqTokens.brandPrimary.withAlpha(25);
    final Color foreground =
        widget.isPrimary ? Colors.white : MinqTokens.textPrimary;

    return SizedBox(
      height: 160,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(borderRadius: MinqTokens.cornerLarge()),
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
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(foreground),
                    ),
                  )
                  : Column(
                    key: const ValueKey<String>('content'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(widget.icon, size: 40),
                      SizedBox(height: MinqTokens.spacing(1)),
                      Text(
                        widget.text,
                        style: MinqTokens.titleMedium.copyWith(
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
