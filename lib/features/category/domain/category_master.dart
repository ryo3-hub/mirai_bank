// カテゴリ作成時に選べるプリセット（マスター）データ（issue #97）。
//
// CSV `docs/category_master.csv` の内容を Dart の `const` データとして
// 保持する。ユーザーが選んだ master の小カテゴリ key を `Category.masterKey`
// に保存して由来を辿れるようにする。

class CategoryMasterMajor {
  const CategoryMasterMajor({
    required this.key,
    required this.name,
    required this.kana,
    required this.iconCode,
    required this.colorCode,
  });

  /// 英小文字スネークケースの一意キー（例: `language`, `programming`）。
  final String key;

  /// 表示名（例: 「語学学習」）。
  final String name;

  /// 五十音ソート用の読み（ひらがな）。
  final String kana;

  /// 既定アイコンコード（`CategoryPresets.icons` のキー）。
  final String iconCode;

  /// 既定カラーコード（`CategoryPresets.colors` のいずれか）。
  final String colorCode;
}

class CategoryMasterMinor {
  const CategoryMasterMinor({
    required this.key,
    required this.majorKey,
    required this.name,
    required this.kana,
    required this.recommendedRate,
  });

  /// 英小文字スネークケースの一意キー（`Category.masterKey` で参照）。
  final String key;

  /// 親 major の [CategoryMasterMajor.key]。
  final String majorKey;

  /// 表示名（例: 「英語」）。CSV の `minor_category` をそのまま使う。
  final String name;

  /// 五十音ソート用の読み（ひらがな）。
  final String kana;

  /// 推奨時給（円）。
  final int recommendedRate;
}

/// マスタデータの集約クラス。`const` リストでコンパイル時に保持。
class CategoryMaster {
  const CategoryMaster._();

  /// 全 14 大カテゴリ（**五十音順** で並べてある）。
  static const List<CategoryMasterMajor> majors = [
    CategoryMasterMajor(
      key: 'exercise',
      name: '運動・トレーニング',
      kana: 'うんどう',
      iconCode: 'fitness_center',
      colorCode: '#D32F2F',
    ),
    CategoryMasterMajor(
      key: 'academic',
      name: '学問・教養',
      kana: 'がくもん',
      iconCode: 'menu_book',
      colorCode: '#5D4037',
    ),
    CategoryMasterMajor(
      key: 'creative',
      name: 'クリエイティブ制作',
      kana: 'くりえいてぃぶ',
      iconCode: 'palette',
      colorCode: '#7B1FA2',
    ),
    CategoryMasterMajor(
      key: 'health',
      name: '健康管理',
      kana: 'けんこう',
      iconCode: 'self_improvement',
      colorCode: '#0097A7',
    ),
    CategoryMasterMajor(
      key: 'communication',
      name: 'コミュニケーション',
      kana: 'こみゅにけーしょん',
      iconCode: 'translate',
      colorCode: '#F57C00',
    ),
    CategoryMasterMajor(
      key: 'language',
      name: '語学学習',
      kana: 'ごがく',
      iconCode: 'language',
      colorCode: '#1976D2',
    ),
    CategoryMasterMajor(
      key: 'qualification',
      name: '資格・検定',
      kana: 'しかく',
      iconCode: 'school',
      colorCode: '#7B1FA2',
    ),
    CategoryMasterMajor(
      key: 'work',
      name: '仕事・本業',
      kana: 'しごと',
      iconCode: 'work',
      colorCode: '#455A64',
    ),
    CategoryMasterMajor(
      key: 'investment',
      name: '資産形成・投資',
      kana: 'しさん',
      iconCode: 'calculate',
      colorCode: '#2E7D5B',
    ),
    CategoryMasterMajor(
      key: 'hobby',
      name: '趣味',
      kana: 'しゅみ',
      iconCode: 'music_note',
      colorCode: '#F57C00',
    ),
    CategoryMasterMajor(
      key: 'self_dev',
      name: '自己啓発・マインド',
      kana: 'じこけいはつ',
      iconCode: 'self_improvement',
      colorCode: '#7B1FA2',
    ),
    CategoryMasterMajor(
      key: 'reading',
      name: '読書・インプット',
      kana: 'どくしょ',
      iconCode: 'menu_book',
      colorCode: '#5D4037',
    ),
    CategoryMasterMajor(
      key: 'sidejob',
      name: '副業・フリーランス',
      kana: 'ふくぎょう',
      iconCode: 'work',
      colorCode: '#F57C00',
    ),
    CategoryMasterMajor(
      key: 'programming',
      name: 'プログラミング・IT',
      kana: 'ぷろぐらみんぐ',
      iconCode: 'code',
      colorCode: '#0097A7',
    ),
  ];

  /// 全 55 小カテゴリ（key で一意）。各 major 内では五十音順。
  static const List<CategoryMasterMinor> minors = [
    // 運動・トレーニング（五十音順: ゆうさんそ・きんとれ・すぽーつ・よが）
    CategoryMasterMinor(
      key: 'strength',
      majorKey: 'exercise',
      name: '筋トレ',
      kana: 'きんとれ',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'sports',
      majorKey: 'exercise',
      name: 'スポーツ・武道',
      kana: 'すぽーつ',
      recommendedRate: 900,
    ),
    CategoryMasterMinor(
      key: 'aerobic',
      majorKey: 'exercise',
      name: '有酸素運動',
      kana: 'ゆうさんそ',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'yoga',
      majorKey: 'exercise',
      name: 'ヨガ・ストレッチ',
      kana: 'よが',
      recommendedRate: 800,
    ),

    // 学問・教養
    CategoryMasterMinor(
      key: 'sciences',
      majorKey: 'academic',
      name: '自然科学系',
      kana: 'しぜんかがく',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'humanities',
      majorKey: 'academic',
      name: '人文系',
      kana: 'じんぶん',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'math',
      majorKey: 'academic',
      name: '数学・統計',
      kana: 'すうがく',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'law_econ',
      majorKey: 'academic',
      name: '法律・経済・経営',
      kana: 'ほうりつ',
      recommendedRate: 1000,
    ),

    // クリエイティブ制作
    CategoryMasterMinor(
      key: 'illustration',
      majorKey: 'creative',
      name: 'イラスト・絵画',
      kana: 'いらすと',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'music_creation',
      majorKey: 'creative',
      name: '音楽制作・作曲',
      kana: 'おんがく',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'modeling_3d',
      majorKey: 'creative',
      name: '3DCG・モデリング',
      kana: 'さんでぃーしーじー',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'photo_video',
      majorKey: 'creative',
      name: '写真・動画',
      kana: 'しゃしん',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'writing_novel',
      majorKey: 'creative',
      name: '執筆・小説',
      kana: 'しっぴつ',
      recommendedRate: 1000,
    ),

    // 健康管理
    CategoryMasterMinor(
      key: 'cooking_health',
      majorKey: 'health',
      name: '食事・自炊',
      kana: 'しょくじ',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'sleep',
      majorKey: 'health',
      name: '睡眠・休養',
      kana: 'すいみん',
      recommendedRate: 700,
    ),
    CategoryMasterMinor(
      key: 'meditation',
      majorKey: 'health',
      name: '瞑想・マインドフルネス',
      kana: 'めいそう',
      recommendedRate: 800,
    ),

    // 語学学習
    CategoryMasterMinor(
      key: 'english',
      majorKey: 'language',
      name: '英語',
      kana: 'えいご',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'korean',
      majorKey: 'language',
      name: '韓国語',
      kana: 'かんこくご',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'other_language',
      majorKey: 'language',
      name: 'その他の言語',
      kana: 'そのた',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'chinese',
      majorKey: 'language',
      name: '中国語',
      kana: 'ちゅうごくご',
      recommendedRate: 1000,
    ),

    // コミュニケーション
    CategoryMasterMinor(
      key: 'negotiation',
      majorKey: 'communication',
      name: '交渉術・対人スキル',
      kana: 'こうしょう',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'speech',
      majorKey: 'communication',
      name: 'プレゼン・スピーチ練習',
      kana: 'ぷれぜん',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'interview',
      majorKey: 'communication',
      name: '面接・転職準備',
      kana: 'めんせつ',
      recommendedRate: 1500,
    ),

    // 資格・検定
    CategoryMasterMinor(
      key: 'it_cert',
      majorKey: 'qualification',
      name: 'IT系資格',
      kana: 'あいてぃー',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'other_cert',
      majorKey: 'qualification',
      name: 'その他の資格',
      kana: 'そのた',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'national_cert',
      majorKey: 'qualification',
      name: '国家資格',
      kana: 'こっか',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'business_cert',
      majorKey: 'qualification',
      name: 'ビジネス系資格',
      kana: 'びじねす',
      recommendedRate: 1000,
    ),

    // 仕事・本業
    CategoryMasterMinor(
      key: 'career',
      majorKey: 'work',
      name: 'キャリア設計',
      kana: 'きゃりあ',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'work_skill',
      majorKey: 'work',
      name: '業務スキル研鑽',
      kana: 'ぎょうむ',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'research',
      majorKey: 'work',
      name: '業界・市場リサーチ',
      kana: 'ぎょうかい',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'presentation',
      majorKey: 'work',
      name: '資料作成・プレゼン準備',
      kana: 'しりょう',
      recommendedRate: 1500,
    ),

    // 資産形成・投資
    CategoryMasterMinor(
      key: 'finance',
      majorKey: 'investment',
      name: '家計・節約・税金',
      kana: 'かけい',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'invest_study',
      majorKey: 'investment',
      name: '投資の勉強',
      kana: 'とうし',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'realestate_crypto',
      majorKey: 'investment',
      name: '不動産・仮想通貨',
      kana: 'ふどうさん',
      recommendedRate: 1500,
    ),

    // 自己啓発・マインド
    CategoryMasterMinor(
      key: 'coaching',
      majorKey: 'self_dev',
      name: 'コーチング・メンタルケア',
      kana: 'こーちんぐ',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'journaling',
      majorKey: 'self_dev',
      name: 'ジャーナリング・振り返り',
      kana: 'じゃーなりんぐ',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'habit',
      majorKey: 'self_dev',
      name: '目標設定・習慣化',
      kana: 'もくひょう',
      recommendedRate: 1000,
    ),

    // 趣味
    CategoryMasterMinor(
      key: 'game',
      majorKey: 'hobby',
      name: 'ゲーム・将棋・囲碁',
      kana: 'げーむ',
      recommendedRate: 600,
    ),
    CategoryMasterMinor(
      key: 'camera',
      majorKey: 'hobby',
      name: '写真・カメラ',
      kana: 'しゃしん',
      recommendedRate: 700,
    ),
    CategoryMasterMinor(
      key: 'craft',
      majorKey: 'hobby',
      name: '手芸・DIY・園芸',
      kana: 'しゅげい',
      recommendedRate: 700,
    ),
    CategoryMasterMinor(
      key: 'other_hobby',
      majorKey: 'hobby',
      name: 'その他の趣味',
      kana: 'そのた',
      recommendedRate: 600,
    ),
    CategoryMasterMinor(
      key: 'instrument',
      majorKey: 'hobby',
      name: '楽器演奏',
      kana: 'がっき',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'cooking_hobby',
      majorKey: 'hobby',
      name: '料理',
      kana: 'りょうり',
      recommendedRate: 700,
    ),

    // 読書・インプット
    CategoryMasterMinor(
      key: 'tech_book',
      majorKey: 'reading',
      name: '技術書・専門書',
      kana: 'ぎじゅつしょ',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'general_book',
      majorKey: 'reading',
      name: '教養書・新書',
      kana: 'きょうようしょ',
      recommendedRate: 700,
    ),
    CategoryMasterMinor(
      key: 'news',
      majorKey: 'reading',
      name: '業界ニュース・記事',
      kana: 'ぎょうかい',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'business_book',
      majorKey: 'reading',
      name: 'ビジネス書・自己啓発',
      kana: 'びじねす',
      recommendedRate: 800,
    ),

    // 副業・フリーランス
    CategoryMasterMinor(
      key: 'sales',
      majorKey: 'sidejob',
      name: '営業・案件獲得',
      kana: 'えいぎょう',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'indiedev',
      majorKey: 'sidejob',
      name: '個人開発・プロダクト制作',
      kana: 'こじん',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'design',
      majorKey: 'sidejob',
      name: 'デザイン・動画制作',
      kana: 'でざいん',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'writing',
      majorKey: 'sidejob',
      name: 'ブログ・ライティング',
      kana: 'ぶろぐ',
      recommendedRate: 1200,
    ),

    // プログラミング・IT
    CategoryMasterMinor(
      key: 'ai_data',
      majorKey: 'programming',
      name: 'AI・データ分析',
      kana: 'えーあい',
      recommendedRate: 1800,
    ),
    CategoryMasterMinor(
      key: 'web_dev',
      majorKey: 'programming',
      name: 'Web・アプリ開発',
      kana: 'うぇぶ',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'other_it',
      majorKey: 'programming',
      name: 'その他IT技術',
      kana: 'そのた',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'infra',
      majorKey: 'programming',
      name: 'インフラ・クラウド',
      kana: 'いんふら',
      recommendedRate: 1500,
    ),
  ];

  /// minor key で参照（見つからなければ null）。
  static CategoryMasterMinor? findMinor(String? key) {
    if (key == null) return null;
    for (final m in minors) {
      if (m.key == key) return m;
    }
    return null;
  }

  static CategoryMasterMajor? findMajor(String key) {
    for (final m in majors) {
      if (m.key == key) return m;
    }
    return null;
  }

  /// 指定 major の小カテゴリを五十音順で返す。
  static List<CategoryMasterMinor> minorsFor(String majorKey) {
    final list = minors.where((m) => m.majorKey == majorKey).toList();
    list.sort((a, b) => a.kana.compareTo(b.kana));
    return list;
  }
}
