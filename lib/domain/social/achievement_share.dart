/// 実績シェア用のデータモデル
class AchievementShare {
  final String achievementId;
  final String title;
  final String description;
  final String iconPath;
  final DateTime achievedAt;
  final int currentStreak;
  final int totalQuests;
  final String? customMessage;

  const AchievementShare({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.achievedAt,
    required this.currentStreak,
    required this.totalQuests,
    this.customMessage,
  });

  factory AchievementShare.fromJson(Map<String, dynamic> json) {
    return AchievementShare(
      achievementId: json['achievementId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconPath: json['iconPath'] as String,
      achievedAt: DateTime.parse(json['achievedAt'] as String),
      currentStreak: json['currentStreak'] as int,
      totalQuests: json['totalQuests'] as int,
      customMessage: json['customMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'title': title,
      'description': description,
      'iconPath': iconPath,
      'achievedAt': achievedAt.toIso8601String(),
      'currentStreak': currentStreak,
      'totalQuests': totalQuests,
      'customMessage': customMessage,
    };
  }
}

/// シェア可能な進捗データ
class ProgressShare {
  final int currentStreak;
  final int bestStreak;
  final int totalQuests;
  final int completedToday;
  final DateTime shareDate;
  final String? motivationalMessage;

  const ProgressShare({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalQuests,
    required this.completedToday,
    required this.shareDate,
    this.motivationalMessage,
  });

  factory ProgressShare.fromJson(Map<String, dynamic> json) {
    return ProgressShare(
      currentStreak: json['currentStreak'] as int,
      bestStreak: json['bestStreak'] as int,
      totalQuests: json['totalQuests'] as int,
      completedToday: json['completedToday'] as int,
      shareDate: DateTime.parse(json['shareDate'] as String),
      motivationalMessage: json['motivationalMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalQuests': totalQuests,
      'completedToday': completedToday,
      'shareDate': shareDate.toIso8601String(),
      'motivationalMessage': motivationalMessage,
    };
  }
}

/// シェア用画像の設定
class ShareImageConfig {
  final int width;
  final int height;
  final String backgroundImage;
  final String primaryColor;
  final String accentColor;

  const ShareImageConfig({
    this.width = 800,
    this.height = 600,
    this.backgroundImage = 'assets/images/share_background.png',
    this.primaryColor = '#4ECDC4',
    this.accentColor = '#FFD700',
  });

  factory ShareImageConfig.fromJson(Map<String, dynamic> json) {
    return ShareImageConfig(
      width: json['width'] as int? ?? 800,
      height: json['height'] as int? ?? 600,
      backgroundImage: json['backgroundImage'] as String? ?? 'assets/images/share_background.png',
      primaryColor: json['primaryColor'] as String? ?? '#4ECDC4',
      accentColor: json['accentColor'] as String? ?? '#FFD700',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'backgroundImage': backgroundImage,
      'primaryColor': primaryColor,
      'accentColor': accentColor,
    };
  }
}