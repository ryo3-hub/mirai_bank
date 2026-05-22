# ホーム画面

## 概要
今日の積み上げ金額・タイマー・目標進捗を一画面に集約したダッシュボード。アプリの起動時にデフォルトで表示される。

## UI 構成
上から下へ：

```
[SafeArea]  ← AppBar は削除済み (issue #56)
[SingleChildScrollView]
  0. StreakBadge — 連続学習日数（任意表示）
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

### 3. Timer card（カウントダウン式、issue #95）
状態により 3 つに分岐：

#### idle (タイマー停止中、かつカテゴリあり)
- 「タイマーで学習を始める」見出し
- カテゴリ選択カード（タップで `CategoryPickerSheet`）
- FilledButton「プリセットを選んで開始」→ `TimerPresetPickerSheet` を開く
- プリセット選択でカウントダウンタイマーが起動

#### running (タイマー稼働中 / 一時停止中)
- カテゴリヘッダー（アイコン + 名前 + 「集中中」or「一時停止中」バッジ）
- **残り時間** (`mm:ss`、56px、tabular figures。一時停止中はグレー)
- 進捗バー（経過 / 目標、一時停止中はグレー）
- 確定金額（**15 分単位の切り下げ** で 15 分の節目ごとに増える、primary 色）
- メモ TextField（任意、スキルアップ内容など）
- ボタン行 `[一時停止 / 再開]` `[停止]`
- 目標時間に到達したら自動停止 → セッション保存 + プッシュ通知

#### no category (カテゴリ 0 件)
- アイコン + 「カテゴリがありません」
- FilledButton.icon「カテゴリを追加」（タップで `CategoryEditSheet.show()`）

### 5. DashboardGoalsSection
- 目標が 0 件のときは表示なし（`SizedBox.shrink`）
- **最大表示件数: 5 件** (`_maxDisplay = 5`)
- 上回る分は「他 N 件」リンクで `/settings/goals` へ
- 各目標：ラベル / 達成率 % / 進捗バー / 現在金額 / 目標金額

## 業務ルール（タイマー）

### 課金計算（日本のアルバイト式 = 15 分単位）
- 経過秒数を 15 分単位で切り下げ：`paidDurationSec = (workedSec ÷ 900) × 900`
- 金額: `(paidDurationSec / 3600) × hourlyRate`
- 15 分未満で停止 → **記録しない**（WorkSession を作らずタイマーだけクリア）
- 例（時給 2000 円）: 14:59 = 0 円 / 15:00 = 500 円 / 23:00 = 500 円 / 30:00 = 1000 円

### 一時停止 / 再開
- ActiveTimer に `accumulatedSec`（停止までの累積）+ `resumedAt`（直近で再開した時刻、null = 一時停止中）を保持
- 経過秒数 = `accumulatedSec + (resumedAt != null ? (now - resumedAt).inSeconds : 0)`
- 一時停止中は完了通知をキャンセル。再開時に残り時間で再スケジュール

### 自動完了
- `elapsedSec >= targetDurationSec` で自動 `_stop()` を 1 度だけトリガー
- セッション保存 + `AmountFlash` + 完了プッシュ通知（事前に `scheduleTimerCompletion` 済み）

## 入力フィールド
- **タイマー稼働中のメモ**: 任意、複数行（maxLines: 2）、`fillColor: colorScheme.surface`

## リスト表示の上限
- 目標進捗: **5 件**
- それ以上は `/settings/goals` で全件閲覧

## 遷移
- 「カテゴリを追加」→ `CategoryEditSheet` （ボトムシート）
- カテゴリ選択 → `CategoryPickerSheet`（ボトムシート）
- 「プリセットを選んで開始」→ `TimerPresetPickerSheet`（ボトムシート、編集アイコンから `/settings/timer-presets`）
- 目標「他 N 件」/ 「すべて見る」→ `/settings/goals`

## 状態
- **Loading**:
  - タイマー読み込み中: `CircularProgressIndicator` を中央に
  - カテゴリ読み込み中: `CircularProgressIndicator` を中央に
- **Error**: タイマーカードに「タイマーの読み込みに失敗しました: $e」を表示

## 通知（トースト + プッシュ）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| プリセットを選んで開始 | なし | 「開始に失敗しました: $e」 |
| 一時停止 / 再開 | なし | 「操作に失敗しました: $e」 |
| 停止（15 分以上） | ⚡ `AmountFlash`（課金額アニメ） | 「停止に失敗しました: $e」 |
| 停止（15 分未満） | トースト「15 分未満だったので記録しませんでした」 | 〃 |
| 目標時間到達（自動完了） | ⚡ `AmountFlash` + 📲 プッシュ通知 | 〃 |

## 関連ファイル
- `lib/features/timer/presentation/home_page.dart`
- `lib/features/timer/presentation/timer_preset_picker_sheet.dart`
- `lib/features/timer/presentation/timer_preset_list_page.dart`
- `lib/features/timer/presentation/timer_preset_edit_sheet.dart`
- `lib/features/timer/presentation/widgets/today_amount_card.dart`
- `lib/features/timer/presentation/widgets/dashboard_goals_section.dart`
- `lib/features/timer/application/timer_providers.dart`
- `lib/features/timer/application/timer_preset_providers.dart`
- `lib/features/timer/domain/active_timer.dart`
- `lib/features/timer/domain/amount_calculator.dart`
- `lib/features/timer/domain/timer_preset.dart`
- `lib/features/history/application/summary_providers.dart`（今日の金額）
- `lib/shared/notification/notification_service.dart`（完了通知）
