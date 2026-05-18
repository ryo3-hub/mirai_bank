# 010 通知・リマインダー機能

## 概要
学習リマインダー・タイマー常駐通知・目標達成通知・連続学習節目通知を実装する。

## 対象フェーズ
Phase 3 — 継続支援機能

## 依存チケット
- 003（タイマー常駐通知）
- 009（目標達成通知）

## タスク

### インフラ層（`flutter_local_notifications` ラッパー）
- [×] `NotificationService` クラスを作成
  - [×] 初期化（iOS パーミッションリクエスト含む）
  - [×] `showOngoingTimerNotification(categoryName, elapsed)` — 常駐通知
  - [×] `cancelTimerNotification()` — 常駐通知をキャンセル
  - [×] `scheduleReminderNotification(timeOfDay)` — 毎日指定時刻に通知
  - [×] `cancelReminderNotification()` — リマインダーキャンセル
  - [×] `showAchievementNotification(goalName)` — 目標達成通知
  - [×] `showStreakNotification(days)` — 連続学習節目通知

### アプリケーション層
- [×] `StreakCalculator` — 連続学習日数を計算するユースケース
- [×] 連続学習節目チェック（3日 / 7日 / 30日）のロジック

### プレゼンテーション層（設定画面）
- [×] リマインダー ON / OFF トグル
- [×] リマインダー時刻選択（`showTimePicker`）
- [×] 目標達成通知 ON / OFF トグル
- [×] 設定値を `Setting` テーブルに保存

### データ層
- [×] `SettingRepository` インターフェース定義
- [×] `SettingRepositoryImpl`（Drift 実装）
  - [×] Setting の取得 / 更新

## 完了条件
- 設定した時刻にリマインダー通知が届く（実機確認）
- タイマー起動中に常駐通知が表示され、停止でクリアされる
- 目標達成時に通知が届く
- `flutter analyze` がエラーなし
