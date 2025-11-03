import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// 検索クエリをハイライト表示するテキストウィジェット
class SearchHighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool caseSensitive;

  const SearchHighlightText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.caseSensitive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final tokens = MinqTheme.of(context);
    final defaultHighlightStyle = highlightStyle ??
        TextStyle(
          backgroundColor: tokens.brandPrimary.withAlpha((255 * 0.3).round()),
          fontWeight: FontWeight.bold,
          color: tokens.brandPrimary,
        );

    final spans = _buildTextSpans(
      text: text,
      query: query,
      baseStyle: style,
      highlightStyle: defaultHighlightStyle,
      caseSensitive: caseSensitive,
    );

    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.start,
    );
  }

  List<TextSpan> _buildTextSpans({
    required String text,
    required String query,
    required TextStyle? baseStyle,
    required TextStyle highlightStyle,
    required bool caseSensitive,
  }) {
    final spans = <TextSpan>[];

    // クエリを単語に分割
    final queryWords =
        query.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();

    if (queryWords.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    // 各単語のマッチ位置を見つける
    final matches = <_Match>[];

    for (final word in queryWords) {
      final searchText = caseSensitive ? text : text.toLowerCase();
      final searchWord = caseSensitive ? word : word.toLowerCase();

      int startIndex = 0;
      while (true) {
        final index = searchText.indexOf(searchWord, startIndex);
        if (index == -1) break;

        matches.add(_Match(start: index, end: index + word.length, word: word));

        startIndex = index + 1;
      }
    }

    // マッチをソートしてマージ
    matches.sort((a, b) => a.start.compareTo(b.start));
    final mergedMatches = _mergeOverlappingMatches(matches);

    // TextSpanを構築
    int currentIndex = 0;

    for (final match in mergedMatches) {
      // マッチ前のテキスト
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // ハイライトされたテキスト
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: baseStyle?.merge(highlightStyle) ?? highlightStyle,
        ),
      );

      currentIndex = match.end;
    }

    // 残りのテキスト
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: baseStyle));
    }

    return spans;
  }

  List<_Match> _mergeOverlappingMatches(List<_Match> matches) {
    if (matches.isEmpty) return matches;

    final merged = <_Match>[];
    _Match current = matches.first;

    for (int i = 1; i < matches.length; i++) {
      final next = matches[i];

      if (next.start <= current.end) {
        // オーバーラップしている場合はマージ
        current = _Match(
          start: current.start,
          end: next.end > current.end ? next.end : current.end,
          word: '${current.word} ${next.word}',
        );
      } else {
        // オーバーラップしていない場合は現在のマッチを追加
        merged.add(current);
        current = next;
      }
    }

    merged.add(current);
    return merged;
  }
}

/// マッチ情報
class _Match {
  final int start;
  final int end;
  final String word;

  const _Match({required this.start, required this.end, required this.word});
}

/// 複数のハイライトスタイルをサポートするバージョン
class MultiHighlightText extends StatelessWidget {
  final String text;
  final List<HighlightPattern> patterns;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const MultiHighlightText({
    super.key,
    required this.text,
    required this.patterns,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    if (patterns.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final spans = _buildMultiHighlightSpans();

    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textAlign: textAlign ?? TextAlign.start,
    );
  }

  List<TextSpan> _buildMultiHighlightSpans() {
    final allMatches = <_PatternMatch>[];

    // 各パターンのマッチを見つける
    for (int i = 0; i < patterns.length; i++) {
      final pattern = patterns[i];
      final searchText = pattern.caseSensitive ? text : text.toLowerCase();
      final searchPattern =
          pattern.caseSensitive
              ? pattern.pattern
              : pattern.pattern.toLowerCase();

      int startIndex = 0;
      while (true) {
        final index = searchText.indexOf(searchPattern, startIndex);
        if (index == -1) break;

        allMatches.add(
          _PatternMatch(
            start: index,
            end: index + pattern.pattern.length,
            patternIndex: i,
          ),
        );

        startIndex = index + 1;
      }
    }

    // マッチをソート
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    // TextSpanを構築
    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in allMatches) {
      // 重複チェック
      if (match.start < currentIndex) continue;

      // マッチ前のテキスト
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, match.start),
            style: style,
          ),
        );
      }

      // ハイライトされたテキスト
      final pattern = patterns[match.patternIndex];
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: style?.merge(pattern.highlightStyle) ?? pattern.highlightStyle,
        ),
      );

      currentIndex = match.end;
    }

    // 残りのテキスト
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex), style: style));
    }

    return spans;
  }
}

/// ハイライトパターン
class HighlightPattern {
  final String pattern;
  final TextStyle highlightStyle;
  final bool caseSensitive;

  const HighlightPattern({
    required this.pattern,
    required this.highlightStyle,
    this.caseSensitive = false,
  });
}

/// パターンマッチ情報
class _PatternMatch {
  final int start;
  final int end;
  final int patternIndex;

  const _PatternMatch({
    required this.start,
    required this.end,
    required this.patternIndex,
  });
}
