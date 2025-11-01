class NotificationSoundProfile {
  const NotificationSoundProfile({
    required this.id,
    required this.label,
    required this.description,
    required this.playSound,
    required this.enableVibration,
    this.vibrationPattern,
  });

  final String id;
  final String label;
  final String description;
  final bool playSound;
  final bool enableVibration;
  final List<int>? vibrationPattern;

  static const NotificationSoundProfile defaultProfile =
      NotificationSoundProfile(
        id: 'default',
        label: '標準',
        description: 'デバイスの標準通知音とバイブレーションを使用します。',
        playSound: true,
        enableVibration: true,
      );

  static const NotificationSoundProfile focusProfile = NotificationSoundProfile(
    id: 'focus',
    label: '集中モード',
    description: '音は鳴らさず、控えめなバイブレーションのみでお知らせします。',
    playSound: false,
    enableVibration: true,
    vibrationPattern: <int>[0, 120, 40, 120],
  );

  static const NotificationSoundProfile chimeProfile = NotificationSoundProfile(
    id: 'gentle_chime',
    label: '軽やかなチャイム',
    description: '音は鳴りますがバイブレーションは抑制されます。',
    playSound: true,
    enableVibration: false,
  );

  static const NotificationSoundProfile silentProfile =
      NotificationSoundProfile(
        id: 'silent',
        label: 'サイレント',
        description: '音もバイブレーションも発生しません。',
        playSound: false,
        enableVibration: false,
      );

  static List<NotificationSoundProfile> get presets =>
      <NotificationSoundProfile>[
        defaultProfile,
        chimeProfile,
        focusProfile,
        silentProfile,
      ];

  static NotificationSoundProfile byId(String? id) {
    return presets.firstWhere(
      (profile) => profile.id == id,
      orElse: () => defaultProfile,
    );
  }
}
