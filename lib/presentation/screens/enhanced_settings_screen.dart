import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/settings/settings_search_service.dart';
import 'package:minq/domain/settings/settings_category.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/settings/settings_category_widget.dart';
import 'package:minq/presentation/widgets/settings/settings_item_widget.dart';
import 'package:minq/presentation/widgets/settings/settings_search_bar.dart';

class EnhancedSettingsScreen extends ConsumerStatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  ConsumerState<EnhancedSettingsScreen> createState() =>
      _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState
    extends ConsumerState<EnhancedSettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _showAdvancedSettings = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);
    final categories = ref.watch(settingsCategoriesProvider);
    final searchResults =
        _searchQuery.isNotEmpty
            ? ref.watch(settingsSearchProvider(_searchQuery))
            : <SettingsSearchResult>[];

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          '設定',
          style: theme.typography.h4.copyWith(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showAdvancedSettings ? Icons.visibility_off : Icons.visibility,
              color: theme.textSecondary,
            ),
            tooltip: _showAdvancedSettings ? '高度な設定を非表示' : '高度な設定を表示',
            onPressed: () {
              setState(() {
                _showAdvancedSettings = !_showAdvancedSettings;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(theme.spacing.md),
            color: theme.surface,
            child: SettingsSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              onClear: _clearSearch,
            ),
          ),

          // Content
          Expanded(
            child:
                _searchQuery.isNotEmpty
                    ? _buildSearchResults(searchResults)
                    : _buildCategorizedSettings(categories),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(List<SettingsSearchResult> results) {
    final theme = MinqTheme.of(context);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.textMuted),
            SizedBox(height: theme.spacing.md),
            Text(
              '検索結果が見つかりませんでした',
              style: theme.typography.bodyLarge.copyWith(
                color: theme.textSecondary,
              ),
            ),
            SizedBox(height: theme.spacing.sm),
            Text(
              '別のキーワードで検索してみてください',
              style: theme.typography.bodyMedium.copyWith(
                color: theme.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(theme.spacing.md),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return Card(
          margin: EdgeInsets.only(bottom: theme.spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.md,
                  vertical: theme.spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: theme.surfaceAlt,
                  borderRadius: BorderRadius.vertical(
                    top: theme.cornerMedium().topLeft,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      result.category.icon,
                      size: 16,
                      color: theme.textSecondary,
                    ),
                    SizedBox(width: theme.spacing.sm),
                    Text(
                      result.category.title,
                      style: theme.typography.bodySmall.copyWith(
                        color: theme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Settings item
              SettingsItemWidget(
                item: result.item,
                category: result.category,
                searchQuery: _searchQuery,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorizedSettings(List<SettingsCategory> categories) {
    final theme = MinqTheme.of(context);
    final filteredCategories =
        categories
            .where((category) => _showAdvancedSettings || !category.isAdvanced)
            .toList();

    return ListView.builder(
      padding: EdgeInsets.all(theme.spacing.md),
      itemCount: filteredCategories.length,
      itemBuilder: (context, index) {
        final category = filteredCategories[index];
        return Padding(
          padding: EdgeInsets.only(bottom: theme.spacing.lg),
          child: SettingsCategoryWidget(
            category: category,
            showAdvanced: _showAdvancedSettings,
          ),
        );
      },
    );
  }
}

/// Provider for settings categories
final settingsCategoriesProvider = Provider<List<SettingsCategory>>((ref) {
  return [
    // Appearance & Theme
    const SettingsCategory(
      id: 'appearance',
      title: '外観・テーマ',
      subtitle: 'アプリの見た目をカスタマイズ',
      icon: Icons.palette_outlined,
      items: [
        SettingsItem(
          id: 'theme_mode',
          title: 'テーマモード',
          subtitle: 'ライト・ダーク・システム設定',
          icon: Icons.brightness_6_outlined,
          type: SettingsItemType.selection,
          options: [
            SettingsOption(
              id: 'system',
              title: 'システム設定に従う',
              icon: Icons.phone_android,
              value: ThemeMode.system,
            ),
            SettingsOption(
              id: 'light',
              title: 'ライトモード',
              icon: Icons.light_mode,
              value: ThemeMode.light,
            ),
            SettingsOption(
              id: 'dark',
              title: 'ダークモード',
              icon: Icons.dark_mode,
              value: ThemeMode.dark,
            ),
          ],
          searchKeywords: ['テーマ', 'ダーク', 'ライト', '外観', '色'],
        ),
        SettingsItem(
          id: 'accent_color',
          title: 'アクセントカラー',
          subtitle: 'アプリのメインカラーを選択',
          icon: Icons.color_lens_outlined,
          type: SettingsItemType.colorPicker,
          searchKeywords: ['色', 'カラー', 'アクセント', 'テーマ'],
        ),
        SettingsItem(
          id: 'theme_customization',
          title: 'テーマカスタマイズ',
          subtitle: '詳細なテーマ設定',
          icon: Icons.tune_outlined,
          type: SettingsItemType.navigation,
          route: '/settings/theme-customization',
          searchKeywords: ['カスタマイズ', 'テーマ', '詳細設定'],
        ),
      ],
    ),

    // Notifications
    const SettingsCategory(
      id: 'notifications',
      title: '通知',
      subtitle: '通知の設定と管理',
      icon: Icons.notifications_outlined,
      items: [
        SettingsItem(
          id: 'notifications_enabled',
          title: '通知を有効にする',
          subtitle: 'プッシュ通知の受信',
          icon: Icons.notifications_active_outlined,
          type: SettingsItemType.toggle,
          searchKeywords: ['通知', 'プッシュ', 'お知らせ'],
        ),
        SettingsItem(
          id: 'notification_time',
          title: '通知時間',
          subtitle: 'デイリーリマインダーの時間',
          icon: Icons.schedule_outlined,
          type: SettingsItemType.timePicker,
          searchKeywords: ['時間', '時刻', 'リマインダー', '通知'],
        ),
        SettingsItem(
          id: 'notification_categories',
          title: '通知カテゴリ',
          subtitle: 'カテゴリ別の通知設定',
          icon: Icons.category_outlined,
          type: SettingsItemType.navigation,
          route: '/settings/notification-categories',
          searchKeywords: ['カテゴリ', '種類', '通知'],
        ),
        SettingsItem(
          id: 'smart_notifications',
          title: 'スマート通知',
          subtitle: 'AIによる最適な通知タイミング',
          icon: Icons.psychology_outlined,
          type: SettingsItemType.navigation,
          route: '/settings/smart-notifications',
          searchKeywords: ['AI', 'スマート', '自動', '最適化'],
        ),
      ],
    ),

    // Privacy & Security
    const SettingsCategory(
      id: 'privacy',
      title: 'プライバシー・セキュリティ',
      subtitle: 'データ保護とセキュリティ設定',
      icon: Icons.security_outlined,
      items: [
        SettingsItem(
          id: 'biometric_auth',
          title: '生体認証',
          subtitle: '指紋・顔認証でアプリを保護',
          icon: Icons.fingerprint_outlined,
          type: SettingsItemType.toggle,
          searchKeywords: ['生体認証', '指紋', '顔認証', 'セキュリティ'],
        ),
        SettingsItem(
          id: 'data_sync',
          title: 'データ同期',
          subtitle: 'クラウド同期の設定',
          icon: Icons.sync_outlined,
          type: SettingsItemType.navigation,
          route: '/settings/data-sync',
          searchKeywords: ['同期', 'クラウド', 'バックアップ'],
        ),
        SettingsItem(
          id: 'privacy_settings',
          title: 'プライバシー設定',
          subtitle: 'データ使用とプライバシー管理',
          icon: Icons.privacy_tip_outlined,
          type: SettingsItemType.navigation,
          route: '/settings/privacy',
          searchKeywords: ['プライバシー', 'データ', '個人情報'],
        ),
      ],
    ),

    // Accessibility
    const SettingsCategory(
      id: 'accessibility',
      title: 'アクセシビリティ',
      subtitle: '使いやすさの設定',
      icon: Icons.accessibility_outlined,
      items: [
        SettingsItem(
          id: 'high_contrast',
          title: '高コントラスト',
          subtitle: '色のコントラストを強化',
          icon: Icons.contrast_outlined,
          type: SettingsItemType.toggle,
          searchKeywords: ['コントラスト', '見やすさ', 'アクセシビリティ'],
        ),
        SettingsItem(
          id: 'large_text',
          title: '大きな文字',
          subtitle: 'テキストサイズを拡大',
          icon: Icons.text_increase_outlined,
          type: SettingsItemType.toggle,
          searchKeywords: ['文字', 'テキスト', '大きい', '拡大'],
        ),
        SettingsItem(
          id: 'animations_enabled',
          title: 'アニメーション',
          subtitle: 'アニメーション効果の有効/無効',
          icon: Icons.animation_outlined,
          type: SettingsItemType.toggle,
          searchKeywords: ['アニメーション', '動き', '効果'],
        ),
      ],
    ),

    // Data Management
    const SettingsCategory(
      id: 'data',
      title: 'データ管理',
      subtitle: 'データのバックアップと管理',
      icon: Icons.storage_outlined,
      items: [
        SettingsItem(
          id: 'data_export',
          title: 'データエクスポート',
          subtitle: 'データをファイルに出力',
          icon: Icons.download_outlined,
          type: SettingsItemType.navigation,
          route: '/settings/data-export',
          searchKeywords: ['エクスポート', 'ダウンロード', 'バックアップ'],
        ),
        SettingsItem(
          id: 'data_import',
          title: 'データインポート',
          subtitle: 'バックアップファイルから復元',
          icon: Icons.upload_outlined,
          type: SettingsItemType.navigation,
          route: '/settings/data-import',
          searchKeywords: ['インポート', 'アップロード', '復元'],
        ),
        SettingsItem(
          id: 'storage_usage',
          title: 'ストレージ使用量',
          subtitle: 'アプリのデータ使用量を確認',
          icon: Icons.storage_outlined,
          type: SettingsItemType.navigation,
          route: '/settings/storage',
          searchKeywords: ['ストレージ', '容量', '使用量'],
        ),
      ],
    ),

    // About & Support
    const SettingsCategory(
      id: 'about',
      title: 'アプリについて',
      subtitle: 'サポートと情報',
      icon: Icons.info_outlined,
      items: [
        SettingsItem(
          id: 'help_center',
          title: 'ヘルプセンター',
          subtitle: 'よくある質問と使い方',
          icon: Icons.help_outline,
          type: SettingsItemType.navigation,
          route: '/help',
          searchKeywords: ['ヘルプ', 'サポート', '質問', '使い方'],
        ),
        SettingsItem(
          id: 'contact_support',
          title: 'お問い合わせ',
          subtitle: 'バグ報告や機能要望',
          icon: Icons.feedback_outlined,
          type: SettingsItemType.navigation,
          route: '/support',
          searchKeywords: ['お問い合わせ', 'サポート', 'バグ', '要望'],
        ),
        SettingsItem(
          id: 'app_version',
          title: 'アプリバージョン',
          subtitle: 'バージョン 1.0.0',
          icon: Icons.info_outline,
          type: SettingsItemType.info,
          value: '1.0.0',
          searchKeywords: ['バージョン', '情報'],
        ),
        SettingsItem(
          id: 'privacy_policy',
          title: 'プライバシーポリシー',
          subtitle: 'データの取り扱いについて',
          icon: Icons.privacy_tip_outlined,
          type: SettingsItemType.navigation,
          route: '/privacy-policy',
          searchKeywords: ['プライバシー', 'ポリシー', '規約'],
        ),
        SettingsItem(
          id: 'terms_of_service',
          title: '利用規約',
          subtitle: 'サービス利用規約',
          icon: Icons.description_outlined,
          type: SettingsItemType.navigation,
          route: '/terms',
          searchKeywords: ['利用規約', '規約', '条件'],
        ),
      ],
    ),

    // Advanced Settings (only shown when enabled)
    const SettingsCategory(
      id: 'advanced',
      title: '高度な設定',
      subtitle: '開発者・上級者向け設定',
      icon: Icons.settings_outlined,
      isAdvanced: true,
      items: [
        SettingsItem(
          id: 'developer_mode',
          title: '開発者モード',
          subtitle: '開発者向け機能を有効化',
          icon: Icons.developer_mode_outlined,
          type: SettingsItemType.toggle,
          searchKeywords: ['開発者', 'デベロッパー', 'デバッグ'],
        ),
        SettingsItem(
          id: 'debug_mode',
          title: 'デバッグモード',
          subtitle: 'デバッグ情報を表示',
          icon: Icons.bug_report_outlined,
          type: SettingsItemType.toggle,
          searchKeywords: ['デバッグ', 'ログ', '診断'],
        ),
        SettingsItem(
          id: 'reset_settings',
          title: '設定をリセット',
          subtitle: 'すべての設定を初期値に戻す',
          icon: Icons.restore_outlined,
          type: SettingsItemType.action,
          isDangerous: true,
          searchKeywords: ['リセット', '初期化', '復元'],
        ),
        SettingsItem(
          id: 'delete_account',
          title: 'アカウント削除',
          subtitle: 'アカウントとデータを完全削除',
          icon: Icons.delete_forever_outlined,
          type: SettingsItemType.action,
          isDangerous: true,
          route: '/settings/delete-account',
          searchKeywords: ['削除', 'アカウント', '退会'],
        ),
      ],
    ),
  ];
});

/// Provider for settings search results
final settingsSearchProvider =
    Provider.family<List<SettingsSearchResult>, String>((ref, query) {
      final searchService = ref.watch(settingsSearchServiceProvider);
      final categories = ref.watch(settingsCategoriesProvider);
      return searchService.searchSettings(categories, query);
    });
