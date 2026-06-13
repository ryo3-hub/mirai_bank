import 'day_session_group.dart';

/// 履歴一覧で表示するセッションのグループ + 表示上限関連の情報。
///
/// DB には全件保持しているが、UI のスクロール性能と「見るのは直近だけ」
/// という UX 判断から、履歴一覧では直近 [displayLimit] 件に絞って表示する。
/// 統計・カレンダー・累計目標などは別 provider で全件参照しているため、
/// この絞り込みは履歴タブの表示に閉じている。
class LimitedSessionGroups {
  const LimitedSessionGroups({
    required this.groups,
    required this.totalCount,
    required this.displayedCount,
  });

  /// 表示用にグループ化されたセッション（最新日順）。
  final List<DaySessionGroup> groups;

  /// 全期間に存在するアクティブなセッション総数。
  final int totalCount;

  /// 実際に [groups] に含めて表示しているセッション数。
  /// 通常は min(totalCount, displayLimit) だが、境界日の日計を正しく
  /// 保つため境界日のセッションを全部含める分だけ上振れし得る
  /// （issue #202）。
  final int displayedCount;

  /// 全件中、表示しきれていない件数があるか。
  bool get isTruncated => totalCount > displayedCount;

  static const int displayLimit = 100;

  static const LimitedSessionGroups empty = LimitedSessionGroups(
    groups: [],
    totalCount: 0,
    displayedCount: 0,
  );
}
