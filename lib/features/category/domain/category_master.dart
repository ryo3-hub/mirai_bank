// カテゴリ作成時に選べるプリセット（マスター）データ（issue #97 / 刷新 #169）。
//
// 表示順は `docs/category_master.csv` に書かれた順を **そのまま** 採用する
// （CSV の手書き順を信頼できる UI 出現順として扱い、五十音ソートは行わない）。
// 内容を変えたいときは CSV を編集してから、本ファイルもそれに合わせる。
//
// ユーザーが選んだプリセット minor の key は `Category.masterKey` に保存し、
// あとから master を辿れるようにする。マスタから minor を削除しても、
// `findMinor` が null を返すだけで Category 行自体は壊れない設計。

class CategoryMasterMajor {
  const CategoryMasterMajor({
    required this.key,
    required this.name,
    required this.iconCode,
    required this.colorCode,
  });

  /// 英小文字スネークケースの一意キー（例: `language`, `programming`）。
  final String key;

  /// 表示名（例: 「語学学習」）。
  final String name;

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
    required this.recommendedRate,
  });

  /// 英小文字スネークケースの一意キー（`Category.masterKey` で参照）。
  final String key;

  /// 親 major の [CategoryMasterMajor.key]。
  final String majorKey;

  /// 表示名（CSV の `minor_category` をそのまま）。
  final String name;

  /// 推奨時給（円）。CSV の `recommended_hourly_rate`。
  final int recommendedRate;
}

/// マスタデータの集約クラス。`const` リストでコンパイル時に保持。
class CategoryMaster {
  const CategoryMaster._();

  /// 全 15 大カテゴリ。並びは `docs/category_master.csv` の登場順。
  static const List<CategoryMasterMajor> majors = [
    CategoryMasterMajor(
      key: 'language',
      name: '語学学習',
      iconCode: 'language',
      colorCode: '#1976D2',
    ),
    CategoryMasterMajor(
      key: 'programming',
      name: 'プログラミング・IT',
      iconCode: 'code',
      colorCode: '#0097A7',
    ),
    CategoryMasterMajor(
      key: 'qualification',
      name: '資格・検定',
      iconCode: 'school',
      colorCode: '#7B1FA2',
    ),
    CategoryMasterMajor(
      key: 'academic',
      name: '学問・教養',
      iconCode: 'menu_book',
      colorCode: '#5D4037',
    ),
    CategoryMasterMajor(
      key: 'reading',
      name: '読書・インプット',
      iconCode: 'menu_book',
      colorCode: '#5D4037',
    ),
    CategoryMasterMajor(
      key: 'work',
      name: '仕事・本業',
      iconCode: 'work',
      colorCode: '#455A64',
    ),
    CategoryMasterMajor(
      key: 'sidejob',
      name: '副業・フリーランス',
      iconCode: 'work',
      colorCode: '#F57C00',
    ),
    CategoryMasterMajor(
      key: 'investment',
      name: '資産形成・投資',
      iconCode: 'calculate',
      colorCode: '#2E7D5B',
    ),
    CategoryMasterMajor(
      key: 'creative',
      name: 'クリエイティブ制作',
      iconCode: 'palette',
      colorCode: '#7B1FA2',
    ),
    CategoryMasterMajor(
      key: 'exercise',
      name: '運動・トレーニング',
      iconCode: 'fitness_center',
      colorCode: '#D32F2F',
    ),
    CategoryMasterMajor(
      key: 'health',
      name: '健康管理',
      iconCode: 'self_improvement',
      colorCode: '#0097A7',
    ),
    CategoryMasterMajor(
      key: 'self_dev',
      name: '自己啓発・マインド',
      iconCode: 'self_improvement',
      colorCode: '#7B1FA2',
    ),
    CategoryMasterMajor(
      key: 'communication',
      name: 'コミュニケーション',
      iconCode: 'translate',
      colorCode: '#F57C00',
    ),
    // 家事・生活：issue #169 で新設。日常タスクの記録用。
    CategoryMasterMajor(
      key: 'home_life',
      name: '家事・生活',
      iconCode: 'biotech',
      colorCode: '#F57C00',
    ),
    CategoryMasterMajor(
      key: 'hobby',
      name: '趣味',
      iconCode: 'music_note',
      colorCode: '#F57C00',
    ),
  ];

  /// 全 68 小カテゴリ（key で一意）。並びは `docs/category_master.csv` の
  /// 登場順をそのまま採用。
  static const List<CategoryMasterMinor> minors = [
    // 語学学習
    CategoryMasterMinor(
      key: 'english',
      majorKey: 'language',
      name: '英語',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'toeic',
      majorKey: 'language',
      name: 'TOEIC対策',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'chinese',
      majorKey: 'language',
      name: '中国語',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'korean',
      majorKey: 'language',
      name: '韓国語',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'french',
      majorKey: 'language',
      name: 'フランス語',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'german',
      majorKey: 'language',
      name: 'ドイツ語',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'spanish',
      majorKey: 'language',
      name: 'スペイン語',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'other_language',
      majorKey: 'language',
      name: 'その他の言語',
      recommendedRate: 1200,
    ),

    // プログラミング・IT
    CategoryMasterMinor(
      key: 'web_dev',
      majorKey: 'programming',
      name: 'Web・アプリ開発',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'ai_data',
      majorKey: 'programming',
      name: 'AI・データ分析',
      recommendedRate: 2000,
    ),
    CategoryMasterMinor(
      key: 'infra',
      majorKey: 'programming',
      name: 'インフラ・クラウド',
      recommendedRate: 1800,
    ),
    CategoryMasterMinor(
      key: 'other_it',
      majorKey: 'programming',
      name: 'その他IT技術',
      recommendedRate: 1200,
    ),

    // 資格・検定
    CategoryMasterMinor(
      key: 'business_cert',
      majorKey: 'qualification',
      name: 'ビジネス系資格',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'national_cert',
      majorKey: 'qualification',
      name: '国家資格',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'it_cert',
      majorKey: 'qualification',
      name: 'IT系資格',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'university_exam',
      majorKey: 'qualification',
      name: '大学受験',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'highschool_exam',
      majorKey: 'qualification',
      name: '高校受験',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'other_cert',
      majorKey: 'qualification',
      name: 'その他の資格',
      recommendedRate: 1000,
    ),

    // 学問・教養
    CategoryMasterMinor(
      key: 'math',
      majorKey: 'academic',
      name: '数学・統計',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'law_econ',
      majorKey: 'academic',
      name: '法律・経済・経営',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'humanities',
      majorKey: 'academic',
      name: '人文系',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'sciences',
      majorKey: 'academic',
      name: '自然科学系',
      recommendedRate: 1000,
    ),

    // 読書・インプット
    CategoryMasterMinor(
      key: 'business_book',
      majorKey: 'reading',
      name: 'ビジネス書・自己啓発書',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'tech_book',
      majorKey: 'reading',
      name: '技術書・専門書',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'general_book',
      majorKey: 'reading',
      name: '教養書・新書',
      recommendedRate: 800,
    ),

    // 仕事・本業
    CategoryMasterMinor(
      key: 'work_skill',
      majorKey: 'work',
      name: '業務スキル研鑽',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'presentation',
      majorKey: 'work',
      name: '資料作成・プレゼン準備',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'research',
      majorKey: 'work',
      name: '業界・市場リサーチ',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'career',
      majorKey: 'work',
      name: 'キャリア設計',
      recommendedRate: 1000,
    ),

    // 副業・フリーランス
    CategoryMasterMinor(
      key: 'writing',
      majorKey: 'sidejob',
      name: 'Webライティング',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'design',
      majorKey: 'sidejob',
      name: 'デザイン・動画制作',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'indiedev',
      majorKey: 'sidejob',
      name: '個人開発・プロダクト制作',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'sales',
      majorKey: 'sidejob',
      name: '営業・案件獲得',
      recommendedRate: 1200,
    ),

    // 資産形成・投資
    CategoryMasterMinor(
      key: 'invest_study',
      majorKey: 'investment',
      name: '投資の勉強',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'realestate_crypto',
      majorKey: 'investment',
      name: '不動産・仮想通貨',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'finance',
      majorKey: 'investment',
      name: '家計・節約・税金',
      recommendedRate: 1000,
    ),

    // クリエイティブ制作
    CategoryMasterMinor(
      key: 'illustration',
      majorKey: 'creative',
      name: 'イラスト・絵画',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'music_creation',
      majorKey: 'creative',
      name: '音楽制作・作曲',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'photo_video',
      majorKey: 'creative',
      name: '写真・動画作品制作',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'writing_novel',
      majorKey: 'creative',
      name: '執筆（小説・エッセイ）',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'modeling_3d',
      majorKey: 'creative',
      name: '3DCG・モデリング',
      recommendedRate: 1500,
    ),

    // 運動・トレーニング
    CategoryMasterMinor(
      key: 'strength',
      majorKey: 'exercise',
      name: '筋トレ',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'running',
      majorKey: 'exercise',
      name: 'ランニング',
      recommendedRate: 900,
    ),
    CategoryMasterMinor(
      key: 'walking',
      majorKey: 'exercise',
      name: 'ウォーキング',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'jumprope',
      majorKey: 'exercise',
      name: 'なわとび',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'yoga',
      majorKey: 'exercise',
      name: 'ヨガ・ストレッチ',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'radio_taiso',
      majorKey: 'exercise',
      name: 'ラジオ体操',
      recommendedRate: 700,
    ),
    CategoryMasterMinor(
      key: 'sports',
      majorKey: 'exercise',
      name: 'スポーツ・武道',
      recommendedRate: 1100,
    ),

    // 健康管理
    CategoryMasterMinor(
      key: 'cooking_health',
      majorKey: 'health',
      name: '食事・自炊',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'sleep',
      majorKey: 'health',
      name: '睡眠・休養',
      recommendedRate: 700,
    ),
    CategoryMasterMinor(
      key: 'meditation',
      majorKey: 'health',
      name: '瞑想・マインドフルネス',
      recommendedRate: 800,
    ),

    // 自己啓発・マインド
    CategoryMasterMinor(
      key: 'journaling',
      majorKey: 'self_dev',
      name: 'ジャーナリング・日記',
      recommendedRate: 900,
    ),
    CategoryMasterMinor(
      key: 'habit',
      majorKey: 'self_dev',
      name: '目標設定・習慣化',
      recommendedRate: 1000,
    ),
    CategoryMasterMinor(
      key: 'coaching',
      majorKey: 'self_dev',
      name: 'コーチング・メンタルケア',
      recommendedRate: 1200,
    ),

    // コミュニケーション
    CategoryMasterMinor(
      key: 'speech',
      majorKey: 'communication',
      name: 'プレゼン・スピーチ練習',
      recommendedRate: 1200,
    ),
    CategoryMasterMinor(
      key: 'interview',
      majorKey: 'communication',
      name: '面接・転職準備',
      recommendedRate: 1500,
    ),
    CategoryMasterMinor(
      key: 'negotiation',
      majorKey: 'communication',
      name: '交渉術・対人スキル',
      recommendedRate: 1200,
    ),

    // 家事・生活（issue #169 新設）
    CategoryMasterMinor(
      key: 'cooking_home',
      majorKey: 'home_life',
      name: '料理',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'cleaning',
      majorKey: 'home_life',
      name: '掃除',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'housekeeping',
      majorKey: 'home_life',
      name: '家計簿・家計管理',
      recommendedRate: 900,
    ),
    CategoryMasterMinor(
      key: 'parenting',
      majorKey: 'home_life',
      name: '育児・子育て',
      recommendedRate: 900,
    ),

    // 趣味
    CategoryMasterMinor(
      key: 'instrument',
      majorKey: 'hobby',
      name: '楽器演奏',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'camera',
      majorKey: 'hobby',
      name: '写真・カメラ',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'craft',
      majorKey: 'hobby',
      name: '手芸・DIY・園芸',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'blog_writing',
      majorKey: 'hobby',
      name: 'ブログ・日記執筆',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'game',
      majorKey: 'hobby',
      name: 'eスポーツ・ゲーム上達',
      recommendedRate: 800,
    ),
    CategoryMasterMinor(
      key: 'boardgame',
      majorKey: 'hobby',
      name: '将棋・囲碁・ボードゲーム',
      recommendedRate: 700,
    ),
    CategoryMasterMinor(
      key: 'other_hobby',
      majorKey: 'hobby',
      name: 'その他の趣味',
      recommendedRate: 800,
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

  /// 指定 major の小カテゴリを **CSV 登場順** のまま返す。
  /// issue #169 で五十音ソートを廃止（CSV の手書き順を信頼する方針）。
  static List<CategoryMasterMinor> minorsFor(String majorKey) {
    return minors.where((m) => m.majorKey == majorKey).toList(growable: false);
  }
}
