import 'package:flutter/material.dart';

enum PolicyDocumentId { terms, privacy, community, licenses }

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
  PolicyDocumentId.terms: const PolicyDocument(
    id: PolicyDocumentId.terms,
    titleJa: '利用規紁E& コミュニティガイドライン',
    titleEn: 'Terms of Service & Community Guidelines',
    lastUpdated: '2024-06-26',
    highlightTag: '13歳以上�E方のみご利用ぁE��だけまぁE,
    sections: <PolicySection>[
      PolicySection(
        titleJa: '1. サービス概要E,
        titleEn: '1. Service Overview',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'MinQは、匿名�Eペアと共に1日3タチE�Eで習�E化を俁E��モバイルアプリです。利用老E�E匿名�Eロフィールを作�Eし、習�Eクエスト�E記録、PairとのハイタチE��を通じた励ましを行えます、E,
            en: 'MinQ is a mobile application that helps users build habits with an anonymous partner in as little as three taps per day. Users create an anonymous profile to log quests and exchange supportive high-fives with their pair.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '2. 13歳以上�E利用条件',
        titleEn: '2. Age Requirement (13+)',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '本サービスは13歳以上�E方を対象としてぁE��す。未成年の方は保護老E�E同意を得た上でご利用ください、E3歳未満の方は登録めE��用はできません、E,
            en: 'This service is intended for individuals aged 13 and older. Minors should obtain consent from a guardian before using the app. Users under the age of 13 are not permitted to register or use MinQ.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '3. コミュニティガイドライン',
        titleEn: '3. Community Guidelines',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'PairとのめE��取りは互いを尊重する姿勢で行い、誹謗中傷めE��ラスメント、個人惁E��の共有を禁止します。不適刁E��利用が報告された場合�Eアカウント制限、停止を行います、E,
            en: 'Interact with your pair respectfully. Harassment, abusive language, and sharing personally identifiable information are prohibited. Accounts may be limited or suspended if inappropriate behaviour is reported.',
          ),
          PolicyParagraph(
            ja: '共有する�E真�E本人めE��三老E�E個人惁E��が�Eり込まなぁE��ぁE��してください。違反が見つかった場合�E削除めE��査対象となります、E,
            en: 'Ensure that proof photos do not expose personal information about yourself or others. Violations may lead to removal or moderation review.',
          ),
          PolicyParagraph(
            ja: '特に、未成年老E�E安�Eを確保するため、�E人ユーザーが未成年老E��対して不適刁E��関係を求める言動や、個人惁E��を聞き�Eす行為を固く禁じます。保護老E�E方は、未成年のお子様�E利用状況を適刁E��監督する責任を負ぁE��す、E,
            en: 'To ensure the safety of minors, adult users are strictly prohibited from soliciting inappropriate relationships or personal information from minors. Guardians are responsible for appropriately supervising their minor\'s use of the service.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '4. 通報・ブロチE��',
        titleEn: '4. Reporting & Blocking',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'PairとのめE��取りで不快な体験があった場合�E、アプリ冁E�Eメニューから通報・ブロチE��が可能です。通報は24時間以冁E��一次対応し、安�Eチ�Eムが状況を確認します、E,
            en: 'If you encounter uncomfortable behaviour, use the in-app menu to report or block your pair. Reports receive an initial review within 24 hours by the safety team.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '5. Pair機�Eにおける禁止事頁E,
        titleEn: '5. Prohibited Behaviour in Pair Mode',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                '未成年老E��士のペアリングは、同年代かつ学習目皁E��限定されます。�E人ユーザーは未成年との個別連絡、オフラインでの接触要請、E��銭めE��フトの要求、個人惁E���E�氏名・連絡先�E学校名など�E��E取得を一刁E��ってはぁE��ません。違反が確認された場合�E即時にペア解消�Eアカウント停止を行います、E,
            en:
                'Pairing between minors is restricted to peers with educational goals only. Adult users must never initiate private contact with minors, request offline meetings, solicit money or gifts, or collect personally identifiable information (such as real names, contact details, or school names). Any violation results in immediate pair termination and possible account suspension.',
          ),
          PolicyParagraph(
            ja:
                '年齢にかかわらず、性皁E��表現、デート�Eマッチング目皁E�E利用、賭博�E金融啁E��の勧誘、勧誘リンクの送付�E禁止です。違反を受けた場合�E通報機�Eから安�Eチ�Eムにお知らせください、E,
            en:
                'Regardless of age, sexual content, dating or matchmaking solicitations, gambling, financial product promotions, and referral links are prohibited. If you encounter these behaviours, report them to the safety team using the in-app reporting tools.',
          ),
        ],
      ),
    ],
  ),
  PolicyDocumentId.privacy: const PolicyDocument(
    id: PolicyDocumentId.privacy,
    titleJa: 'プライバシーポリシー',
    titleEn: 'Privacy Policy',
    lastUpdated: '2024-06-26',
    sections: <PolicySection>[
      PolicySection(
        titleJa: '1. 収集する惁E��',
        titleEn: '1. Information We Collect',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '匿名�Eロフィール、アプリ冁E�EQuest達�Eログ、PairとのハイタチE��履歴、E��知設定、任意で連携したGoogleアカウンチEDを取得します。�E真証跡は端末冁E��EXIFを除去し、ハチE��ュ化されたファイル名で保存されます、E,
            en: 'We collect anonymous profile details, quest completion logs, pair high-five history, notification preferences, and optional linked Google account IDs. Photo proofs have EXIF data removed on-device and are stored using hashed filenames.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '2. 利用目皁E,
        titleEn: '2. How We Use Information',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '習�E継続�E可視化、E��知配信、�EチE��ング精度向上、アプリ改喁E�Eための刁E��に利用します。個人が特定できる形で第三老E��共有することはありません、E,
            en: 'Data is used to visualise progress, deliver notifications, improve matching quality, and analyse app performance. We do not share data with third parties in a personally identifiable form.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '3. チE�Eタの保護と保持期間',
        titleEn: '3. Data Protection & Retention',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '通信はすべてTLSで暗号化され、保存データは暗号化されたストレージに保持されます。アカウント削除申請かめE日間�E復允E��予期間が経過した後、データを完�Eに削除します。この期間冁E��再度ログインすると、削除リクエスト�Eキャンセルされます、E,
            en: 'All network traffic is encrypted via TLS and stored data resides in encrypted storage. After a 7-day grace period following an account deletion request, all data is permanently removed. Logging in again within this period will cancel the deletion request.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '4. ユーザーの権利',
        titleEn: '4. Your Rights',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'アプリ冁E��らデータの閲覧、エクスポ�Eト、削除申請が可能です。お問い合わせ�E support@minq.app までお寁E��ください、E,
            en: 'You can review, export, or request deletion of your data from within the app. Contact support@minq.app for assistance.',
          ),
        ],
      ),
    ],
  ),
  PolicyDocumentId.community: const PolicyDocument(
    id: PolicyDocumentId.community,
    titleJa: '安�E対筁E& 通報対忁E,
    titleEn: 'Safety Measures & Reporting SOP',
    lastUpdated: '2024-06-26',
    sections: <PolicySection>[
      PolicySection(
        titleJa: '1. 初動対忁E,
        titleEn: '1. Initial Response',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '通報を受領征E4時間以冁E��拁E��老E��状況を確認し、暫定措置�E�Eairの一時停止など�E�を講じます、E,
            en: 'Within 24 hours of receiving a report, our team reviews the situation and may take interim actions such as temporarily pausing the pair.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '2. 調査と連絡',
        titleEn: '2. Investigation & Communication',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'ログめE��受信メチE��ージを調査し、忁E��に応じて追加惁E��を依頼します。調査結果と対応方針�E通報老E��メールで共有します、E,
            en: 'We review logs and partner interactions and request additional details if required. Findings and resolutions are shared with the reporter via email.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '3. 再発防止',
        titleEn: '3. Preventive Measures',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'レポ�Eト�E容を�E析し、テンプレート改喁E��レート制限などの機�E改喁E��行います。安�Eに関するインサイト�Eチ�Eム冁E�E週次レビューで共有します、E,
            en: 'We analyse reports to inform improvements such as template updates or rate limiting. Safety insights are reviewed in weekly team meetings.',
          ),
        ],
      ),
    ],
  ),
  PolicyDocumentId.licenses: const PolicyDocument(
    id: PolicyDocumentId.licenses,
    titleJa: 'コンチE��チE��利 & ライセンス一覧',
    titleEn: 'Content Rights & Licensing Overview',
    lastUpdated: '2024-07-01',
    sections: <PolicySection>[
      PolicySection(
        titleJa: '1. ビジュアルアセチE��',
        titleEn: '1. Visual Assets',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                'アプリアイコンおよびイラスト�E社冁E��ザインチ�Eムによるオリジナル制作物です。第三老E��供素材�E使用してぁE��せん、E,
            en:
                'App icons and illustrations are original works created by the in-house design team. No third-party stock materials are included.',
          ),
          PolicyParagraph(
            ja:
                'UIの主要フォントには Google Fonts の Noto Sans JP / Inter を採用し、SIL Open Font License 1.1 に基づぁE��再�E币E��てぁE��す、E,
            en:
                'The primary UI fonts are Noto Sans JP and Inter (Google Fonts) redistributed under the SIL Open Font License 1.1.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '2. アイコン & アニメーション',
        titleEn: '2. Icons & Animations',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                'アプリ冁E��イコンは Material Symbols を�EースにカスタマイズしてぁE��す、Eaterial Symbols のライセンス�E�Epache License 2.0�E�に従い表記してぁE��す、E,
            en:
                'In-app icons originate from Material Symbols with bespoke adjustments. Attribution follows the Apache License 2.0 terms.',
          ),
          PolicyParagraph(
            ja:
                'コンフェチE��ィ等�Eアニメーションは LottieFiles の「Celebration Pack」！EC BY 4.0�E�を加工し使用してぁE��す。�E典クレジチE��をアプリ冁E��明記してぁE��す、E,
            en:
                'Animations such as confetti leverage the LottieFiles “Celebration Pack E(CC BY 4.0) with modifications. Credits are declared within the app.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '3. 効果音 & BGM',
        titleEn: '3. Sound Effects & BGM',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                '記録完亁E��のサウンド�E「Soundeffect-lab」よめECC0 ライセンスで取得した素材を使用し、改変後にクレジチE��を掲示してぁE��す、E,
            en:
                'Record completion sounds derive from Soundeffect-lab CC0 assets with post-processing; acknowledgement is displayed in-app.',
          ),
          PolicyParagraph(
            ja:
                'そ�E他�EBGMは Epidemic Sound のサブスクリプション契紁E��基づき利用してぁE��す（トラチE��IDはリリースノ�Eトに記載）、E,
            en:
                'Ambient BGM uses licensed tracks from Epidemic Sound via subscription; track IDs are documented in release notes.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '4. OSSコンポ�EネンチE,
        titleEn: '4. Open Source Software Components',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                'Flutter, Riverpod, Isar, Firebase などのOSSライブラリは吁E��イセンス�E�ESD, MIT, Apache 2.0 等）に従って利用してぁE��す、E,
            en:
                'Flutter, Riverpod, Isar, Firebase and other OSS libraries are used under their respective licenses (BSD, MIT, Apache 2.0, etc.).',
          ),
          PolicyParagraph(
            ja:
                '依存ライブラリ一覧とライセンス全斁E�Eアプリ冁E��設宁E> コンチE��チE��利」およ�E GitHub リポジトリの LICENSES.md で公開してぁE��す、E,
            en:
                'Full dependency listings and license texts are available under “Settings ↁEContent Rights Eand in the repository’s LICENSES.md.',
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
      case PolicyDocumentId.licenses:
        return Icons.collections_bookmark_outlined;
    }
  }
}
