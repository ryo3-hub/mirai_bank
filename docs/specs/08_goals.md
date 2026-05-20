# 目標追加・編集シート

## 概要
累計目標または期間目標を作成・編集するボトムシート。設定 > 目標設定から開かれる。

## UI 構成
```
[BottomSheet]（showDragHandle: true, isDismissible: true）
  - "新規目標" or "目標を編集"（titleLarge）
  - SegmentedButton（累計 / 期間）
  - 目標金額 TextFormField
  - 対象カテゴリ選択（タップで CategoryOptionSheet）
  - 期間ピッカー（期間目標時のみ表示）
    - 開始日 / 終了日（タップで MiraiDatePickerSheet）
  - ボタン行：
    - 新規: 保存ボタン横幅一杯
    - 編集: 削除ボタン + 保存ボタン（均等幅）
```

専用「キャンセル」ボタンなし。シート外タップ / 下スワイプで閉じる。

## 入力フィールド

### 目標種別（GoalType）
| 値 | ラベル | 内容 |
|---|---|---|
| `cumulative` | 累計 | 全期間の積み上げが目標金額に到達したら達成 |
| `period` | 期間 | 指定期間内の積み上げが目標金額に到達したら達成 |

- デフォルト（新規）: `cumulative`
- 切替時に期間フィールドの表示/非表示が連動

### 目標金額
- 初期値（新規）: `30000`
- 初期値（編集）: 既存の `targetAmount`
- キーボード: number、数字のみ
- 範囲: **1 〜 100,000,000 円** (`Goal.targetAmountMin/Max`)
- バリデーション:
  - 必須 → 「目標金額を入力してください」
  - 数値以外 → 「数値を入力してください」
  - < 1 → 「1円以上を入力してください」
  - > 100000000 → 「上限を超えています」
- suffix: 「円」

### 対象カテゴリ
- 任意（null の場合は「全カテゴリ」が対象）
- タップでカテゴリ選択シート（_CategoryOptionSheet）
  - 「全カテゴリ」 ＋ アクティブな各カテゴリのリスト

### 開始日 / 終了日（期間目標のみ）
- 初期値（新規）: 開始=今日、終了=今日+30日
- 初期値（編集）: 既存の `periodStart` / `periodEnd`
- タップで `MiraiDatePickerSheet`（カレンダータブと同じ意匠の独自ピッカー）
- 範囲: `2020-01-01` 〜 `2100-12-31`
- バリデーション（保存時）:
  - 期間目標で開始 / 終了どちらかが null → 「期間を選択してください」
  - 開始 > 終了（同日 OK）→ 「開始日は終了日以前にしてください」

## アクション

### 保存
- 新規: `GoalController.create()`
- 編集: `GoalController.updateGoal(initial.copyWith(...))`
- 保存後、`GoalAchievementChecker.checkAndMark()` で達成判定 → `achievedAt` を更新

### 削除（編集モードのみ）
1. `showDeleteConfirmDialog` で確認（赤フィルドの削除ボタン）
2. `GoalController.delete()` で削除
3. トースト「目標を削除しました」
4. シートを閉じる

## 達成判定（GoalAggregator）
- `cumulative`: 全期間の `WorkSession.amount` 合計（対象カテゴリがあればフィルタ）
- `period`: `periodStart` ～ `periodEnd` の `WorkSession.endTime` がその範囲内のもの合計
- `currentAmount >= targetAmount` で達成扱い

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| 追加 | 「目標を追加しました」 | 「保存に失敗しました: $e」 |
| 編集 | 「目標を更新しました」 | 「保存に失敗しました: $e」 |
| 削除 | 「目標を削除しました」 | 「削除に失敗しました: $e」 |

達成時は `GoalAchievementDialog` で別途お祝い演出。

## 関連ファイル
- `lib/features/goals/presentation/goal_edit_sheet.dart`
- `lib/features/goals/presentation/goal_list_page.dart`
- `lib/features/goals/presentation/widgets/goal_card.dart`
- `lib/features/goals/application/goal_providers.dart`
- `lib/features/goals/application/goal_achievement_checker.dart`
- `lib/features/goals/domain/goal.dart`
- `lib/features/goals/domain/goal_progress.dart`
- `lib/shared/widgets/mirai_date_picker_sheet.dart`
- `lib/shared/widgets/confirm_dialog.dart`
- `lib/shared/achievement/widgets/goal_achievement_dialog.dart`
