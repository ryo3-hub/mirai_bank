# 仕様書（Specs）

`mirai_bank` の各画面の現状仕様。実装に追従して都度更新する。

開発初期のチケット（`docs/00x_*.md`）は履歴として残しつつ、こちらが**いま動いているアプリ**の正となる仕様。

## 画面一覧

| # | ファイル | 概要 |
|---|---|---|
| 01 | [01_onboarding.md](01_onboarding.md) | 初回起動オンボーディング |
| 02 | [02_home.md](02_home.md) | ホーム（今日の金額 / タイマー / 目標進捗） |
| 03 | [03_calendar.md](03_calendar.md) | カレンダー（月別ヒートマップ + 日別セッション） |
| 04 | [04_statistics.md](04_statistics.md) | 統計（サマリ + 推移グラフ + カテゴリ別） |
| 05 | [05_history.md](05_history.md) | 履歴一覧 + 手動入力シート |
| 06 | [06_settings.md](06_settings.md) | 設定（カテゴリ管理 / 目標 / 通知） |
| 07 | [07_categories.md](07_categories.md) | カテゴリ追加・編集シート |
| 08 | [08_goals.md](08_goals.md) | 目標追加・編集シート |
| 09 | [09_timer_presets.md](09_timer_presets.md) | タイマープリセット編集ページ |
| 10 | [10_regression_test.md](10_regression_test.md) | リリース前マニュアルリグレッションテスト |

## 共通ルール

### 通知（トースト）
`SnackBar` は使わず、`TopToast.show()`（画面上部に表示される独自オーバーレイ）に統一。詳細は CLAUDE.md「Notifications (Toasts)」セクション参照。

### ボトムシート
- すべて `isDismissible: true`（シート外タップ / 下方向スワイプで閉じる）
- 専用「キャンセル」ボタンは置かない
- 編集モードでは削除と保存ボタンを横並びで表示

### 色（テーマ）
- Primary: Sky `#0EA5E9` (Tailwind sky-500, issue #87 で Indigo `#4F46E5` から変更)
- FAB: GitHub Green `#2DA44E` + 円形
- 削除: `colorScheme.error` の赤フィルド
