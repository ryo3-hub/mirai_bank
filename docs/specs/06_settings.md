# 設定画面

## 概要
カテゴリ管理・目標設定・通知設定にアクセスするための画面。設定項目はすべて
子ページに分離してあり、本ページ自体は遷移メニュー（ListTile 集）のみ。

## UI 構成
```
[AppBar] "設定"
[ListView]
  - SectionHeader「管理」
  - ListTile「カテゴリ管理」 → /settings/categories
  - ListTile「目標設定」 → /settings/goals
  - ListTile「履歴」 → /settings/history       ← #54
  - ListTile「タイマープリセット」 → /settings/timer-presets  ← #95
  - Divider
  - SectionHeader「通知」
  - ListTile「通知設定」 → /settings/notifications
```

本ページに直接の入力フィールドはなく、各 ListTile タップで子ページに遷移する。
履歴はボトムナビからは外れており、本ページ経由でのみアクセスする（issue #54）。

## 子画面

### カテゴリ管理（/settings/categories）
- `CategoryListPage`
- 一覧 + FAB「カテゴリを追加」（円形、GitHub Green、CategoryEditSheet を開く）
- 各カテゴリカード: アイコン / 名前 / 時給 / 削除 IconButton（テーマ色）
- 削除前に `showDeleteConfirmDialog` で確認

### 目標設定（/settings/goals）
- `GoalListPage`
- アクティブな目標一覧 + 達成済み（折りたたみセクション）
- FAB「目標を追加」（円形、GitHub Green、GoalEditSheet を開く）
- 各目標カード（GoalCard）: 種別 / カテゴリ / 進捗バー / % / 金額

### 履歴（/settings/history）
- `HistoryPage`（詳細は [05_history.md](05_history.md)）
- ボトムナビからは外れており、設定 → 履歴 経由でアクセスする

### 通知設定（/settings/notifications）
- `NotificationSettingsPage`
- 構成：
  - SwitchListTile「学習リマインダー」（指定時刻に通知）
  - ListTile「リマインダー時刻」（リマインダー有効時のみタップ可能、`MiraiTimePickerSheet` / ドラムロール）
  - 通知する曜日（独自 `_WeekdayCell` を `Row` + `Expanded` で 1 行に。日始まり。0 件選択時は赤の警告文）
  - SwitchListTile「達成通知」（目標達成・連続学習の節目で通知）

#### 学習リマインダー
- スイッチ ON: `NotificationService.scheduleDailyReminder(time, weekdays)` で通知をスケジュール
- スイッチ OFF: 通知キャンセル

#### リマインダー時刻
- 現在の時刻を表示（例: 9:00 PM）
- タップで `MiraiTimePickerSheet`（ドラムロール、24h、1 分刻み、issue #73）を開いて変更
- リマインダー OFF のときはグレーアウト

#### 通知する曜日
- **日〜土** の 7 セルを `Row` + `Expanded` で均等割りで 1 行に並べる
  （日曜始まり、issue #88）
- 各セルは独自 `_WeekdayCell`（角丸 12px、高さ 44px、白背景 + 枠線スタイル）
- 選択時の枠線・テキスト色は曜日色に連動：日曜=赤、土曜=青、平日=primary（水色）
- 値は `DateTime.weekday` 形式（1=月..7=日）で保存、表示順だけ日始まりに
- 複数選択可、リマインダー OFF のときは操作不可
- 1 つも選んでいないと「曜日を 1 つ以上選んでください」エラー文を表示

#### 達成通知
- スイッチ ON: 目標達成時に通知 + アニメ
- スイッチ OFF: 静かに記録のみ

## リスト表示の上限
- カテゴリ管理 / 目標設定どちらも **全件表示**（ScrollList ベース）

## 状態
- **Loading**: 通知設定ページで `appSettingProvider` 読み込み中は `CircularProgressIndicator`
- **Error**: 「設定の読み込みに失敗: $e」

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| リマインダー ON/OFF 切替 | なし | エラートースト |
| リマインダー時刻変更 | なし | なし（即時 DB 保存） |
| 曜日切替 | なし | なし |
| 達成通知 ON/OFF | なし | なし |

カテゴリ削除 / 目標削除のトーストは各シート側参照（[07_categories.md](07_categories.md) / [08_goals.md](08_goals.md)）。

## 関連ファイル
- `lib/features/settings/presentation/settings_page.dart`
- `lib/features/settings/presentation/notification_settings_page.dart`
- `lib/features/settings/application/setting_providers.dart`
- `lib/features/settings/domain/app_setting.dart`
- `lib/features/category/presentation/category_list_page.dart`
- `lib/features/goals/presentation/goal_list_page.dart`
- `lib/shared/notification/notification_service.dart`
- `lib/app/router.dart`
