import 'package:flutter/material.dart';

enum PolicyDocumentId { terms, privacy, community }

class PolicyParagraph {
  const PolicyParagraph({required this.ja, required this.en});

  final String ja;
  final String en;
}

class PolicySection {
  const PolicySection({
    required this.titleJa,
    required this.titleEn,
    required this.paragraphs,
  });

  final String titleJa;
  final String titleEn;
  final List<PolicyParagraph> paragraphs;
}

class PolicyDocument {
  const PolicyDocument({
    required this.id,
    required this.titleJa,
    required this.titleEn,
    required this.lastUpdated,
    required this.sections,
    this.highlightTag,
  });

  final PolicyDocumentId id;
  final String titleJa;
  final String titleEn;
  final String lastUpdated;
  final List<PolicySection> sections;
  final String? highlightTag;
}

final Map<PolicyDocumentId, PolicyDocument> policyDocuments =
    <PolicyDocumentId, PolicyDocument>{
  PolicyDocumentId.terms: PolicyDocument(
    id: PolicyDocumentId.terms,
    titleJa: '利用規約 & コミュニティガイドライン',
    titleEn: 'Terms of Service & Community Guidelines',
    lastUpdated: '2024-06-26',
    highlightTag: '13歳以上の方のみご利用いただけます',
    sections: <PolicySection>[
      const PolicySection(
        titleJa: '1. サービス概要',
        titleEn: '1. Service Overview',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'MinQは、匿名のペアと共に1日3タップで習慣化を促すモバイルアプリです。利用者は匿名プロフィールを作成し、習慣クエストの記録、Pairとのハイタッチを通じた励ましを行えます。',
            en: 'MinQ is a mobile application that helps users build habits with an anonymous partner in as little as three taps per day. Users create an anonymous profile to log quests and exchange supportive high-fives with their pair.',
          ),
        ],
      ),
      const PolicySection(
        titleJa: '2. 13歳以上の利用条件',
        titleEn: '2. Age Requirement (13+)',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '本サービスは13歳以上の方を対象としています。未成年の方は保護者の同意を得た上でご利用ください。13歳未満の方は登録や利用はできません。',
            en: 'This service is intended for individuals aged 13 and older. Minors should obtain consent from a guardian before using the app. Users under the age of 13 are not permitted to register or use MinQ.',
          ),
        ],
      ),
      const PolicySection(
        titleJa: '3. コミュニティガイドライン',
        titleEn: '3. Community Guidelines',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'Pairとのやり取りは互いを尊重する姿勢で行い、誹謗中傷やハラスメント、個人情報の共有を禁止します。不適切な利用が報告された場合はアカウント制限、停止を行います。',
            en: 'Interact with your pair respectfully. Harassment, abusive language, and sharing personally identifiable information are prohibited. Accounts may be limited or suspended if inappropriate behaviour is reported.',
          ),
          PolicyParagraph(
            ja: '共有する写真は本人や第三者の個人情報が写り込まないようにしてください。違反が見つかった場合は削除や審査対象となります。',
            en: 'Ensure that proof photos do not expose personal information about yourself or others. Violations may lead to removal or moderation review.',
          ),
        ],
      ),
      const PolicySection(
        titleJa: '4. 通報・ブロック',
        titleEn: '4. Reporting & Blocking',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'Pairとのやり取りで不快な体験があった場合は、アプリ内のメニューから通報・ブロックが可能です。通報は24時間以内に一次対応し、安全チームが状況を確認します。',
            en: 'If you encounter uncomfortable behaviour, use the in-app menu to report or block your pair. Reports receive an initial review within 24 hours by the safety team.',
          ),
        ],
      ),
    ],
  ),
  PolicyDocumentId.privacy: PolicyDocument(
    id: PolicyDocumentId.privacy,
    titleJa: 'プライバシーポリシー',
    titleEn: 'Privacy Policy',
    lastUpdated: '2024-06-26',
    sections: <PolicySection>[
      const PolicySection(
        titleJa: '1. 収集する情報',
        titleEn: '1. Information We Collect',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '匿名プロフィール、アプリ内のQuest達成ログ、Pairとのハイタッチ履歴、通知設定、任意で連携したGoogleアカウントIDを取得します。写真証跡は端末内でEXIFを除去し、ハッシュ化されたファイル名で保存されます。',
            en: 'We collect anonymous profile details, quest completion logs, pair high-five history, notification preferences, and optional linked Google account IDs. Photo proofs have EXIF data removed on-device and are stored using hashed filenames.',
          ),
        ],
      ),
      const PolicySection(
        titleJa: '2. 利用目的',
        titleEn: '2. How We Use Information',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '習慣継続の可視化、通知配信、マッチング精度向上、アプリ改善のための分析に利用します。個人が特定できる形で第三者と共有することはありません。',
            en: 'Data is used to visualise progress, deliver notifications, improve matching quality, and analyse app performance. We do not share data with third parties in a personally identifiable form.',
          ),
        ],
      ),
      const PolicySection(
        titleJa: '3. データの保護と保持期間',
        titleEn: '3. Data Protection & Retention',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '通信はすべてTLSで暗号化され、保存データは暗号化されたストレージに保持されます。アカウント削除申請から30日以内にデータを完全削除します。',
            en: 'All network traffic is encrypted via TLS and stored data resides in encrypted storage. Upon account deletion requests, all data is permanently removed within 30 days.',
          ),
        ],
      ),
      const PolicySection(
        titleJa: '4. ユーザーの権利',
        titleEn: '4. Your Rights',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'アプリ内からデータの閲覧、エクスポート、削除申請が可能です。お問い合わせは support@minq.app までお寄せください。',
            en: 'You can review, export, or request deletion of your data from within the app. Contact support@minq.app for assistance.',
          ),
        ],
      ),
    ],
  ),
  PolicyDocumentId.community: PolicyDocument(
    id: PolicyDocumentId.community,
    titleJa: '安全対策 & 通報対応',
    titleEn: 'Safety Measures & Reporting SOP',
    lastUpdated: '2024-06-26',
    sections: <PolicySection>[
      const PolicySection(
        titleJa: '1. 初動対応',
        titleEn: '1. Initial Response',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '通報を受領後24時間以内に担当者が状況を確認し、暫定措置（Pairの一時停止など）を講じます。',
            en: 'Within 24 hours of receiving a report, our team reviews the situation and may take interim actions such as temporarily pausing the pair.',
          ),
        ],
      ),
      const PolicySection(
        titleJa: '2. 調査と連絡',
        titleEn: '2. Investigation & Communication',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'ログや送受信メッセージを調査し、必要に応じて追加情報を依頼します。調査結果と対応方針は通報者にメールで共有します。',
            en: 'We review logs and partner interactions and request additional details if required. Findings and resolutions are shared with the reporter via email.',
          ),
        ],
      ),
      const PolicySection(
        titleJa: '3. 再発防止',
        titleEn: '3. Preventive Measures',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'レポート内容を分析し、テンプレート改善やレート制限などの機能改善を行います。安全に関するインサイトはチーム内の週次レビューで共有します。',
            en: 'We analyse reports to inform improvements such as template updates or rate limiting. Safety insights are reviewed in weekly team meetings.',
          ),
        ],
      ),
    ],
  ),
};

extension PolicyDocumentIdExt on PolicyDocumentId {
  IconData get icon {
    switch (this) {
      case PolicyDocumentId.terms:
        return Icons.rule_rounded;
      case PolicyDocumentId.privacy:
        return Icons.verified_user_outlined;
      case PolicyDocumentId.community:
        return Icons.shield_moon_outlined;
    }
  }
}
