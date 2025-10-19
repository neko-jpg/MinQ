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
      'こんにちは！今日も一緒に頑張りましょう！',
      'お疲れさまです！調子はいかがですか？',
      'こんにちは！何かお手伝いできることはありますか？',
    ],
    'motivation': [
      '小さな一歩でも、続けることが大切です。あなたならできます！',
      '習慣は毎日の積み重ねです。今日も頑張りましょう！',
      '完璧を目指さず、継続することを大切にしてください。',
    ],
    'habit': [
      '新しい習慣を始めるときは、小さく始めることがコツです。',
      '習慣を続けるには、同じ時間に行うことが効果的です。',
      '習慣が身につくまで、平均21日かかると言われています。',
    ],
    'support': [
      'いつでもサポートします。一緒に頑張りましょう！',
      '困ったときは遠慮なく相談してください。',
      'あなたの成長を応援しています！',
    ],
    'default': [
      'ありがとうございます。他に何かお手伝いできることはありますか？',
      'そうですね。習慣づくりについて何か質問はありますか？',
      'なるほど。MinQの機能で気になることがあれば教えてください。',
    ],
  };

  final Random _random = Random();

  String generateGreeting() {
    return _greetings[_random.nextInt(_greetings.length)];
  }

  String generateResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // キーワードベースの応答選択
    if (_containsAny(message, ['こんにちは', 'おはよう', 'こんばんは', 'はじめまして'])) {
      return _getRandomResponse('greeting');
    }
    
    if (_containsAny(message, ['やる気', 'モチベーション', '続かない', '挫折', '頑張'])) {
      return _getRandomResponse('motivation');
    }
    
    if (_containsAny(message, ['習慣', 'ルーティン', '続ける', '始める', 'コツ'])) {
      return _getRandomResponse('habit');
    }
    
    if (_containsAny(message, ['ありがとう', 'サポート', '助けて', '相談'])) {
      return _getRandomResponse('support');
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