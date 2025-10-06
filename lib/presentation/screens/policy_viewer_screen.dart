import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:minq/presentation/common/policy_documents.dart';
import 'package:minq/presentation/routing/navigation_extensions.dart';
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
          style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: tokens.textPrimary),
          onPressed: () => context.safePop(),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: EdgeInsets.all(tokens.spacing(5)),
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(documentId.icon, color: tokens.brandPrimary),
              SizedBox(width: tokens.spacing(3)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      document.titleJa,
                      style: tokens.titleMedium.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(1)),
                    Text(
                      document.titleEn,
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(4)),
          Text(
            '最終更新日 / Last updated: ${document.lastUpdated}',
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
          if (document.highlightTag != null) ...<Widget>[
            SizedBox(height: tokens.spacing(3)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing(4),
                vertical: tokens.spacing(2.5),
              ),
              decoration: BoxDecoration(
                color: tokens.brandPrimary.withValues(alpha: 0.1),
                borderRadius: tokens.cornerLarge(),
              ),
              child: Text(
                document.highlightTag!,
                style: tokens.bodySmall.copyWith(
                  color: tokens.brandPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          SizedBox(height: tokens.spacing(5)),
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
            margin: EdgeInsets.only(bottom: tokens.spacing(4)),
            color: tokens.surface,
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(6)),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.trim().isEmpty) {
          return Card(
            elevation: 0,
            margin: EdgeInsets.only(bottom: tokens.spacing(4)),
            color: tokens.surface,
            shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(4)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: tokens.accentError),
                  SizedBox(width: tokens.spacing(3)),
                  Expanded(
                    child: Text(
                      'ドキュメントを読み込めませんでした。時間を置いて再度お試しください。',
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
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
          p: tokens.bodyMedium.copyWith(color: tokens.textPrimary, height: 1.6),
          h1: tokens.titleLarge.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          h2: tokens.titleMedium.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          h3: tokens.titleSmall.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          listBullet: tokens.bodyMedium.copyWith(color: tokens.textPrimary),
          blockquote: tokens.bodySmall.copyWith(color: tokens.textSecondary),
        );

        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: tokens.spacing(4)),
          color: tokens.surface,
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing(4)),
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
      margin: EdgeInsets.only(bottom: tokens.spacing(4)),
      color: tokens.surface,
      shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              section.titleJa,
              style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
            ),
            SizedBox(height: tokens.spacing(1.5)),
            Text(
              section.titleEn,
              style: tokens.labelSmall.copyWith(color: tokens.textMuted),
            ),
            SizedBox(height: tokens.spacing(3)),
            ...section.paragraphs.map((PolicyParagraph paragraph) {
              return Padding(
                padding: EdgeInsets.only(bottom: tokens.spacing(3)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      paragraph.ja,
                      style: tokens.bodySmall.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(2)),
                    Text(
                      paragraph.en,
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
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
