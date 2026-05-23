# 目標追加シート

## 概要
短期 / 中期 / 長期のプリセットから目標を選択するボトムシート。設定 > 目標設定の FAB から開かれる。

issue #100 で「自由入力（種別 / 金額 / 期間）方式」から本プリセット選択方式に変更。
編集機能は廃止し、削除は目標カード右上の削除アイコンから行う。

## UI 構成
```
[BottomSheet]（showDragHandle: true, isDismissible: true）
  - 対象カテゴリ選択（タップで CategoryOptionSheet）
  - "目標を選ぶ"（titleSmall）
  - プリセット 3 ボタン（縦並びの選択カード）
    - 短期目標 (7日間) / 中期目標 (30日間) / 長期目標 (90日間)
    - 各カードに「達成予定: YYYY/M/d」と目標金額（円）を表示
    - 選択中はラジオアイコン + アクセント色枠
  - 保存ボタン（プリセット未選択時は無効・横幅一杯）
```

シート上部のタイトル表記（「新規目標」）は issue #103 で削除。
ドラッグハンドル + 内容で文脈が伝わるため。

専用「キャンセル」ボタンなし。シート外タップ / 下スワイプで閉じる。

## プリセット定義

| プリセット | 期間 | 金額（カテゴリ指定時） | 金額（全カテゴリ） |
|---|---|---|---|
| 短期目標 | 1 週間後（7 日） | 時給 × 7 | 10,000 円 |
| 中期目標 | 1 ヶ月後（30 日） | 時給 × 30 | 50,000 円 |
| 長期目標 | 3 ヶ月後（90 日） | 時給 × 90 | 150,000 円 |

- 達成予定日 = 当日（0:00）+ プリセット日数
- カテゴリを切り替えると、各カードの金額は自動的に再計算される
- 対象カテゴリは任意（null の場合は「全カテゴリ」固定金額）

## アクション

### 保存
- DB 格納形式は既存スキーマ互換：`GoalType.period` + `periodStart = 当日 0:00` + `periodEnd = 当日 + プリセット日数`
- `GoalController.create(type: period, ...)`
- 保存後、`GoalAchievementChecker.checkAndMark()` で達成判定 → `achievedAt` を更新

### 削除
編集機能は廃止。一覧画面の各目標カード右上の削除アイコンから削除する：

1. `showDeleteConfirmDialog` で確認（赤フィルドの削除ボタン）
2. `GoalController.delete()` で削除
3. トースト「目標を削除しました」

達成済みセクション（アコーディオン内）の目標カードも同じ削除アイコンで削除可能。

## 目標カード表示

- 左上：プリセットラベル（短期 / 中期 / 長期、または既存目標は累計 / 期間）
- 中央：対象カテゴリ（アイコン + 名前、null なら「全カテゴリ」）
- 右上：達成済みなら「達成 ✓」、削除アイコン
- 達成予定日（`達成予定: YYYY/M/d`）
- 累積金額 / 目標金額、進捗パーセント、プログレスバー

## プリセットの逆引き（既存目標との互換性）

DB は `GoalType.period` で保存するため、`GoalPreset` は `periodEnd - periodStart` の日数から逆引きする：

| 日数 | プリセット |
|---|---|
| 7 | 短期目標 |
| 30 | 中期目標 |
| 90 | 長期目標 |
| その他 / 累計 / null | プリセットなし（issue #100 以前の自由入力目標扱い） |

プリセットに該当しない既存目標も従来通り「累計」「期間」ラベルで表示する（後方互換）。

## 達成判定（GoalAggregator）
- `currentAmount` は `periodStart` 〜 `periodEnd` の `WorkSession.endTime` がその範囲内のもの合計
  （対象カテゴリがあれば categoryId でフィルタ）
- `currentAmount >= targetAmount` で達成扱い
- 累計目標（issue #100 以前の既存データ）は従来通り全期間集計

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| 追加 | 「目標を追加しました」 | 「保存に失敗しました: $e」 |
| 削除 | 「目標を削除しました」 | 「削除に失敗しました: $e」 |

達成時は `GoalAchievementDialog` で別途お祝い演出。

## 関連ファイル
- `lib/features/goals/presentation/goal_edit_sheet.dart`（新規作成シート）
- `lib/features/goals/presentation/goal_list_page.dart`（削除導線）
- `lib/features/goals/presentation/widgets/goal_card.dart`（削除アイコン）
- `lib/features/goals/application/goal_providers.dart`
- `lib/features/goals/application/goal_achievement_checker.dart`
- `lib/features/goals/domain/goal.dart`（`GoalPreset` enum）
- `lib/features/goals/domain/goal_progress.dart`
- `lib/features/timer/presentation/widgets/dashboard_goals_section.dart`
- `lib/shared/widgets/confirm_dialog.dart`
- `lib/shared/achievement/widgets/goal_achievement_dialog.dart`
