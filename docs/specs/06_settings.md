# 設定画面

## 概要
カテゴリ管理・目標設定・通知設定にアクセスするための画面。

## UI 構成
```
[AppBar] "設定"
[ListView]
  - SectionHeader「管理」
  - ListTile「カテゴリ管理」 → /settings/categories
  - ListTile「目標設定」 → /settings/goals
  - Divider
  - SectionHeader「通知」
  - SwitchListTile「学習リマインダー」
  - ListTile「リマインダー時刻」（リマインダー有効時のみタップ可能）
  - SwitchListTile「達成通知」
```

## 通知セクション

### 学習リマインダー
- スイッチで ON/OFF
- ON: `NotificationService.scheduleDailyReminder(time)` で毎日通知をスケジュール
- OFF: 通知キャンセル

### リマインダー時刻
- 現在の時刻を表示（例: 9:00 PM）
- タップで `showTimePicker` を開いて変更
- リマインダー OFF のときはグレーアウト

### 達成通知
- スイッチで ON/OFF
- ON: 目標達成時に通知 + アニメ
- OFF: 静かに記録のみ

## 入力フィールド
このページ自体には TextField はない。各 SwitchListTile / ListTile への操作のみ。

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

## リスト表示の上限
- カテゴリ管理 / 目標設定どちらも **全件表示**（ScrollList ベース）

## 状態
- **Loading**: `appSettingProvider` 読み込み中は LinearProgressIndicator
- **Error**: 「設定の読み込みに失敗: $e」

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| リマインダー ON/OFF 切替 | なし | エラートースト |
| リマインダー時刻変更 | なし | なし（即時 DB 保存） |
| 達成通知 ON/OFF | なし | なし |

カテゴリ削除 / 目標削除のトーストは各シート側参照（[07_categories.md](07_categories.md) / [08_goals.md](08_goals.md)）。

## 関連ファイル
- `lib/features/settings/presentation/settings_page.dart`
- `lib/features/settings/application/setting_providers.dart`
- `lib/features/settings/domain/app_setting.dart`
- `lib/features/category/presentation/category_list_page.dart`
- `lib/features/goals/presentation/goal_list_page.dart`
- `lib/shared/notification/notification_service.dart`
