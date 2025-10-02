import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:minq/domain/log/quest_log.dart';

class HomeQuestItem {
  const HomeQuestItem({
    required this.id,
    required this.title,
    required this.category,
    required this.estimatedMinutes,
    this.iconKey,
  });

  factory HomeQuestItem.fromJson(Map<String, dynamic> json) {
    return HomeQuestItem(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      estimatedMinutes: json['estimatedMinutes'] as int,
      iconKey: json['iconKey'] as String?,
    );
  }

  final int id;
  final String title;
  final String category;
  final int estimatedMinutes;
  final String? iconKey;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'category': category,
      'estimatedMinutes': estimatedMinutes,
      'iconKey': iconKey,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeQuestItem &&
        other.id == id &&
        other.title == title &&
        other.category == category &&
        other.estimatedMinutes == estimatedMinutes &&
        other.iconKey == iconKey;
  }

  @override
  int get hashCode => Object.hash(id, title, category, estimatedMinutes, iconKey);
}

class HomeLogItem {
  const HomeLogItem({
    required this.id,
    required this.questId,
    required this.timestamp,
    required this.proofType,
    this.proofValue,
  });

  factory HomeLogItem.fromJson(Map<String, dynamic> json) {
    return HomeLogItem(
      id: json['id'] as int,
      questId: json['questId'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      proofType: ProofType.values.firstWhere(
        (ProofType value) => value.name == json['proofType'],
        orElse: () => ProofType.check,
      ),
      proofValue: json['proofValue'] as String?,
    );
  }

  final int id;
  final int questId;
  final DateTime timestamp;
  final ProofType proofType;
  final String? proofValue;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'questId': questId,
      'timestamp': timestamp.toIso8601String(),
      'proofType': proofType.name,
      'proofValue': proofValue,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeLogItem &&
        other.id == id &&
        other.questId == questId &&
        other.timestamp == timestamp &&
        other.proofType == proofType &&
        other.proofValue == proofValue;
  }

  @override
  int get hashCode => Object.hash(id, questId, timestamp, proofType, proofValue);
}

@immutable
class HomeViewData {
  const HomeViewData({
    required this.quests,
    required this.streak,
    required this.completionsToday,
    required this.recentLogs,
    required this.updatedAt,
  });

  factory HomeViewData.empty() {
    return HomeViewData(
      quests: const <HomeQuestItem>[],
      streak: 0,
      completionsToday: 0,
      recentLogs: const <HomeLogItem>[],
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
    );
  }

  factory HomeViewData.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    final List<dynamic> questJson = json['quests'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> logJson = json['recentLogs'] as List<dynamic>? ?? <dynamic>[];
    return HomeViewData(
      quests: questJson
          .map((dynamic item) => HomeQuestItem.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      streak: json['streak'] as int? ?? 0,
      completionsToday: json['completionsToday'] as int? ?? 0,
      recentLogs: logJson
          .map((dynamic item) => HomeLogItem.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
    );
  }

  final List<HomeQuestItem> quests;
  final int streak;
  final int completionsToday;
  final List<HomeLogItem> recentLogs;
  final DateTime updatedAt;

  bool get hasCachedContent =>
      quests.isNotEmpty || recentLogs.isNotEmpty || streak > 0 || completionsToday > 0;

  String toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'quests': quests.map((HomeQuestItem item) => item.toJson()).toList(growable: false),
      'streak': streak,
      'completionsToday': completionsToday,
      'recentLogs': recentLogs.map((HomeLogItem item) => item.toJson()).toList(growable: false),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
    return jsonEncode(json);
  }

  HomeViewData copyWith({
    List<HomeQuestItem>? quests,
    int? streak,
    int? completionsToday,
    List<HomeLogItem>? recentLogs,
    DateTime? updatedAt,
  }) {
    return HomeViewData(
      quests: quests ?? this.quests,
      streak: streak ?? this.streak,
      completionsToday: completionsToday ?? this.completionsToday,
      recentLogs: recentLogs ?? this.recentLogs,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeViewData &&
        listEquals(other.quests, quests) &&
        other.streak == streak &&
        other.completionsToday == completionsToday &&
        listEquals(other.recentLogs, recentLogs) &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(quests),
        streak,
        completionsToday,
        Object.hashAll(recentLogs),
        updatedAt,
      );
}
