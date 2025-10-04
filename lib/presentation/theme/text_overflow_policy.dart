import 'package:flutter/material.dart';

/// チE��ストオーバ�Eフローポリシー - 統一されたテキスト表示ルール
class TextOverflowPolicy {
  const TextOverflowPolicy._();

  // ========================================
  // オーバ�Eフロー設宁E
  // ========================================

  /// タイトル: 1行、省略記号
  static const TextOverflow title = TextOverflow.ellipsis;
  static const int titleMaxLines = 1;
  static const bool titleSoftWrap = false;

  /// サブタイトル: 2行、省略記号
  static const TextOverflow subtitle = TextOverflow.ellipsis;
  static const int subtitleMaxLines = 2;
  static const bool subtitleSoftWrap = true;

  /// 本斁E 制限なし、折り返し
  static const TextOverflow body = TextOverflow.clip;
  static const int? bodyMaxLines = null;
  static const bool bodySoftWrap = true;

  /// 説明文: 3行、省略記号
  static const TextOverflow description = TextOverflow.ellipsis;
  static const int descriptionMaxLines = 3;
  static const bool descriptionSoftWrap = true;

  /// キャプション: 1行、省略記号
  static const TextOverflow caption = TextOverflow.ellipsis;
  static const int captionMaxLines = 1;
  static const bool captionSoftWrap = false;

  /// ラベル: 1行、フェーチE
  static const TextOverflow label = TextOverflow.fade;
  static const int labelMaxLines = 1;
  static const bool labelSoftWrap = false;

  /// ボタン: 1行、省略記号
  static const TextOverflow button = TextOverflow.ellipsis;
  static const int buttonMaxLines = 1;
  static const bool buttonSoftWrap = false;

  /// リストアイチE��: 2行、省略記号
  static const TextOverflow listItem = TextOverflow.ellipsis;
  static const int listItemMaxLines = 2;
  static const bool listItemSoftWrap = true;

  /// カードタイトル: 2行、省略記号
  static const TextOverflow cardTitle = TextOverflow.ellipsis;
  static const int cardTitleMaxLines = 2;
  static const bool cardTitleSoftWrap = true;

  /// カード本斁E 4行、省略記号
  static const TextOverflow cardBody = TextOverflow.ellipsis;
  static const int cardBodyMaxLines = 4;
  static const bool cardBodySoftWrap = true;

  /// チE�EルチッチE 制限なし、折り返し
  static const TextOverflow tooltip = TextOverflow.clip;
  static const int? tooltipMaxLines = null;
  static const bool tooltipSoftWrap = true;

  /// エラーメチE��ージ: 制限なし、折り返し
  static const TextOverflow error = TextOverflow.clip;
  static const int? errorMaxLines = null;
  static const bool errorSoftWrap = true;
}

/// チE��ストスタイル拡張 - オーバ�Eフロー設定を簡単に適用
extension TextStyleOverflow on TextStyle {
  /// タイトルスタイル
  TextStyle get asTitle => copyWith(
        overflow: TextOverflowPolicy.title,
      );

  /// サブタイトルスタイル
  TextStyle get asSubtitle => copyWith(
        overflow: TextOverflowPolicy.subtitle,
      );

  /// 本斁E��タイル
  TextStyle get asBody => copyWith(
        overflow: TextOverflowPolicy.body,
      );

  /// 説明文スタイル
  TextStyle get asDescription => copyWith(
        overflow: TextOverflowPolicy.description,
      );

  /// キャプションスタイル
  TextStyle get asCaption => copyWith(
        overflow: TextOverflowPolicy.caption,
      );

  /// ラベルスタイル
  TextStyle get asLabel => copyWith(
        overflow: TextOverflowPolicy.label,
      );
}

/// 標準化されたテキストウィジェチE��
class StandardText {
  const StandardText._();

  /// タイトルチE��スチE
  static Widget title(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.titleMaxLines,
      overflow: TextOverflowPolicy.title,
      softWrap: TextOverflowPolicy.titleSoftWrap,
      textAlign: textAlign,
    );
  }

  /// サブタイトルチE��スチE
  static Widget subtitle(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.subtitleMaxLines,
      overflow: TextOverflowPolicy.subtitle,
      softWrap: TextOverflowPolicy.subtitleSoftWrap,
      textAlign: textAlign,
    );
  }

  /// 本斁E��キスチE
  static Widget body(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
    int? maxLines,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: maxLines ?? TextOverflowPolicy.bodyMaxLines,
      overflow: TextOverflowPolicy.body,
      softWrap: TextOverflowPolicy.bodySoftWrap,
      textAlign: textAlign,
    );
  }

  /// 説明文チE��スチE
  static Widget description(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.descriptionMaxLines,
      overflow: TextOverflowPolicy.description,
      softWrap: TextOverflowPolicy.descriptionSoftWrap,
      textAlign: textAlign,
    );
  }

  /// キャプションチE��スチE
  static Widget caption(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.captionMaxLines,
      overflow: TextOverflowPolicy.caption,
      softWrap: TextOverflowPolicy.captionSoftWrap,
      textAlign: textAlign,
    );
  }

  /// ラベルチE��スチE
  static Widget label(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.labelMaxLines,
      overflow: TextOverflowPolicy.label,
      softWrap: TextOverflowPolicy.labelSoftWrap,
      textAlign: textAlign,
    );
  }

  /// ボタンチE��スチE
  static Widget button(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.buttonMaxLines,
      overflow: TextOverflowPolicy.button,
      softWrap: TextOverflowPolicy.buttonSoftWrap,
      textAlign: textAlign,
    );
  }

  /// リストアイチE��チE��スチE
  static Widget listItem(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.listItemMaxLines,
      overflow: TextOverflowPolicy.listItem,
      softWrap: TextOverflowPolicy.listItemSoftWrap,
      textAlign: textAlign,
    );
  }

  /// カードタイトルチE��スチE
  static Widget cardTitle(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.cardTitleMaxLines,
      overflow: TextOverflowPolicy.cardTitle,
      softWrap: TextOverflowPolicy.cardTitleSoftWrap,
      textAlign: textAlign,
    );
  }

  /// カード本斁E��キスチE
  static Widget cardBody(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.cardBodyMaxLines,
      overflow: TextOverflowPolicy.cardBody,
      softWrap: TextOverflowPolicy.cardBodySoftWrap,
      textAlign: textAlign,
    );
  }

  /// エラーメチE��ージチE��スチE
  static Widget error(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
  }) {
    return Text(
      text,
      style: style?.copyWith(color: color),
      maxLines: TextOverflowPolicy.errorMaxLines,
      overflow: TextOverflowPolicy.error,
      softWrap: TextOverflowPolicy.errorSoftWrap,
      textAlign: textAlign,
    );
  }
}

/// 展開可能なチE��ストウィジェチE��
class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int collapsedMaxLines;
  final String expandText;
  final String collapseText;
  final Color? linkColor;

  const ExpandableText({
    super.key,
    required this.text,
    this.style,
    this.collapsedMaxLines = 3,
    this.expandText = 'もっと見る',
    this.collapseText = '閉じめE,
    this.linkColor,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkColor = widget.linkColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _isExpanded ? null : widget.collapsedMaxLines,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? widget.collapseText : widget.expandText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: linkColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// チE��ストオーバ�Eフロー検�EウィジェチE��
class TextOverflowDetector extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final Widget Function(BuildContext, bool isOverflowing) builder;

  const TextOverflowDetector({
    super.key,
    required this.text,
    this.style,
    required this.maxLines,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines;

        return builder(context, isOverflowing);
      },
    );
  }
}
