# ホームウィジェット セットアップ

## 概要
iOS/Androidのホーム画面にウィジェットを表示して、アプリを開かずに進捗を確認できるようにします。

## 使用パッケージ
- `home_widget`: iOS/Android両対応のウィジェットパッケージ

## 実装手順

### 1. パッケージのインストール

```yaml
dependencies:
  home_widget: ^0.4.0
```

### 2. Android設定

#### AndroidManifest.xml
```xml
<receiver
    android:name="es.antonborri.home_widget.HomeWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/home_widget" />
</receiver>
```

#### res/xml/home_widget.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="180dp"
    android:minHeight="110dp"
    android:updatePeriodMillis="1800000"
    android:initialLayout="@layout/widget_layout"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen" />
```

#### res/layout/widget_layout.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="16dp"
    android:background="@drawable/widget_background">

    <TextView
        android:id="@+id/widget_title"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="MinQ"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="#FFFFFF" />

    <TextView
        android:id="@+id/widget_streak"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="0 days"
        android:textSize="32sp"
        android:textStyle="bold"
        android:textColor="#FFFFFF"
        android:gravity="center"
        android:layout_marginTop="8dp" />

    <TextView
        android:id="@+id/widget_subtitle"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Current Streak"
        android:textSize="14sp"
        android:textColor="#CCCCCC"
        android:gravity="center" />

    <TextView
        android:id="@+id/widget_today_count"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="0/3 completed"
        android:textSize="14sp"
        android:textColor="#FFFFFF"
        android:gravity="center"
        android:layout_marginTop="8dp" />
</LinearLayout>
```

### 3. iOS設定

#### Widget Extension作成
1. Xcode でプロジェクトを開く
2. File > New > Target > Widget Extension
3. Product Name: "MinQWidget"
4. Include Configuration Intent: チェック

#### MinQWidget.swift
```swift
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), streak: 0, todayCount: 0, totalCount: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), streak: 0, todayCount: 0, totalCount: 3)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // UserDefaults から データを取得
        let sharedDefaults = UserDefaults(suiteName: "group.com.example.minq")
        let streak = sharedDefaults?.integer(forKey: "streak") ?? 0
        let todayCount = sharedDefaults?.integer(forKey: "todayCount") ?? 0
        let totalCount = sharedDefaults?.integer(forKey: "totalCount") ?? 3

        let entry = SimpleEntry(
            date: Date(),
            streak: streak,
            todayCount: todayCount,
            totalCount: totalCount
        )

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let todayCount: Int
    let totalCount: Int
}

struct MinQWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MinQ")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(entry.streak)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Text("days streak")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(entry.todayCount)/\(entry.totalCount)")
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("today")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "667eea"), Color(hex: "764ba2")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

@main
struct MinQWidget: Widget {
    let kind: String = "MinQWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MinQWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MinQ Progress")
        .description("View your habit streak and today's progress")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

### 4. Flutter実装

```dart
import 'package:home_widget/home_widget.dart';

class WidgetService {
  /// ウィジェットデータを更新
  Future<void> updateWidget({
    required int streak,
    required int todayCount,
    required int totalCount,
  }) async {
    try {
      // データを保存
      await HomeWidget.saveWidgetData<int>('streak', streak);
      await HomeWidget.saveWidgetData<int>('todayCount', todayCount);
      await HomeWidget.saveWidgetData<int>('totalCount', totalCount);

      // ウィジェットを更新
      await HomeWidget.updateWidget(
        name: 'MinQWidget',
        iOSName: 'MinQWidget',
        androidName: 'HomeWidgetProvider',
      );
    } catch (e) {
      print('❌ Failed to update widget: $e');
    }
  }

  /// ウィジェットタップ時のURLを設定
  Future<void> setWidgetUrl(String url) async {
    try {
      await HomeWidget.setAppGroupId('group.com.example.minq');
      await HomeWidget.saveWidgetData<String>('url', url);
    } catch (e) {
      print('❌ Failed to set widget URL: $e');
    }
  }

  /// ウィジェットからの起動を監視
  void listenForWidgetLaunch(Function(Uri?) callback) {
    HomeWidget.widgetClicked.listen((uri) {
      callback(uri);
    });
  }

  /// 初期URLを取得
  Future<Uri?> getInitialUrl() async {
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (e) {
      print('❌ Failed to get initial URL: $e');
      return null;
    }
  }
}
```

### 5. 使用例

```dart
class QuestLogController extends StateNotifier<AsyncValue<void>> {
  final WidgetService _widgetService;

  Future<void> completeQuest(String questId) async {
    // クエストを完了
    await _questRepository.completeQuest(questId);

    // 統計を取得
    final stats = await _statsRepository.getStats();

    // ウィジェットを更新
    await _widgetService.updateWidget(
      streak: stats.currentStreak,
      todayCount: stats.todayCompletedCount,
      totalCount: stats.todayTotalCount,
    );
  }
}
```

## 注意事項
- ウィジェットは定期的に更新されます（Android: 30分ごと、iOS: システム管理）
- データはApp GroupまたはShared Preferencesで共有します
- ウィジェットのサイズに応じてレイアウトを調整してください
- バッテリー消費に注意してください
