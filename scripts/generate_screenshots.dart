// スクリーンショット生成スクリプト
// flutter run -d <device> scripts/generate_screenshots.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ScreenshotGeneratorApp(),
    ),
  );
}

class ScreenshotGeneratorApp extends StatelessWidget {
  const ScreenshotGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenshot Generator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const ScreenshotGeneratorScreen(),
    );
  }
}

class ScreenshotGeneratorScreen extends StatefulWidget {
  const ScreenshotGeneratorScreen({super.key});

  @override
  State<ScreenshotGeneratorScreen> createState() =>
      _ScreenshotGeneratorScreenState();
}

class _ScreenshotGeneratorScreenState extends State<ScreenshotGeneratorScreen> {
  int _currentIndex = 0;
  bool _isDark = false;

  final List<ScreenshotConfig> _screenshots = [
    ScreenshotConfig(
      name: '01_home_screen',
      title: '今日の習慣を一目で確認',
      description: 'シンプルで使いやすいホーム画面',
    ),
    ScreenshotConfig(
      name: '02_stats_screen',
      title: '成長を見える化',
      description: 'ストリークと達成率をグラフで表示',
    ),
    ScreenshotConfig(
      name: '03_pair_feature',
      title: '友達と励まし合おう',
      description: 'ペア機能でモチベーションアップ',
    ),
    ScreenshotConfig(
      name: '04_create_quest',
      title: '簡単に習慣を追加',
      description: '直感的なクエスト作成フォーム',
    ),
    ScreenshotConfig(
      name: '05_notifications',
      title: '忘れずにリマインド',
      description: 'カスタマイズ可能な通知設定',
    ),
    ScreenshotConfig(
      name: '06_dark_mode',
      title: '目に優しいデザイン',
      description: 'ダークモード完全対応',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final config = _screenshots[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Screenshot ${_currentIndex + 1}/${_screenshots.length}'),
        actions: [
          IconButton(
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDark = !_isDark;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _takeScreenshot,
          ),
        ],
      ),
      body: Column(
        children: [
          // キャッチコピー部分
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDark
                    ? [Colors.blue.shade900, Colors.purple.shade900]
                    : [Colors.blue.shade400, Colors.purple.shade400],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  config.description,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // アプリ画面部分（モックアップ）
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildMockScreen(_currentIndex),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentIndex > 0
                  ? () {
                      setState(() {
                        _currentIndex--;
                      });
                    }
                  : null,
            ),
            Text('${_currentIndex + 1} / ${_screenshots.length}'),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentIndex < _screenshots.length - 1
                  ? () {
                      setState(() {
                        _currentIndex++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockScreen(int index) {
    // 実際のアプリ画面のモックアップを表示
    // 本番では実際の画面を表示
    return Container(
      color: _isDark ? Colors.grey.shade900 : Colors.white,
      child: Center(
        child: Text(
          'Mock Screen ${index + 1}\n\n実際のアプリ画面をここに表示',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: _isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> _takeScreenshot() async {
    // スクリーンショット撮影の指示を表示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'スクリーンショットを撮影してください\n'
          'ファイル名: ${_screenshots[_currentIndex].name}_${_isDark ? 'dark' : 'light'}.png',
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // 実際の撮影は手動またはintegration_testで行う
    print('Screenshot: ${_screenshots[_currentIndex].name}');
  }
}

class ScreenshotConfig {
  final String name;
  final String title;
  final String description;

  ScreenshotConfig({
    required this.name,
    required this.title,
    required this.description,
  });
}
