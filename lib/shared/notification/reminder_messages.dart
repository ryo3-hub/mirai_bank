import 'dart:math';

/// 日次リマインダー通知の文言タグ（issue #174）。
///
/// `weekday` は月〜金、`weekend` は土・日のみ出すメッセージ。`any` は曜日を
/// 問わず常に候補入りする。`scheduleDailyReminder` が曜日ごとにメッセージを
/// 1 つ選ぶ際、その曜日が weekday/weekend のどちらかでマッチするプールから
/// 乱択する。
enum ReminderTag { any, weekday, weekend }

class ReminderMessage {
  const ReminderMessage(this.title, this.body, {this.tag = ReminderTag.any});

  /// 通知タイトル。短く、注意を引く一言。
  final String title;

  /// 通知本文。行動への一押し。
  final String body;

  /// 曜日タグ。
  final ReminderTag tag;
}

/// リマインダー文言プール。`scheduleDailyReminder` から `randomFor` 経由で
/// 参照する。アプリ起動時に毎回スケジュールし直すので、起動するたびに
/// 次の 1 週間分の文言が再シャッフルされる動きになる（issue #174）。
class ReminderMessages {
  const ReminderMessages._();

  /// 平日 (DateTime.weekday: 1=月 .. 5=金) で発火しうる weekday の曜日番号。
  static const Set<int> _weekdayWeekdays = {1, 2, 3, 4, 5};

  /// メッセージプール本体。
  static const List<ReminderMessage> all = [
    // --- any: 曜日を問わない汎用メッセージ ---
    ReminderMessage('今日の積み上げ、忘れてない？', '5 分でも、未来の自分への投資になります'),
    ReminderMessage('一歩進めましょう', '続けることが、いちばんの武器です'),
    ReminderMessage('そろそろ取り組む時間？', '短い時間でもタイマーを回してみよう'),
    ReminderMessage('今日の自分に投資しよう', '明日の自分が、きっとよろこびます'),
    ReminderMessage('お疲れさまです', 'ひと呼吸ついたら、1 タップで始めましょう'),
    ReminderMessage('ふと、思い出してください', '昨日の自分との小さな約束'),
    ReminderMessage('集中タイムにしませんか', '5 分だけでもいい、まずはタイマーを ON'),
    ReminderMessage('1 ページでも、1 行でも', '前進した分だけ、未来の選択肢が増えます'),
    ReminderMessage('学習スイッチを入れよう', '切り替えのきっかけは、いつだって小さな一歩から'),
    ReminderMessage('今日はまだ手をつけてない？', 'たった 5 分でも、ゼロより遙かに価値があります'),
    ReminderMessage('1 日 30 分が、半年で 90 時間', '今からでもまったく遅くないですよ'),
    ReminderMessage('余白の時間に', 'ちょっとだけ、自分の未来に時間を使おう'),
    ReminderMessage('続けてる人だけが見える景色', '今日も、その景色に一歩近づけます'),
    ReminderMessage('小さな積み上げが、大きな変化に', 'まずはタイマーを回すところから'),
    ReminderMessage('自分との約束、覚えてる？', '少しでもいい、今日のぶんを始めましょう'),
    ReminderMessage('学びの時間です', '今日のあなたの 5 分は、未来のあなたの何時間分'),
    ReminderMessage('一服したら、再開しよう', '小さく区切れば、続けやすい'),
    ReminderMessage('やる気が出ない日でも', 'まずはタイマーを 5 分セット。それで十分'),

    // --- weekday: 平日（月〜金）の文脈を反映 ---
    ReminderMessage(
      '仕事終わりの一息に',
      '今日の積み上げ時間です。短くて OK',
      tag: ReminderTag.weekday,
    ),
    ReminderMessage(
      '平日こそ、習慣を作る日',
      '短くてもタイマーを回す、それだけで前進',
      tag: ReminderTag.weekday,
    ),
    ReminderMessage(
      '1 日の終わりに',
      '5 分だけ、自分の時間を持ちましょう',
      tag: ReminderTag.weekday,
    ),
    ReminderMessage(
      'スキマ時間を味方に',
      '通勤や休憩の合間でも、少しずつ前へ',
      tag: ReminderTag.weekday,
    ),
    ReminderMessage(
      '今日の自分、お疲れさま',
      '寝る前のひと押しが、明日の余裕につながります',
      tag: ReminderTag.weekday,
    ),
    ReminderMessage(
      '1 タスクだけでも',
      '今日のリズムを崩さないことが大事',
      tag: ReminderTag.weekday,
    ),

    // --- weekend: 休日（土・日）の文脈を反映 ---
    ReminderMessage(
      '週末はゆっくり、でも忘れずに',
      '自分の時間を、ちょっとだけ取りませんか',
      tag: ReminderTag.weekend,
    ),
    ReminderMessage(
      '休日こそ、じっくり集中',
      'まとまった時間が取れる、絶好のチャンス',
      tag: ReminderTag.weekend,
    ),
    ReminderMessage(
      '週末の朝、コーヒー片手に',
      '気軽な気持ちで、学びを楽しもう',
      tag: ReminderTag.weekend,
    ),
    ReminderMessage(
      'リフレッシュも兼ねて',
      '軽く 15 分、タイマーを回してみよう',
      tag: ReminderTag.weekend,
    ),
    ReminderMessage(
      '休日は、自由なペースで',
      '続けることに意味がある。短くても大丈夫',
      tag: ReminderTag.weekend,
    ),
  ];

  /// 指定 `weekday` (DateTime.weekday: 1=月..7=日) で発火するリマインダー用に、
  /// 該当するタグのプールからメッセージを 1 つ乱択する。
  ///
  /// - 月〜金: tag が `any` または `weekday`
  /// - 土・日: tag が `any` または `weekend`
  ///
  /// テストから決定論を確保したい場合は `random` を渡す（省略時は `Random()`）。
  static ReminderMessage randomFor(int weekday, {Random? random}) {
    final pool = _poolFor(weekday);
    // プールが空になる設計ではないが、念のため最後の砦として any 全件にフォールバック
    final candidates =
        pool.isNotEmpty ? pool : all.where((m) => m.tag == ReminderTag.any).toList();
    final rnd = random ?? Random();
    return candidates[rnd.nextInt(candidates.length)];
  }

  static List<ReminderMessage> _poolFor(int weekday) {
    final allowed = _weekdayWeekdays.contains(weekday)
        ? const {ReminderTag.any, ReminderTag.weekday}
        : const {ReminderTag.any, ReminderTag.weekend};
    return all.where((m) => allowed.contains(m.tag)).toList(growable: false);
  }
}
