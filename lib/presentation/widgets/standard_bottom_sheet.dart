import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/elevation_system.dart';
import 'package:minq/presentation/theme/spacing_system.dart';

/// 標準�EトムシーチE- 統一された�Eトムシートコンポ�EネンチE
class StandardBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget content;
  final List<BottomSheetAction>? actions;
  final bool showDragHandle;
  final double? height;
  final bool scrollable;

  const StandardBottomSheet({
    super.key,
    this.title,
    this.titleWidget,
    required this.content,
    this.actions,
    this.showDragHandle = true,
    this.height,
    this.scrollable = true,
  });

  /// ボトムシートを表示
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? titleWidget,
    required Widget content,
    List<BottomSheetAction>? actions,
    bool showDragHandle = true,
    double? height,
    bool scrollable = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => StandardBottomSheet(
        title: title,
        titleWidget: titleWidget,
        content: content,
        actions: actions,
        showDragHandle: showDragHandle,
        height: height,
        scrollable: scrollable,
      ),
    );
  }

  /// リスト選択�EトムシーチE
  static Future<T?> showList<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetListItem<T>> items,
    T? selectedValue,
  }) {
    return show<T>(
      context: context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isSelected = item.value == selectedValue;
          return ListTile(
            leading: item.icon,
            title: Text(item.label),
            subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
            trailing: isSelected ? const Icon(Icons.check) : null,
            selected: isSelected,
            onTap: () => Navigator.of(context).pop(item.value),
          );
        }).toList(),
      ),
      scrollable: false,
    );
  }

  /// 確認�EトムシーチE
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'キャンセル',
    bool destructive = false,
  }) {
    return show<bool>(
      context: context,
      title: title,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(message),
      ),
      actions: [
        BottomSheetAction(
          label: cancelText,
          onPressed: (context) => Navigator.of(context).pop(false),
          isCancel: true,
        ),
        BottomSheetAction(
          label: confirmText,
          onPressed: (context) => Navigator.of(context).pop(true),
          isPrimary: true,
          isDestructive: destructive,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.9;
    final contentHeight = height ?? maxHeight;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderSystem.bottomSheetRadius,
        boxShadow: ElevationSystem.bottomSheet,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ドラチE��ハンドル
            if (showDragHandle) _buildDragHandle(),

            // タイトル
            if (title != null || titleWidget != null) _buildTitle(context),

            // コンチE��チE
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: contentHeight,
                ),
                child: scrollable
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: content,
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: content,
                      ),
              ),
            ),

            // アクション
            if (actions != null && actions!.isNotEmpty) _buildActions(context),

            // 下部余白
            SpacingSystem.vSpaceMD,
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: titleWidget ??
          Text(
            title!,
            style: Theme.of(context).textTheme.titleLarge,
          ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actions!.map((action) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildActionButton(context, action),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, BottomSheetAction action) {
    if (action.isPrimary) {
      return ElevatedButton(
        onPressed: () => action.onPressed(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: action.isDestructive
              ? const Color(0xFFEF4444)
              : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
        ),
        child: Text(action.label),
      );
    }

    if (action.isCancel) {
      return OutlinedButton(
        onPressed: () => action.onPressed(context),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
        child: Text(action.label),
      );
    }

    return TextButton(
      onPressed: () => action.onPressed(context),
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
      ),
      child: Text(action.label),
    );
  }
}

/// ボトムシートアクション
class BottomSheetAction {
  final String label;
  final void Function(BuildContext) onPressed;
  final bool isPrimary;
  final bool isCancel;
  final bool isDestructive;

  const BottomSheetAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isCancel = false,
    this.isDestructive = false,
  });
}

/// ボトムシートリストアイチE��
class BottomSheetListItem<T> {
  final String label;
  final String? subtitle;
  final Widget? icon;
  final T value;

  const BottomSheetListItem({
    required this.label,
    this.subtitle,
    this.icon,
    required this.value,
  });
}

/// BuildContext拡張
extension BottomSheetExtension on BuildContext {
  /// ボトムシートを表示
  Future<T?> showBottomSheet<T>({
    String? title,
    Widget? titleWidget,
    required Widget content,
    List<BottomSheetAction>? actions,
    bool showDragHandle = true,
    double? height,
    bool scrollable = true,
  }) {
    return StandardBottomSheet.show<T>(
      context: this,
      title: title,
      titleWidget: titleWidget,
      content: content,
      actions: actions,
      showDragHandle: showDragHandle,
      height: height,
      scrollable: scrollable,
    );
  }

  /// リスト選択�Eトムシートを表示
  Future<T?> showListBottomSheet<T>({
    required String title,
    required List<BottomSheetListItem<T>> items,
    T? selectedValue,
  }) {
    return StandardBottomSheet.showList<T>(
      context: this,
      title: title,
      items: items,
      selectedValue: selectedValue,
    );
  }

  /// 確認�Eトムシートを表示
  Future<bool?> showConfirmBottomSheet({
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'キャンセル',
    bool destructive = false,
  }) {
    return StandardBottomSheet.showConfirm(
      context: this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      destructive: destructive,
    );
  }
}
