import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ヘルプセンター画面
class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプセンター'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            title: 'よくある質問',
            icon: Icons.help_outline,
            onTap: () => _navigateToFAQ(context),
          ),
          _buildSection(
            context,
            title: 'チュートリアル',
            icon: Icons.school_outlined,
            onTap: () => _navigateToTutorial(context),
          ),
          _buildSection(
            context,
            title: 'お問い合わせ',
            icon: Icons.email_outlined,
            onTap: () => _navigateToContact(context),
          ),
          _buildSection(
            context,
            title: 'バグ報告',
            icon: Icons.bug_report_outlined,
            onTap: () => _navigateToBugReport(context),
          ),
          const Divider(),
          _buildSection(
            context,
            title: '利用規約',
            icon: Icons.description_outlined,
            onTap: () => _navigateToTerms(context),
          ),
          _buildSection(
            context,
            title: 'プライバシーポリシー',
            icon: Icons.privacy_tip_outlined,
            onTap: () => _navigateToPrivacy(context),
          ),
          _buildSection(
            context,
            title: 'ライセンス',
            icon: Icons.info_outlined,
            onTap: () => _navigateToLicenses(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _navigateToFAQ(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FAQScreen()),
    );
  }

  void _navigateToTutorial(BuildContext context) {
    // TODO: チュートリアル画面へ遷移
  }

  void _navigateToContact(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactScreen()),
    );
  }

  void _navigateToBugReport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BugReportScreen()),
    );
  }

  void _navigateToTerms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsScreen()),
    );
  }

  void _navigateToPrivacy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
    );
  }

  void _navigateToLicenses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LicensePage(
          applicationName: 'MinQ',
          applicationVersion: '1.0.0',
          applicationLegalese: '© 2025 MinQ Team',
        ),
      ),
    );
  }
}

/// FAQ画面
class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('よくある質問'),
      ),
      body: ListView(
        children: [
          _buildFAQItem(
            question: 'クエストとは何ですか？',
            answer: 'クエストは、あなたが継続したい習慣のことです。毎日の運動、読書、瞑想など、どんな習慣でも設定できます。',
          ),
          _buildFAQItem(
            question: 'ペア機能はどのように使いますか？',
            answer: 'ペア機能を使うと、他のユーザーと一緒に習慣を継続できます。お互いに励まし合いながら、モチベーションを維持できます。',
          ),
          _buildFAQItem(
            question: '連続日数（ストリーク）が途切れてしまいました',
            answer: 'ストリーク保護機能を使うと、1日だけ記録を忘れても連続日数を維持できます。設定画面から有効化してください。',
          ),
          _buildFAQItem(
            question: '通知が届きません',
            answer: '設定アプリで通知が許可されているか確認してください。また、アプリ内の通知設定も確認してください。',
          ),
          _buildFAQItem(
            question: 'データをバックアップできますか？',
            answer: 'はい、設定画面からデータをエクスポートできます。JSONまたはCSV形式で保存できます。',
          ),
          _buildFAQItem(
            question: 'アカウントを削除したい',
            answer: '設定画面の「アカウント削除」から削除できます。削除されたデータは復元できませんのでご注意ください。',
          ),
          _buildFAQItem(
            question: '有料プランはありますか？',
            answer: '現在、MinQは完全無料でご利用いただけます。将来的にプレミアム機能を追加する可能性があります。',
          ),
          _buildFAQItem(
            question: 'オフラインでも使えますか？',
            answer: 'はい、オフラインでも記録できます。インターネットに接続すると自動的に同期されます。',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }
}

/// お問い合わせ画面
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お問い合わせ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'お名前',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'お名前を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                if (!value.contains('@')) {
                  return '有効なメールアドレスを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'お問い合わせ内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'お問い合わせ内容を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitContact,
              child: const Text('送信'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitContact() async {
    if (_formKey.currentState!.validate()) {
      // TODO: お問い合わせを送信
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('お問い合わせを送信しました')),
      );
      Navigator.pop(context);
    }
  }
}

/// バグ報告画面
class BugReportScreen extends StatefulWidget {
  const BugReportScreen({super.key});

  @override
  State<BugReportScreen> createState() => _BugReportScreenState();
}

class _BugReportScreenState extends State<BugReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('バグ報告'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              'バグを発見された場合は、以下のフォームからご報告ください。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'タイトルを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '詳細',
                hintText: '発生した状況、再現手順などを詳しく記載してください',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '詳細を入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _attachScreenshot,
              icon: const Icon(Icons.image),
              label: const Text('スクリーンショットを添付'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitBugReport,
              child: const Text('送信'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _attachScreenshot() async {
    // TODO: スクリーンショットを添付
  }

  Future<void> _submitBugReport() async {
    if (_formKey.currentState!.validate()) {
      // TODO: バグ報告を送信
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('バグ報告を送信しました')),
      );
      Navigator.pop(context);
    }
  }
}

/// 利用規約画面
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('利用規約'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          // TODO: assets/legal/terms_of_service_ja.md から読み込む
          '利用規約の内容がここに表示されます',
        ),
      ),
    );
  }
}

/// プライバシーポリシー画面
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プライバシーポリシー'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          // TODO: assets/legal/privacy_policy_ja.md から読み込む
          'プライバシーポリシーの内容がここに表示されます',
        ),
      ),
    );
  }
}
