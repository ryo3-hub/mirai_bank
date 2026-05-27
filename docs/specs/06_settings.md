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
  - ListTile「データ管理」 → /settings/data              ← #144
  - Divider
  - SectionHeader「通知」
  - ListTile「通知設定」 → /settings/notifications
  - Divider
  - SectionHeader「その他」
  - ListTile「お問い合わせ」 → ContactService.openInquiryMail()   ← #142
  - ListTile「アプリを評価する」 → AppReviewService.requestExplicit()   ← #141
  - ListTile「利用規約」 → /settings/terms             ← #140
  - ListTile「プライバシーポリシー」 → /settings/privacy   ← #139
  - ListTile「アプリについて」 → /settings/about       ← #143
```

本ページに直接の入力フィールドはなく、各 ListTile タップで子ページに遷移する。
履歴はボトムナビからは外れており、本ページ経由でのみアクセスする（issue #54）。

## 子画面

### カテゴリ管理（/settings/categories）
- `CategoryListPage`
- 一覧 + 共通 `AddActionFab`「カテゴリを追加」（Extended FAB、primary 色、角丸 16、issue #123）
- 各カテゴリカード: アイコン / 名前 / 時給 / 削除 IconButton（テーマ色）
- 削除前に `showDeleteConfirmDialog` で確認

### 目標設定（/settings/goals）
- `GoalListPage`
- アクティブな目標一覧 + 達成済み（折りたたみセクション）
- 共通 `AddActionFab`「目標を追加」（Extended FAB、primary 色、角丸 16、issue #123）
- 各目標カード（GoalCard）: 種別 / カテゴリ / 進捗バー / % / 金額

### 履歴（/settings/history）
- `HistoryPage`（詳細は [05_history.md](05_history.md)）
- ボトムナビからは外れており、設定 → 履歴 経由でアクセスする

### データ管理（/settings/data、issue #144）
- `DataManagementPage`
- 「データをエクスポート」: `BackupService.exportToFile()` で全テーブルを
  JSON にシリアライズ → 一時ファイル作成 → `share_plus` で共有シートを開く
- 「データを復元」: `file_picker` で JSON を選択 → 確認ダイアログ →
  `BackupService.importFromFile(file)` でトランザクション内で全件上書き
- ファイル名: `mirai_bank_backup_YYYYMMDD_HHmm.json`
- JSON 形式バージョン (`schemaVersion = 6`) が現アプリと不一致なら
  `BackupFormatException` でエラートースト
- 機種変時はユーザーが iCloud Drive / Google Drive 等を経由してファイルを移す

### アプリについて（/settings/about、issue #143）
- `AboutPage`
- 表示内容:
  - アイコン円（savings_outlined、primary 12% 背景）
  - アプリ名（`package_info_plus` の `appName`）
  - 「バージョン X.Y.Z (BUILD)」
  - ListTile「OSS ライセンス」（タップで Flutter 標準の `showLicensePage`）
- 著作権表示は `applicationLegalese: '© 2026 ryo3-hub'`

### クラッシュレポート（issue #145、運用）
- `sentry_flutter` を `lib/main.dart` で初期化（`SentryFlutter.init` でラップ）
- DSN は `--dart-define=SENTRY_DSN=...` で注入（リポジトリにはコミットしない）
- DSN 未指定（ローカル開発・テスト）ではクラッシュ送信を完全スキップ
- `tracesSampleRate`: 本番 0.1 / 開発 1.0
- `environment`: `kReleaseMode` で production / development を切替
- `sendDefaultPii = false`（IP / Cookie 等を送らない）
- 既知の bootstrap 失敗は `Sentry.captureException` で明示送信
- プライバシーポリシー（issue #139）の「第三者サービス」節に Sentry 利用を
  明記（送信される情報: スタックトレース / アプリバージョン / OS / 端末モデル、
  個人特定情報は送信しない）

### お問い合わせ（issue #142）
- 設定 → 「お問い合わせ」タップで `ContactService.openInquiryMail()` を呼ぶ
- `mailto:` URI を組み立てて `url_launcher` で既定メールアプリを起動
- 件名: `[mirai_bank] お問い合わせ`
- 本文末尾に `package_info_plus` / `device_info_plus` で取得した
  アプリバージョン / OS / 端末モデルを自動付与
- 送信先メールアドレスは `--dart-define=SUPPORT_EMAIL=...` で上書き可能。
  既定値は `r357box.app@gmail.com`（issue #162 で確定）
- 失敗時はエラートースト

### アプリを評価する（issue #141）
- 設定 → 「アプリを評価する」タップで `AppReviewService.requestExplicit()` を呼ぶ
- 利用可能なら `InAppReview.requestReview()`（iOS の SKStoreReviewController /
  Android の Google Play In-App Review）。利用不可なら `openStoreListing` で
  ストアアプリに遷移
- 自動トリガー: 達成系の体験直後に `maybeRequestAfterAchievement()` を呼ぶ前提
  （60 日のクールダウン付き、利用不可ならノーオペ）
- DSN や App Store ID は `--dart-define=APP_STORE_ID=...` で渡す想定

### 利用規約（/settings/terms、issue #140）
- `TermsPage`（`LegalDocumentPage` の共通実装をラップ）
- 本文は `LegalTexts.terms`
- 「アプリ表示金額はモチベ用の参考値で、実際の収入を保証しない」「金融商品ではない」
  といった免責が中心。準拠法・裁判管轄も記載
- 改訂はアプリ更新で配信

### プライバシーポリシー（/settings/privacy、issue #139）
- `PrivacyPolicyPage`（`LegalDocumentPage` の共通実装をラップ）
- 本文は `lib/features/settings/domain/legal_texts.dart` の
  `LegalTexts.privacyPolicy`（`LegalSection` の配列）にバンドルされており、
  外部 URL ホスティングなしでアプリ内表示
- 改訂時はアプリのバージョンアップで配信。最終更新日も同ファイルに定義
- 取得データは端末ローカルのみ・第三者送信なし、を明記

### 通知設定（/settings/notifications）
- `NotificationSettingsPage`
- 構成：
  - SwitchListTile「学習リマインダー」（指定時刻に通知）
  - ListTile「リマインダー時刻」（リマインダー有効時のみタップ可能、`MiraiTimePickerSheet` / ドラムロール）
  - 通知する曜日（共通 `WeekdayPicker` を `Row` + `Expanded` で 1 行に。日始まり。0 件選択時は赤の警告文。`lib/shared/widgets/weekday_picker.dart`、issue #121 で共通化）
  - SwitchListTile「達成通知」（目標達成・連続学習の節目で通知）

#### 学習リマインダー
- スイッチ ON: `NotificationService.scheduleDailyReminder(time, weekdays)` で通知をスケジュール
- スイッチ OFF: 通知キャンセル

#### リマインダー時刻
- 現在の時刻を表示（例: 9:00 PM）
- タップで `MiraiTimePickerSheet`（ドラムロール、24h、1 分刻み、issue #73）を開いて変更
- リマインダー OFF のときはグレーアウト

#### 通知する曜日
- 共通 `WeekdayPicker`（`lib/shared/widgets/weekday_picker.dart`、issue #121 で
  オンボーディングと共通化）を使い、**日〜土** の 7 セルを `Row` + `Expanded` で
  均等割りで 1 行に並べる（日曜始まり、issue #88）
- 各セルは角丸 12px、高さ 44px、白背景 + 枠線スタイル
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
