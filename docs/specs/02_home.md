# ホーム画面

## 概要
今日の積み上げ金額・タイマー・目標進捗を一画面に集約したダッシュボード。アプリの起動時にデフォルトで表示される。

## UI 構成
上から下へ：

```
[AppBar] "ホーム"
[SingleChildScrollView]
  1. TodayAmountCard — 今日の積み上げ
  2. (空き 12px)
  3. Timer card — タイマー（idle / running / no category）
  4. (空き 12px)
  5. DashboardGoalsSection — 目標進捗（最大 5 件）
```

### 1. TodayAmountCard
- ラベル「今日の積み上げ」
- 大きな金額表示（`AnimatedAmount`、48px、primary 色）
- 今日の作業時間（`DurationFormatter.hourMinute`、tabular figures）

### 3. Timer card
状態により 3 つに分岐：

#### idle (タイマー停止中、かつカテゴリあり)
- 「タイマーで学習を始める」見出し
- カテゴリ選択カード（タップで `CategoryPickerSheet`）
- FilledButton「計測を開始」（カテゴリ選択必須）

#### running (タイマー稼働中)
- カテゴリヘッダー（アイコン + 名前 + 「計測中」バッジ）
- 経過時間（48px、`DurationFormatter.hms`）
- 推定金額（リアルタイム）
- メモ TextField（任意）
- FilledButton「計測を停止」（赤フィルド）

#### no category (カテゴリ 0 件)
- アイコン + 「カテゴリがありません」
- FilledButton.icon「カテゴリを追加」（タップで `CategoryEditSheet.show()`）

### 5. DashboardGoalsSection
- 目標が 0 件のときは表示なし（`SizedBox.shrink`）
- **最大表示件数: 5 件** (`_maxDisplay = 5`)
- 上回る分は「他 N 件」リンクで `/settings/goals` へ
- 各目標：ラベル / 達成率 % / 進捗バー / 現在金額 / 目標金額

## 入力フィールド
- **タイマー停止時のメモ**: 任意、複数行（maxLines: 2）、`fillColor: colorScheme.surface`

## リスト表示の上限
- 目標進捗: **5 件**
- それ以上は `/settings/goals` で全件閲覧

## 遷移
- 「カテゴリを追加」→ `CategoryEditSheet` （ボトムシート）
- カテゴリ選択 → `CategoryPickerSheet`（ボトムシート）
- 目標「他 N 件」/ 「すべて見る」→ `/settings/goals`
- 下部ナビゲーション → 他タブ（カレンダー / 統計 / 履歴 / 設定）

## 状態
- **Loading**:
  - タイマー読み込み中: `CircularProgressIndicator` を中央に
  - カテゴリ読み込み中: `CircularProgressIndicator` を中央に
- **Error**: タイマーカードに「タイマーの読み込みに失敗しました: $e」を表示

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| 計測を開始 | なし | 「開始に失敗しました: $e」 |
| 計測を停止 | ⚡ `AmountFlash`（稼いだ金額アニメ） | 「停止に失敗しました: $e」 |

## 関連ファイル
- `lib/features/timer/presentation/home_page.dart`
- `lib/features/timer/presentation/widgets/today_amount_card.dart`
- `lib/features/timer/presentation/widgets/dashboard_goals_section.dart`
- `lib/features/timer/application/timer_providers.dart`
- `lib/features/history/application/summary_providers.dart`（今日の金額）
