import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class PolicyViewerScreen extends StatelessWidget {
  const PolicyViewerScreen({super.key, required this.documentId});

  final PolicyDocumentId documentId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final document = policyDocuments[documentId]!;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          document.titleJa,
          style: tokens.typography.h5.copyWith(color: tokens.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.textPrimary),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing.lg),
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(documentId.icon, color: tokens.brandPrimary),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      document.titleJa,
                      style: tokens.typography.h4.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      document.titleEn,
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          Text(
            '最終更新日 / Last updated: ${document.lastUpdated}',
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.textMuted,
            ),
          ),
          if (document.highlightTag != null) ...<Widget>[
            SizedBox(height: tokens.spacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
                borderRadius: tokens.cornerLarge(),
              ),
              child: Text(
                document.highlightTag!,
                style: tokens.typography.bodySmall.copyWith(
                  color: tokens.brandPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          SizedBox(height: tokens.spacing.lg),
          if (document.assetPath != null)
            _PolicyMarkdownCard(document: document)
          else
            ...document.sections.map(
              (PolicySection section) =>
                  _PolicySectionCard(tokens: tokens, section: section),
            ),
        ],
      ),
    );
  }
}

class _PolicyMarkdownCard extends StatelessWidget {
  const _PolicyMarkdownCard({required this.document});

  final PolicyDocument document;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final assetPath = document.assetPath!;
    final bundle = DefaultAssetBundle.of(context);

    return FutureBuilder<String>(
      future: bundle.loadString(assetPath),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: tokens.spacing.lg),
            color: tokens.surface,
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.xl),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.trim().isEmpty) {
          return Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: tokens.spacing.lg),
            color: tokens.surface,
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: tokens.accentError),
                  SizedBox(width: tokens.spacing.md),
                  Expanded(
                    child: Text(
                      'ドキュメントを読み込めませんでした。時間を置いて再度お試しください。',
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final markdownStyle = MarkdownStyleSheet.fromTheme(
          Theme.of(context),
        ).copyWith(
          p: tokens.typography.body.copyWith(
            color: tokens.textPrimary,
            height: 1.6,
          ),
          h1: tokens.typography.h1.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          h2: tokens.typography.h2.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          h3: tokens.typography.h3.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          listBullet: tokens.typography.bodyMedium.copyWith(
            color: tokens.textPrimary,
          ),
          blockquote: tokens.typography.bodySmall.copyWith(
            color: tokens.textSecondary,
          ),
        );

        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: tokens.spacing.lg),
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.lg),
            child: MarkdownBody(
              data: snapshot.data!,
              styleSheet: markdownStyle,
              selectable: false,
            ),
          ),
        );
      },
    );
  }
}

class _PolicySectionCard extends StatelessWidget {
  const _PolicySectionCard({required this.tokens, required this.section});

  final MinqTheme tokens;
  final PolicySection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: tokens.spacing.lg),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              section.titleJa,
              style: tokens.typography.h5.copyWith(color: tokens.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              section.titleEn,
              style: tokens.typography.caption.copyWith(
                color: tokens.textMuted,
              ),
            ),
            SizedBox(height: tokens.spacing.md),
            ...section.paragraphs.map((PolicyParagraph paragraph) {
              return Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      paragraph.ja,
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    Text(
                      paragraph.en,
                      style: tokens.typography.bodySmall.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
