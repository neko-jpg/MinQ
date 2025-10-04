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
    titleJa: '蛻ｩ逕ｨ隕冗ｴ・& 繧ｳ繝溘Η繝九ユ繧｣繧ｬ繧､繝峨Λ繧､繝ｳ',
    titleEn: 'Terms of Service & Community Guidelines',
    lastUpdated: '2024-06-26',
    highlightTag: '13豁ｳ莉･荳翫・譁ｹ縺ｮ縺ｿ縺泌茜逕ｨ縺・◆縺縺代∪縺・,
    sections: <PolicySection>[
      PolicySection(
        titleJa: '1. 繧ｵ繝ｼ繝薙せ讎りｦ・,
        titleEn: '1. Service Overview',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'MinQ縺ｯ縲∝諺蜷阪・繝壹い縺ｨ蜈ｱ縺ｫ1譌･3繧ｿ繝・・縺ｧ鄙呈・蛹悶ｒ菫・☆繝｢繝舌う繝ｫ繧｢繝励Μ縺ｧ縺吶ょ茜逕ｨ閠・・蛹ｿ蜷阪・繝ｭ繝輔ぅ繝ｼ繝ｫ繧剃ｽ懈・縺励∫ｿ呈・繧ｯ繧ｨ繧ｹ繝医・險倬鹸縲￣air縺ｨ縺ｮ繝上う繧ｿ繝・メ繧帝壹§縺溷干縺ｾ縺励ｒ陦後∴縺ｾ縺吶・,
            en: 'MinQ is a mobile application that helps users build habits with an anonymous partner in as little as three taps per day. Users create an anonymous profile to log quests and exchange supportive high-fives with their pair.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '2. 13豁ｳ莉･荳翫・蛻ｩ逕ｨ譚｡莉ｶ',
        titleEn: '2. Age Requirement (13+)',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '譛ｬ繧ｵ繝ｼ繝薙せ縺ｯ13豁ｳ莉･荳翫・譁ｹ繧貞ｯｾ雎｡縺ｨ縺励※縺・∪縺吶よ悴謌仙ｹｴ縺ｮ譁ｹ縺ｯ菫晁ｭｷ閠・・蜷梧э繧貞ｾ励◆荳翫〒縺泌茜逕ｨ縺上□縺輔＞縲・3豁ｳ譛ｪ貅縺ｮ譁ｹ縺ｯ逋ｻ骭ｲ繧・茜逕ｨ縺ｯ縺ｧ縺阪∪縺帙ｓ縲・,
            en: 'This service is intended for individuals aged 13 and older. Minors should obtain consent from a guardian before using the app. Users under the age of 13 are not permitted to register or use MinQ.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '3. 繧ｳ繝溘Η繝九ユ繧｣繧ｬ繧､繝峨Λ繧､繝ｳ',
        titleEn: '3. Community Guidelines',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'Pair縺ｨ縺ｮ繧・ｊ蜿悶ｊ縺ｯ莠偵＞繧貞ｰ企㍾縺吶ｋ蟋ｿ蜍｢縺ｧ陦後＞縲∬ｪｹ隰嶺ｸｭ蛯ｷ繧・ワ繝ｩ繧ｹ繝｡繝ｳ繝医∝倶ｺｺ諠・ｱ縺ｮ蜈ｱ譛峨ｒ遖∵ｭ｢縺励∪縺吶ゆｸ埼←蛻・↑蛻ｩ逕ｨ縺悟ｱ蜻翫＆繧後◆蝣ｴ蜷医・繧｢繧ｫ繧ｦ繝ｳ繝亥宛髯舌∝●豁｢繧定｡後＞縺ｾ縺吶・,
            en: 'Interact with your pair respectfully. Harassment, abusive language, and sharing personally identifiable information are prohibited. Accounts may be limited or suspended if inappropriate behaviour is reported.',
          ),
          PolicyParagraph(
            ja: '蜈ｱ譛峨☆繧句・逵溘・譛ｬ莠ｺ繧・ｬｬ荳芽・・蛟倶ｺｺ諠・ｱ縺悟・繧願ｾｼ縺ｾ縺ｪ縺・ｈ縺・↓縺励※縺上□縺輔＞縲る＆蜿阪′隕九▽縺九▲縺溷ｴ蜷医・蜑企勁繧・ｯｩ譟ｻ蟇ｾ雎｡縺ｨ縺ｪ繧翫∪縺吶・,
            en: 'Ensure that proof photos do not expose personal information about yourself or others. Violations may lead to removal or moderation review.',
          ),
          PolicyParagraph(
            ja: '迚ｹ縺ｫ縲∵悴謌仙ｹｴ閠・・螳牙・繧堤｢ｺ菫昴☆繧九◆繧√∵・莠ｺ繝ｦ繝ｼ繧ｶ繝ｼ縺梧悴謌仙ｹｴ閠・↓蟇ｾ縺励※荳埼←蛻・↑髢｢菫ゅｒ豎ゅａ繧玖ｨ蜍輔ｄ縲∝倶ｺｺ諠・ｱ繧定◇縺榊・縺呵｡檎ぜ繧貞崋縺冗ｦ√§縺ｾ縺吶ゆｿ晁ｭｷ閠・・譁ｹ縺ｯ縲∵悴謌仙ｹｴ縺ｮ縺雁ｭ先ｧ倥・蛻ｩ逕ｨ迥ｶ豕√ｒ驕ｩ蛻・↓逶｣逹｣縺吶ｋ雋ｬ莉ｻ繧定ｲ縺・∪縺吶・,
            en: 'To ensure the safety of minors, adult users are strictly prohibited from soliciting inappropriate relationships or personal information from minors. Guardians are responsible for appropriately supervising their minor\'s use of the service.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '4. 騾壼ｱ繝ｻ繝悶Ο繝・け',
        titleEn: '4. Reporting & Blocking',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: 'Pair縺ｨ縺ｮ繧・ｊ蜿悶ｊ縺ｧ荳榊ｿｫ縺ｪ菴馴ｨ薙′縺ゅ▲縺溷ｴ蜷医・縲√い繝励Μ蜀・・繝｡繝九Η繝ｼ縺九ｉ騾壼ｱ繝ｻ繝悶Ο繝・け縺悟庄閭ｽ縺ｧ縺吶る壼ｱ縺ｯ24譎る俣莉･蜀・↓荳谺｡蟇ｾ蠢懊＠縲∝ｮ牙・繝√・繝縺檎憾豕√ｒ遒ｺ隱阪＠縺ｾ縺吶・,
            en: 'If you encounter uncomfortable behaviour, use the in-app menu to report or block your pair. Reports receive an initial review within 24 hours by the safety team.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '5. Pair讖溯・縺ｫ縺翫￠繧狗ｦ∵ｭ｢莠矩・,
        titleEn: '5. Prohibited Behaviour in Pair Mode',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                '譛ｪ謌仙ｹｴ閠・酔螢ｫ縺ｮ繝壹い繝ｪ繝ｳ繧ｰ縺ｯ縲∝酔蟷ｴ莉｣縺九▽蟄ｦ鄙堤岼逧・↓髯仙ｮ壹＆繧後∪縺吶よ・莠ｺ繝ｦ繝ｼ繧ｶ繝ｼ縺ｯ譛ｪ謌仙ｹｴ縺ｨ縺ｮ蛟句挨騾｣邨｡縲√が繝輔Λ繧､繝ｳ縺ｧ縺ｮ謗･隗ｦ隕∬ｫ九・≡驫ｭ繧・ぐ繝輔ヨ縺ｮ隕∵ｱゅ∝倶ｺｺ諠・ｱ・域ｰ丞錐繝ｻ騾｣邨｡蜈医・蟄ｦ譬｡蜷阪↑縺ｩ・峨・蜿門ｾ励ｒ荳蛻・｡後▲縺ｦ縺ｯ縺・￠縺ｾ縺帙ｓ縲る＆蜿阪′遒ｺ隱阪＆繧後◆蝣ｴ蜷医・蜊ｳ譎ゅ↓繝壹い隗｣豸医・繧｢繧ｫ繧ｦ繝ｳ繝亥●豁｢繧定｡後＞縺ｾ縺吶・,
            en:
                'Pairing between minors is restricted to peers with educational goals only. Adult users must never initiate private contact with minors, request offline meetings, solicit money or gifts, or collect personally identifiable information (such as real names, contact details, or school names). Any violation results in immediate pair termination and possible account suspension.',
          ),
          PolicyParagraph(
            ja:
                '蟷ｴ鮨｢縺ｫ縺九°繧上ｉ縺壹∵ｧ逧・↑陦ｨ迴ｾ縲√ョ繝ｼ繝医・繝槭ャ繝√Φ繧ｰ逶ｮ逧・・蛻ｩ逕ｨ縲∬ｳｭ蜊壹・驥題檮蝠・刀縺ｮ蜍ｧ隱倥∝匡隱倥Μ繝ｳ繧ｯ縺ｮ騾∽ｻ倥・遖∵ｭ｢縺ｧ縺吶る＆蜿阪ｒ蜿励￠縺溷ｴ蜷医・騾壼ｱ讖溯・縺九ｉ螳牙・繝√・繝縺ｫ縺顔衍繧峨○縺上□縺輔＞縲・,
            en:
                'Regardless of age, sexual content, dating or matchmaking solicitations, gambling, financial product promotions, and referral links are prohibited. If you encounter these behaviours, report them to the safety team using the in-app reporting tools.',
          ),
        ],
      ),
    ],
  ),
  PolicyDocumentId.privacy: const PolicyDocument(
    id: PolicyDocumentId.privacy,
    titleJa: '繝励Λ繧､繝舌す繝ｼ繝昴Μ繧ｷ繝ｼ',
    titleEn: 'Privacy Policy',
    lastUpdated: '2024-06-26',
    sections: <PolicySection>[
      PolicySection(
        titleJa: '1. 蜿朱寔縺吶ｋ諠・ｱ',
        titleEn: '1. Information We Collect',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '蛹ｿ蜷阪・繝ｭ繝輔ぅ繝ｼ繝ｫ縲√い繝励Μ蜀・・Quest驕疲・繝ｭ繧ｰ縲￣air縺ｨ縺ｮ繝上う繧ｿ繝・メ螻･豁ｴ縲・夂衍險ｭ螳壹∽ｻｻ諢上〒騾｣謳ｺ縺励◆Google繧｢繧ｫ繧ｦ繝ｳ繝・D繧貞叙蠕励＠縺ｾ縺吶ょ・逵溯ｨｼ霍｡縺ｯ遶ｯ譛ｫ蜀・〒EXIF繧帝勁蜴ｻ縺励√ワ繝・す繝･蛹悶＆繧後◆繝輔ぃ繧､繝ｫ蜷阪〒菫晏ｭ倥＆繧後∪縺吶・,
            en: 'We collect anonymous profile details, quest completion logs, pair high-five history, notification preferences, and optional linked Google account IDs. Photo proofs have EXIF data removed on-device and are stored using hashed filenames.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '2. 蛻ｩ逕ｨ逶ｮ逧・,
        titleEn: '2. How We Use Information',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '鄙呈・邯咏ｶ壹・蜿ｯ隕門喧縲・夂衍驟堺ｿ｡縲√・繝・メ繝ｳ繧ｰ邊ｾ蠎ｦ蜷台ｸ翫√い繝励Μ謾ｹ蝟・・縺溘ａ縺ｮ蛻・梵縺ｫ蛻ｩ逕ｨ縺励∪縺吶ょ倶ｺｺ縺檎音螳壹〒縺阪ｋ蠖｢縺ｧ隨ｬ荳芽・→蜈ｱ譛峨☆繧九％縺ｨ縺ｯ縺ゅｊ縺ｾ縺帙ｓ縲・,
            en: 'Data is used to visualise progress, deliver notifications, improve matching quality, and analyse app performance. We do not share data with third parties in a personally identifiable form.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '3. 繝・・繧ｿ縺ｮ菫晁ｭｷ縺ｨ菫晄戟譛滄俣',
        titleEn: '3. Data Protection & Retention',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '騾壻ｿ｡縺ｯ縺吶∋縺ｦTLS縺ｧ證怜捷蛹悶＆繧後∽ｿ晏ｭ倥ョ繝ｼ繧ｿ縺ｯ證怜捷蛹悶＆繧後◆繧ｹ繝医Ξ繝ｼ繧ｸ縺ｫ菫晄戟縺輔ｌ縺ｾ縺吶ゅい繧ｫ繧ｦ繝ｳ繝亥炎髯､逕ｳ隲九°繧・譌･髢薙・蠕ｩ蜈・幻莠域悄髢薙′邨碁℃縺励◆蠕後√ョ繝ｼ繧ｿ繧貞ｮ悟・縺ｫ蜑企勁縺励∪縺吶ゅ％縺ｮ譛滄俣蜀・↓蜀榊ｺｦ繝ｭ繧ｰ繧､繝ｳ縺吶ｋ縺ｨ縲∝炎髯､繝ｪ繧ｯ繧ｨ繧ｹ繝医・繧ｭ繝｣繝ｳ繧ｻ繝ｫ縺輔ｌ縺ｾ縺吶・,
            en: 'All network traffic is encrypted via TLS and stored data resides in encrypted storage. After a 7-day grace period following an account deletion request, all data is permanently removed. Logging in again within this period will cancel the deletion request.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '4. 繝ｦ繝ｼ繧ｶ繝ｼ縺ｮ讓ｩ蛻ｩ',
        titleEn: '4. Your Rights',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '繧｢繝励Μ蜀・°繧峨ョ繝ｼ繧ｿ縺ｮ髢ｲ隕ｧ縲√お繧ｯ繧ｹ繝昴・繝医∝炎髯､逕ｳ隲九′蜿ｯ閭ｽ縺ｧ縺吶ゅ♀蝠上＞蜷医ｏ縺帙・ support@minq.app 縺ｾ縺ｧ縺雁ｯ・○縺上□縺輔＞縲・,
            en: 'You can review, export, or request deletion of your data from within the app. Contact support@minq.app for assistance.',
          ),
        ],
      ),
    ],
  ),
  PolicyDocumentId.community: const PolicyDocument(
    id: PolicyDocumentId.community,
    titleJa: '螳牙・蟇ｾ遲・& 騾壼ｱ蟇ｾ蠢・,
    titleEn: 'Safety Measures & Reporting SOP',
    lastUpdated: '2024-06-26',
    sections: <PolicySection>[
      PolicySection(
        titleJa: '1. 蛻晏虚蟇ｾ蠢・,
        titleEn: '1. Initial Response',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '騾壼ｱ繧貞女鬆伜ｾ・4譎る俣莉･蜀・↓諡・ｽ楢・′迥ｶ豕√ｒ遒ｺ隱阪＠縲∵圻螳壽蒔鄂ｮ・・air縺ｮ荳譎ょ●豁｢縺ｪ縺ｩ・峨ｒ隰帙§縺ｾ縺吶・,
            en: 'Within 24 hours of receiving a report, our team reviews the situation and may take interim actions such as temporarily pausing the pair.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '2. 隱ｿ譟ｻ縺ｨ騾｣邨｡',
        titleEn: '2. Investigation & Communication',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '繝ｭ繧ｰ繧・∝女菫｡繝｡繝・そ繝ｼ繧ｸ繧定ｪｿ譟ｻ縺励∝ｿ・ｦ√↓蠢懊§縺ｦ霑ｽ蜉諠・ｱ繧剃ｾ晞ｼ縺励∪縺吶りｪｿ譟ｻ邨先棡縺ｨ蟇ｾ蠢懈婿驥昴・騾壼ｱ閠・↓繝｡繝ｼ繝ｫ縺ｧ蜈ｱ譛峨＠縺ｾ縺吶・,
            en: 'We review logs and partner interactions and request additional details if required. Findings and resolutions are shared with the reporter via email.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '3. 蜀咲匱髦ｲ豁｢',
        titleEn: '3. Preventive Measures',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja: '繝ｬ繝昴・繝亥・螳ｹ繧貞・譫舌＠縲√ユ繝ｳ繝励Ξ繝ｼ繝域隼蝟・ｄ繝ｬ繝ｼ繝亥宛髯舌↑縺ｩ縺ｮ讖溯・謾ｹ蝟・ｒ陦後＞縺ｾ縺吶ょｮ牙・縺ｫ髢｢縺吶ｋ繧､繝ｳ繧ｵ繧､繝医・繝√・繝蜀・・騾ｱ谺｡繝ｬ繝薙Η繝ｼ縺ｧ蜈ｱ譛峨＠縺ｾ縺吶・,
            en: 'We analyse reports to inform improvements such as template updates or rate limiting. Safety insights are reviewed in weekly team meetings.',
          ),
        ],
      ),
    ],
  ),
  PolicyDocumentId.licenses: const PolicyDocument(
    id: PolicyDocumentId.licenses,
    titleJa: '繧ｳ繝ｳ繝・Φ繝・ｨｩ蛻ｩ & 繝ｩ繧､繧ｻ繝ｳ繧ｹ荳隕ｧ',
    titleEn: 'Content Rights & Licensing Overview',
    lastUpdated: '2024-07-01',
    sections: <PolicySection>[
      PolicySection(
        titleJa: '1. 繝薙ず繝･繧｢繝ｫ繧｢繧ｻ繝・ヨ',
        titleEn: '1. Visual Assets',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                '繧｢繝励Μ繧｢繧､繧ｳ繝ｳ縺翫ｈ縺ｳ繧､繝ｩ繧ｹ繝医・遉ｾ蜀・ョ繧ｶ繧､繝ｳ繝√・繝縺ｫ繧医ｋ繧ｪ繝ｪ繧ｸ繝翫Ν蛻ｶ菴懃黄縺ｧ縺吶らｬｬ荳芽・署萓帷ｴ譚舌・菴ｿ逕ｨ縺励※縺・∪縺帙ｓ縲・,
            en:
                'App icons and illustrations are original works created by the in-house design team. No third-party stock materials are included.',
          ),
          PolicyParagraph(
            ja:
                'UI縺ｮ荳ｻ隕√ヵ繧ｩ繝ｳ繝医↓縺ｯ Google Fonts 縺ｮ Noto Sans JP / Inter 繧呈治逕ｨ縺励ヾIL Open Font License 1.1 縺ｫ蝓ｺ縺･縺・※蜀埼・蟶・＠縺ｦ縺・∪縺吶・,
            en:
                'The primary UI fonts are Noto Sans JP and Inter (Google Fonts) redistributed under the SIL Open Font License 1.1.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '2. 繧｢繧､繧ｳ繝ｳ & 繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ',
        titleEn: '2. Icons & Animations',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                '繧｢繝励Μ蜀・い繧､繧ｳ繝ｳ縺ｯ Material Symbols 繧偵・繝ｼ繧ｹ縺ｫ繧ｫ繧ｹ繧ｿ繝槭う繧ｺ縺励※縺・∪縺吶・aterial Symbols 縺ｮ繝ｩ繧､繧ｻ繝ｳ繧ｹ・・pache License 2.0・峨↓蠕薙＞陦ｨ險倥＠縺ｦ縺・∪縺吶・,
            en:
                'In-app icons originate from Material Symbols with bespoke adjustments. Attribution follows the Apache License 2.0 terms.',
          ),
          PolicyParagraph(
            ja:
                '繧ｳ繝ｳ繝輔ぉ繝・ユ繧｣遲峨・繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ縺ｯ LottieFiles 縺ｮ縲靴elebration Pack縲搾ｼ・C BY 4.0・峨ｒ蜉蟾･縺嶺ｽｿ逕ｨ縺励※縺・∪縺吶ょ・蜈ｸ繧ｯ繝ｬ繧ｸ繝・ヨ繧偵い繝励Μ蜀・↓譏手ｨ倥＠縺ｦ縺・∪縺吶・,
            en:
                'Animations such as confetti leverage the LottieFiles 窶廚elebration Pack窶・(CC BY 4.0) with modifications. Credits are declared within the app.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '3. 蜉ｹ譫憺浹 & BGM',
        titleEn: '3. Sound Effects & BGM',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                '險倬鹸螳御ｺ・凾縺ｮ繧ｵ繧ｦ繝ｳ繝峨・縲郡oundeffect-lab縲阪ｈ繧・CC0 繝ｩ繧､繧ｻ繝ｳ繧ｹ縺ｧ蜿門ｾ励＠縺溽ｴ譚舌ｒ菴ｿ逕ｨ縺励∵隼螟牙ｾ後↓繧ｯ繝ｬ繧ｸ繝・ヨ繧呈軸遉ｺ縺励※縺・∪縺吶・,
            en:
                'Record completion sounds derive from Soundeffect-lab CC0 assets with post-processing; acknowledgement is displayed in-app.',
          ),
          PolicyParagraph(
            ja:
                '縺昴・莉悶・BGM縺ｯ Epidemic Sound 縺ｮ繧ｵ繝悶せ繧ｯ繝ｪ繝励す繝ｧ繝ｳ螂醍ｴ・↓蝓ｺ縺･縺榊茜逕ｨ縺励※縺・∪縺呻ｼ医ヨ繝ｩ繝・けID縺ｯ繝ｪ繝ｪ繝ｼ繧ｹ繝弱・繝医↓險倩ｼ会ｼ峨・,
            en:
                'Ambient BGM uses licensed tracks from Epidemic Sound via subscription; track IDs are documented in release notes.',
          ),
        ],
      ),
      PolicySection(
        titleJa: '4. OSS繧ｳ繝ｳ繝昴・繝阪Φ繝・,
        titleEn: '4. Open Source Software Components',
        paragraphs: <PolicyParagraph>[
          PolicyParagraph(
            ja:
                'Flutter, Riverpod, Isar, Firebase 縺ｪ縺ｩ縺ｮOSS繝ｩ繧､繝悶Λ繝ｪ縺ｯ蜷・Λ繧､繧ｻ繝ｳ繧ｹ・・SD, MIT, Apache 2.0 遲会ｼ峨↓蠕薙▲縺ｦ蛻ｩ逕ｨ縺励※縺・∪縺吶・,
            en:
                'Flutter, Riverpod, Isar, Firebase and other OSS libraries are used under their respective licenses (BSD, MIT, Apache 2.0, etc.).',
          ),
          PolicyParagraph(
            ja:
                '萓晏ｭ倥Λ繧､繝悶Λ繝ｪ荳隕ｧ縺ｨ繝ｩ繧､繧ｻ繝ｳ繧ｹ蜈ｨ譁・・繧｢繝励Μ蜀・瑚ｨｭ螳・> 繧ｳ繝ｳ繝・Φ繝・ｨｩ蛻ｩ縲阪♀繧医・ GitHub 繝ｪ繝昴ず繝医Μ縺ｮ LICENSES.md 縺ｧ蜈ｬ髢九＠縺ｦ縺・∪縺吶・,
            en:
                'Full dependency listings and license texts are available under 窶彜ettings 竊・Content Rights窶・and in the repository窶冱 LICENSES.md.',
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
