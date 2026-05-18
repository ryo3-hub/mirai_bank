# 001 プロジェクト基盤構築

## 概要
クリーンアーキテクチャのフォルダ構成・依存関係・ローカルDBのセットアップを行う。
後続の全チケットの土台となる作業。

## 対象フェーズ
Phase 1 — MVP コア

## タスク

### パッケージ追加
- [×] `pubspec.yaml` に依存ライブラリを追加
  - `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`
  - `drift`, `drift_flutter`, `sqlite3_flutter_libs`
  - `go_router`
  - `uuid`
  - `intl`
  - `flutter_local_notifications`
  - `fl_chart`
  - `table_calendar`
  - dev: `build_runner`, `drift_dev`, `riverpod_lint`, `custom_lint`
- [×] `flutter pub get` で依存解決を確認

### フォルダ構成
- [×] `lib/features/category/` を作成（presentation / application / domain / infrastructure）
- [×] `lib/features/timer/` を作成
- [×] `lib/features/history/` を作成
- [×] `lib/features/statistics/` を作成
- [×] `lib/features/settings/` を作成
- [×] `lib/shared/` を作成（theme / widgets / utils）

### ローカル DB（Drift）
- [×] `lib/infrastructure/database/app_database.dart` を作成
- [×] `Category` テーブル定義
- [×] `WorkSession` テーブル定義
- [×] `ActiveTimer` テーブル定義（シングルトン用）
- [×] `Goal` テーブル定義
- [×] `build_runner` でコード生成が通ることを確認（`flutter pub run build_runner build`）

### ルーティング
- [×] `go_router` の初期設定（`AppRouter` クラス作成）
- [×] 5画面分のルート定義（ホーム / カレンダー / 統計 / 履歴 / 設定）

### テーマ
- [×] `AppTheme` クラスを作成（ライト / ダーク）
- [×] `MaterialApp` に適用

### ナビゲーション
- [×] `BottomNavigationBar` の共通 Shell ウィジェット作成

## 完了条件
- `flutter analyze` がエラーなし
- `flutter test` がパス
- アプリが起動しボトムナビゲーションで5画面を切り替えられる（スタブ画面でよい）
