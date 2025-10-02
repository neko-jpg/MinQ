import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 統計期間
enum StatsPeriod {
  week,
  month,
  year,
}

extension StatsPeriodExtension on StatsPeriod {
  String get displayName {
    switch (this) {
      case StatsPeriod.week:
        return '週';
      case StatsPeriod.month:
        return '月';
      case StatsPeriod.year:
        return '年';
    }
  }

  int get days {
    switch (this) {
      case StatsPeriod.week:
        return 7;
      case StatsPeriod.month:
        return 30;
      case StatsPeriod.year:
        return 365;
    }
  }
}

/// 統計期間コントローラー
class StatsPeriodController extends StateNotifier<StatsPeriod> {
  StatsPeriodController() : super(StatsPeriod.week);

  void setPeriod(StatsPeriod period) {
    state = period;
  }

  void setWeek() => setPeriod(StatsPeriod.week);
  void setMonth() => setPeriod(StatsPeriod.month);
  void setYear() => setPeriod(StatsPeriod.year);
}

/// 統計期間プロバイダー
final statsPeriodProvider =
    StateNotifierProvider<StatsPeriodController, StatsPeriod>((ref) {
  return StatsPeriodController();
});
