/// 法務系の静的テキスト（プライバシーポリシー / 利用規約）。
///
/// アプリ内表示用。外部 URL ホスティングは無し（本アプリは外部送信を
/// 一切行わないので、文面もアプリにバンドルしてしまえば運用が楽）。
/// 改訂時はバージョンアップでアプリを更新する。
library;

class LegalTexts {
  const LegalTexts._();

  /// プライバシーポリシー最終更新日（ストア掲載・規約改定通知の参照に使う）。
  static const String privacyPolicyUpdatedAt = '2026年5月26日';

  /// 利用規約最終更新日。
  static const String termsUpdatedAt = '2026年5月26日';

  /// プライバシーポリシー本文。Markdown ではなく Dart のセクション配列で
  /// 持ち、表示側で `Text` ウィジェットの並びにレンダリングする。
  static const List<LegalSection> privacyPolicy = [
    LegalSection.paragraph(
      'mirai_bank（以下「本アプリ」）は、ユーザーのプライバシーを尊重し、'
      '個人情報の保護に努めます。本ポリシーでは、本アプリがどのような情報を'
      '取り扱うかを説明します。',
    ),
    LegalSection.heading('1. 取得する情報'),
    LegalSection.paragraph(
      '本アプリは、以下のデータをユーザーの端末内にローカル保存します。',
    ),
    LegalSection.bullets([
      'ユーザーが入力したカテゴリ名 / 時給 / 学習時間 / メモ',
      '設定した目標と達成状況',
      'リマインダー通知の設定（曜日 / 時刻 / 有効・無効）',
      'アプリの利用設定（テーマ、表示設定など）',
    ]),
    LegalSection.paragraph(
      'これらは端末内にのみ保存され、本アプリの開発者を含む第三者には'
      '一切送信されません。',
    ),
    LegalSection.heading('2. 個人情報の取得'),
    LegalSection.paragraph(
      '本アプリは、氏名、メールアドレス、電話番号、住所、生年月日、'
      'その他お客様を個人として特定できる情報を一切取得しません。',
    ),
    LegalSection.heading('3. パーミッション（権限）の使用'),
    LegalSection.paragraph(
      '本アプリは以下のパーミッションを利用します。',
    ),
    LegalSection.bullets([
      '通知（ローカル通知）: 学習リマインダーや目標達成のお知らせを'
          '端末内で表示するために使用します。OS の通知許可ダイアログで'
          '拒否することができます。',
    ]),
    LegalSection.heading('4. 第三者サービス'),
    LegalSection.paragraph(
      '本アプリは、現時点でアナリティクスサービス、広告ネットワーク、'
      'クラッシュレポート等の第三者サービスを利用していません。'
      '将来的にこれらを導入する場合は、本ポリシーを更新してお知らせします。',
    ),
    LegalSection.heading('5. 子どもの利用について'),
    LegalSection.paragraph(
      '本アプリは全年齢を対象としています。13 歳未満のお子様が利用される'
      '場合は、保護者の方の同意のもとでご利用ください。',
    ),
    LegalSection.heading('6. データの保存と削除'),
    LegalSection.paragraph(
      '本アプリの全データは、端末内のローカルストレージ（SQLite データベース）'
      'に保存されます。アプリをアンインストールすると、これらのデータも'
      'すべて削除されます。',
    ),
    LegalSection.heading('7. データの第三者提供'),
    LegalSection.paragraph(
      '本アプリは、ユーザーのデータを第三者に提供しません。',
    ),
    LegalSection.heading('8. プライバシーポリシーの変更'),
    LegalSection.paragraph(
      '本ポリシーは、必要に応じて改訂することがあります。重要な変更がある'
      '場合は、アプリ内またはストアのリリースノートで通知します。',
    ),
    LegalSection.heading('9. お問い合わせ'),
    LegalSection.paragraph(
      '本ポリシーに関するご質問やご意見は、設定 → お問い合わせより'
      'ご連絡ください。',
    ),
    LegalSection.heading('10. 準拠法'),
    LegalSection.paragraph(
      '本ポリシーは日本国の法律に準拠します。',
    ),
  ];

  /// 利用規約本文（同じ表示構造）。
  static const List<LegalSection> terms = [
    LegalSection.paragraph(
      '本利用規約（以下「本規約」）は、mirai_bank（以下「本アプリ」）の'
      '利用条件を定めるものです。本アプリをご利用いただく場合、'
      '本規約に同意したものとみなします。',
    ),
    LegalSection.heading('第 1 条（適用）'),
    LegalSection.paragraph(
      '本規約は、ユーザーと本アプリの開発者との間の本アプリ利用に関する'
      '一切の関係に適用されます。',
    ),
    LegalSection.heading('第 2 条（金額表示について）'),
    LegalSection.paragraph(
      '本アプリは、ユーザーが設定した時給と学習時間をもとに、'
      '学習を金額として可視化する機能を提供します。',
    ),
    LegalSection.paragraph(
      '表示される金額は、学習継続のモチベーション維持を目的とした'
      '参考値であり、実際の収入・報酬・金銭的利益を保証するものでは'
      'ありません。',
    ),
    LegalSection.paragraph(
      '本アプリは金融商品、投資助言サービス、金銭授受サービスでは'
      'ありません。',
    ),
    LegalSection.heading('第 3 条（自己責任）'),
    LegalSection.paragraph(
      'ユーザーは、本アプリを自己の責任において利用するものとします。'
      '本アプリの利用により発生したいかなる損害についても、開発者は'
      '一切の責任を負いません。',
    ),
    LegalSection.heading('第 4 条（禁止事項）'),
    LegalSection.paragraph(
      'ユーザーは、本アプリの利用にあたり、以下の行為をしてはなりません。',
    ),
    LegalSection.bullets([
      '法令または公序良俗に違反する行為',
      '本アプリのリバースエンジニアリング、改変、不正利用',
      '本アプリの運営を妨害する行為',
      'その他、開発者が不適切と判断する行為',
    ]),
    LegalSection.heading('第 5 条（知的財産権）'),
    LegalSection.paragraph(
      '本アプリに関する著作権、商標権その他の知的財産権は、'
      '開発者または正当な権利者に帰属します。',
    ),
    LegalSection.heading('第 6 条（サービスの提供の停止等）'),
    LegalSection.paragraph(
      '開発者は、メンテナンス、不具合修正、アップデート等の理由により、'
      'ユーザーへの事前通知なく本アプリの全部または一部の提供を停止または'
      '中断することができるものとします。',
    ),
    LegalSection.heading('第 7 条（免責事項）'),
    LegalSection.paragraph(
      '開発者は、本アプリに関して、その正確性、有用性、特定目的への'
      '適合性等について、いかなる保証も行いません。',
    ),
    LegalSection.paragraph(
      'バグ、データの消失、端末の不具合、通知の不達等、本アプリの利用に'
      '関して発生したいかなる損害についても、開発者は責任を負いません。',
    ),
    LegalSection.heading('第 8 条（利用規約の変更）'),
    LegalSection.paragraph(
      '開発者は、必要と判断した場合には、ユーザーに通知することなく'
      '本規約を変更することができるものとします。変更後の本規約は、'
      'アプリ内に表示した時点から効力を生じるものとします。',
    ),
    LegalSection.heading('第 9 条（準拠法・裁判管轄）'),
    LegalSection.paragraph(
      '本規約の解釈にあたっては、日本国の法律を準拠法とします。'
      '本アプリに関して紛争が生じた場合には、開発者の所在地を管轄する'
      '裁判所を専属的合意管轄とします。',
    ),
  ];
}

/// 法務系テキストの 1 ブロック（見出し / 段落 / 箇条書きのいずれか）。
sealed class LegalSection {
  const LegalSection();

  const factory LegalSection.heading(String text) = LegalHeading;
  const factory LegalSection.paragraph(String text) = LegalParagraph;
  const factory LegalSection.bullets(List<String> items) = LegalBullets;
}

class LegalHeading extends LegalSection {
  const LegalHeading(this.text);
  final String text;
}

class LegalParagraph extends LegalSection {
  const LegalParagraph(this.text);
  final String text;
}

class LegalBullets extends LegalSection {
  const LegalBullets(this.items);
  final List<String> items;
}
