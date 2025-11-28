import 'dart:math';

/// 軽量なルールベースAIサービス
/// Gemmaモデルの問題が解決するまでの一時的な代替案
class LightweightAIService {
  static const List<String> _greetings = [
    'こんにちは！MinQのAIコンシェルジュです。今日も習慣づくりを頑張りましょう！',
    'お疲れさまです！今日の習慣の調子はいかがですか？',
    'こんにちは！何かお手伝いできることはありますか？',
    'MinQへようこそ！習慣形成のサポートをさせていただきます。',
  ];

  static const Map<String, List<String>> _responses = {
    'greeting': [
      'こんにちは！今日も一緒に頑張りましょう！何か目標はありますか？',
      'お疲れさまです！今日の習慣の調子はいかがですか？',
      'こんにちは！MinQで新しい習慣を始めてみませんか？',
      'いい調子ですね！今日も小さな一歩を踏み出しましょう。',
    ],
    'motivation': [
      '小さな一歩でも、続けることが大切です。あなたならできます！',
      '習慣は毎日の積み重ねです。完璧を目指さず、継続を大切にしましょう。',
      '今日できなくても大丈夫。明日また新しい気持ちで始めましょう！',
      '成功の秘訣は諦めないこと。一緒に頑張りましょう！',
    ],
    'habit': [
      '新しい習慣は小さく始めるのがコツです。1日1分からでも大丈夫！',
      '同じ時間に行うと習慣化しやすくなります。朝の時間がおすすめです。',
      '習慣が身につくまで約21日。焦らず続けることが大切です。',
      'MinQのリマインダー機能を使って、習慣を忘れないようにしましょう。',
    ],
    'support': [
      'いつでもサポートします。困ったときは遠慮なく相談してください！',
      'あなたの成長を心から応援しています。一緒に頑張りましょう！',
      'MinQの機能を活用して、楽しく習慣づくりを続けましょう。',
      '小さな進歩も大きな成果です。自分を褒めてあげてくださいね。',
    ],
    'question': [
      'いい質問ですね！習慣づくりについてもっと詳しく聞かせてください。',
      'そのことについて一緒に考えてみましょう。どんなことが気になりますか？',
      'MinQの機能で解決できるかもしれません。詳しく教えてください。',
    ],
    'default': [
      'ありがとうございます。習慣づくりで何かお困りのことはありますか？',
      'そうですね。MinQでどんな習慣を始めてみたいですか？',
      'なるほど。他にも気になることがあれば何でも聞いてくださいね。',
      '素晴らしいですね！継続することで必ず成果が出ますよ。',
    ],
  };

  final Random _random = Random();

  String generateGreeting() {
    return _greetings[_random.nextInt(_greetings.length)];
  }

  String generateResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // キーワードベースの応答選択（優先度順）
    if (_containsAny(message, [
      'こんにちは',
      'おはよう',
      'こんばんは',
      'はじめまして',
      'hello',
      'hi',
    ])) {
      return _getRandomResponse('greeting');
    }

    if (_containsAny(message, [
      'やる気',
      'モチベーション',
      '続かない',
      '挫折',
      '頑張',
      '疲れ',
      'しんどい',
    ])) {
      return _getRandomResponse('motivation');
    }

    if (_containsAny(message, [
      '習慣',
      'ルーティン',
      '続ける',
      '始める',
      'コツ',
      '方法',
      'どうやって',
    ])) {
      return _getRandomResponse('habit');
    }

    if (_containsAny(message, ['ありがとう', 'サポート', '助けて', '相談', 'お疲れ', '応援'])) {
      return _getRandomResponse('support');
    }

    if (_containsAny(message, [
      '？',
      '?',
      'なぜ',
      'どう',
      'なに',
      '何',
      'いつ',
      'どこ',
      'だれ',
    ])) {
      return _getRandomResponse('question');
    }

    return _getRandomResponse('default');
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _getRandomResponse(String category) {
    final responses = _responses[category] ?? _responses['default']!;
    return responses[_random.nextInt(responses.length)];
  }
}
