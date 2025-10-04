import 'package:flutter/material.dart';

/// 繝・く繧ｹ繝医が繝ｼ繝舌・繝輔Ο繝ｼ繝昴Μ繧ｷ繝ｼ - 邨ｱ荳縺輔ｌ縺溘ユ繧ｭ繧ｹ繝郁｡ｨ遉ｺ繝ｫ繝ｼ繝ｫ
class TextOverflowPolicy {
  const TextOverflowPolicy._();

  // ========================================
  // 繧ｪ繝ｼ繝舌・繝輔Ο繝ｼ險ｭ螳・
  // ========================================

  /// 繧ｿ繧､繝医Ν: 1陦後∫怐逡･險伜捷
  static const TextOverflow title = TextOverflow.ellipsis;
  static const int titleMaxLines = 1;
  static const bool titleSoftWrap = false;

  /// 繧ｵ繝悶ち繧､繝医Ν: 2陦後∫怐逡･險伜捷
  static const TextOverflow subtitle = TextOverflow.ellipsis;
  static const int subtitleMaxLines = 2;
  static const bool subtitleSoftWrap = true;

  /// 譛ｬ譁・ 蛻ｶ髯舌↑縺励∵釜繧願ｿ斐＠
  static const TextOverflow body = TextOverflow.clip;
  static const int? bodyMaxLines = null;
  static const bool bodySoftWrap = true;

  /// 隱ｬ譏取枚: 3陦後∫怐逡･險伜捷
  static const TextOverflow description = TextOverflow.ellipsis;
  static const int descriptionMaxLines = 3;
  static const bool descriptionSoftWrap = true;

  /// 繧ｭ繝｣繝励す繝ｧ繝ｳ: 1陦後∫怐逡･險伜捷
  static const TextOverflow caption = TextOverflow.ellipsis;
  static const int captionMaxLines = 1;
  static const bool captionSoftWrap = false;

  /// 繝ｩ繝吶Ν: 1陦後√ヵ繧ｧ繝ｼ繝・
  static const TextOverflow label = TextOverflow.fade;
  static const int labelMaxLines = 1;
  static const bool labelSoftWrap = false;

  /// 繝懊ち繝ｳ: 1陦後∫怐逡･險伜捷
  static const TextOverflow button = TextOverflow.ellipsis;
  static const int buttonMaxLines = 1;
  static const bool buttonSoftWrap = false;

  /// 繝ｪ繧ｹ繝医い繧､繝・Β: 2陦後∫怐逡･險伜捷
  static const TextOverflow listItem = TextOverflow.ellipsis;
  static const int listItemMaxLines = 2;
  static const bool listItemSoftWrap = true;

  /// 繧ｫ繝ｼ繝峨ち繧､繝医Ν: 2陦後∫怐逡･險伜捷
  static const TextOverflow cardTitle = TextOverflow.ellipsis;
  static const int cardTitleMaxLines = 2;
  static const bool cardTitleSoftWrap = true;

  /// 繧ｫ繝ｼ繝画悽譁・ 4陦後∫怐逡･險伜捷
  static const TextOverflow cardBody = TextOverflow.ellipsis;
  static const int cardBodyMaxLines = 4;
  static const bool cardBodySoftWrap = true;

  /// 繝・・繝ｫ繝√ャ繝・ 蛻ｶ髯舌↑縺励∵釜繧願ｿ斐＠
  static const TextOverflow tooltip = TextOverflow.clip;
  static const int? tooltipMaxLines = null;
  static const bool tooltipSoftWrap = true;

  /// 繧ｨ繝ｩ繝ｼ繝｡繝・そ繝ｼ繧ｸ: 蛻ｶ髯舌↑縺励∵釜繧願ｿ斐＠
  static const TextOverflow error = TextOverflow.clip;
  static const int? errorMaxLines = null;
  static const bool errorSoftWrap = true;
}

/// 繝・く繧ｹ繝医せ繧ｿ繧､繝ｫ諡｡蠑ｵ - 繧ｪ繝ｼ繝舌・繝輔Ο繝ｼ險ｭ螳壹ｒ邁｡蜊倥↓驕ｩ逕ｨ
extension TextStyleOverflow on TextStyle {
  /// 繧ｿ繧､繝医Ν繧ｹ繧ｿ繧､繝ｫ
  TextStyle get asTitle => copyWith(
        overflow: TextOverflowPolicy.title,
      );

  /// 繧ｵ繝悶ち繧､繝医Ν繧ｹ繧ｿ繧､繝ｫ
  TextStyle get asSubtitle => copyWith(
        overflow: TextOverflowPolicy.subtitle,
      );

  /// 譛ｬ譁・せ繧ｿ繧､繝ｫ
  TextStyle get asBody => copyWith(
        overflow: TextOverflowPolicy.body,
      );

  /// 隱ｬ譏取枚繧ｹ繧ｿ繧､繝ｫ
  TextStyle get asDescription => copyWith(
        overflow: TextOverflowPolicy.description,
      );

  /// 繧ｭ繝｣繝励す繝ｧ繝ｳ繧ｹ繧ｿ繧､繝ｫ
  TextStyle get asCaption => copyWith(
        overflow: TextOverflowPolicy.caption,
      );

  /// 繝ｩ繝吶Ν繧ｹ繧ｿ繧､繝ｫ
  TextStyle get asLabel => copyWith(
        overflow: TextOverflowPolicy.label,
      );
}

/// 讓呎ｺ門喧縺輔ｌ縺溘ユ繧ｭ繧ｹ繝医え繧｣繧ｸ繧ｧ繝・ヨ
class StandardText {
  const StandardText._();

  /// 繧ｿ繧､繝医Ν繝・く繧ｹ繝・
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

  /// 繧ｵ繝悶ち繧､繝医Ν繝・く繧ｹ繝・
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

  /// 譛ｬ譁・ユ繧ｭ繧ｹ繝・
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

  /// 隱ｬ譏取枚繝・く繧ｹ繝・
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

  /// 繧ｭ繝｣繝励す繝ｧ繝ｳ繝・く繧ｹ繝・
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

  /// 繝ｩ繝吶Ν繝・く繧ｹ繝・
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

  /// 繝懊ち繝ｳ繝・く繧ｹ繝・
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

  /// 繝ｪ繧ｹ繝医い繧､繝・Β繝・く繧ｹ繝・
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

  /// 繧ｫ繝ｼ繝峨ち繧､繝医Ν繝・く繧ｹ繝・
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

  /// 繧ｫ繝ｼ繝画悽譁・ユ繧ｭ繧ｹ繝・
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

  /// 繧ｨ繝ｩ繝ｼ繝｡繝・そ繝ｼ繧ｸ繝・く繧ｹ繝・
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

/// 螻暮幕蜿ｯ閭ｽ縺ｪ繝・く繧ｹ繝医え繧｣繧ｸ繧ｧ繝・ヨ
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
    this.expandText = '繧ゅ▲縺ｨ隕九ｋ',
    this.collapseText = '髢峨§繧・,
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

/// 繝・く繧ｹ繝医が繝ｼ繝舌・繝輔Ο繝ｼ讀懷・繧ｦ繧｣繧ｸ繧ｧ繝・ヨ
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
