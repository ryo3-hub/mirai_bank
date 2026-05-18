# 003 タイマー方式 作業記録

## 概要
カテゴリを選択してタイマーを開始・停止し、作業セッションを自動保存する機能を実装する。
バックグラウンド・スリープ中も開始時刻差分で計測継続できること。

## 対象フェーズ
Phase 1 — MVP コア

## データモデル（参照）
- `ActiveTimer`（categoryId / startTime / memo）
- `WorkSession`（inputMethod = `timer`）

## タスク

### ドメイン層
- [×] `ActiveTimer` エンティティクラス
- [×] 金額計算ロジック `amount = round((durationSec / 3600) * hourlyRate)`

### インフラ層
- [×] `ActiveTimerRepository` インターフェース定義
- [×] `ActiveTimerRepositoryImpl`（Drift 実装）
  - [×] 現在の ActiveTimer を取得
  - [×] ActiveTimer を保存（タイマー開始）
  - [×] ActiveTimer を削除（タイマー停止）
- [×] `WorkSessionRepository` インターフェース定義
- [×] `WorkSessionRepositoryImpl`
  - [×] セッション保存
  - [×] 全セッション取得
  - [×] 更新・ソフトデリート

### アプリケーション層
- [×] `activeTimerProvider`（現在の ActiveTimer を監視）
- [×] `elapsedSecondsProvider`（1秒ごとに `現在時刻 - startTime` を計算）
- [×] `TimerNotifier`
  - [×] `start(categoryId, memo)` — ActiveTimer を保存
  - [×] `stop()` — WorkSession を作成し ActiveTimer を削除

### プレゼンテーション層（ホーム画面内）
- [×] カテゴリ選択ドロップダウン or ボトムシート
- [×] 開始ボタン
- [×] 計測中 UI
  - [×] 経過時間のカウントアップ表示（HH:MM:SS）
  - [×] リアルタイム金額表示（`経過秒 / 3600 * 時給`）
  - [×] メモ入力フィールド（任意）
  - [×] 停止ボタン
- [×] アプリ復帰時に計測中状態を復元（`ActiveTimer` が存在する場合）

### 通知（常駐）
- [×] タイマー開始時に常駐通知を表示（「計測中: カテゴリ名 / 経過時間」）
- [×] タイマー停止時に通知をクリア

## 完了条件
- タイマー開始 → アプリをバックグラウンド → 復帰後も経過時間が正しく表示される
- 停止後に WorkSession が正しく保存される（金額が正しく計算されている）
- `flutter analyze` がエラーなし
