import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/spacing_system.dart';
import '../theme/typography_system.dart';

/// ライセンス表示画面
class LicensesScreen extends ConsumerWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('オープンソースライセンス'),
      ),
      body: FutureBuilder<LicenseData>(
        future: _loadLicenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'ライセンス情報の読み込みに失敗しました',
                    style: AppTypography.body,
                  ),
                ],
              ),
            );
          }

          final licenseData = snapshot.data!;

          return ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              _buildHeader(context, licenseData),
              SizedBox(height: AppSpacing.lg),
              _buildPackageList(context, licenseData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LicenseData data) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'このアプリは以下のオープンソースソフトウェアを使用しています',
              style: AppTypography.body,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              '合計 ${data.packages.length} パッケージ',
              style: AppTypography.caption.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageList(BuildContext context, LicenseData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'パッケージ一覧',
          style: AppTypography.h2,
        ),
        SizedBox(height: AppSpacing.md),
        ...data.packages.map((package) => _buildPackageCard(context, package)),
      ],
    );
  }

  Widget _buildPackageCard(BuildContext context, LicenseEntry entry) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        title: Text(
          entry.packages.join(', '),
          style: AppTypography.h4,
        ),
        subtitle: entry.paragraphs.isNotEmpty
            ? Text(
                _getLicenseType(entry.paragraphs.first.text),
                style: AppTypography.caption,
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          _showLicenseDetail(context, entry);
        },
      ),
    );
  }

  void _showLicenseDetail(BuildContext context, LicenseEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.packages.join(', ')),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entry.paragraphs.map((paragraph) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  paragraph.text,
                  style: AppTypography.bodySmall,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  String _getLicenseType(String licenseText) {
    final text = licenseText.toLowerCase();
    if (text.contains('mit')) return 'MIT License';
    if (text.contains('apache')) return 'Apache License 2.0';
    if (text.contains('bsd')) return 'BSD License';
    if (text.contains('gpl')) return 'GPL License';
    if (text.contains('lgpl')) return 'LGPL License';
    if (text.contains('mpl')) return 'Mozilla Public License';
    return 'その他のライセンス';
  }

  Future<LicenseData> _loadLicenses() async {
    final packages = <LicenseEntry>[];
    
    await for (final license in LicenseRegistry.licenses) {
      packages.add(license);
    }

    // パッケージ名でソート
    packages.sort((a, b) {
      final aName = a.packages.join(', ').toLowerCase();
      final bName = b.packages.join(', ').toLowerCase();
      return aName.compareTo(bName);
    });

    return LicenseData(packages: packages);
  }
}

/// ライセンスデータ
class LicenseData {
  final List<LicenseEntry> packages;

  LicenseData({required this.packages});
}
