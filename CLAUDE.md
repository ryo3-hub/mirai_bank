# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`mirai_bank` is a Flutter application (SDK ^3.7.0). Currently in early/scaffold state — only the default counter demo app exists in `lib/main.dart`.

## Commands

```bash
# Run the app
flutter run

# Run on a specific device
flutter run -d <device_id>

# List available devices
flutter devices

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Analyze code (lint)
flutter analyze

# Get dependencies
flutter pub get

# Build for release
flutter build apk          # Android
flutter build ios          # iOS
flutter build macos        # macOS
```

## Architecture

The project follows standard Flutter conventions:

- `lib/main.dart` — entry point; `MyApp` sets up `MaterialApp`, `MyHomePage` is the root widget
- `test/` — widget tests using `flutter_test`
- Platform directories (`android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/`) contain platform-specific runner code

State management is currently plain `StatefulWidget` with `setState`. As the app grows, introduce a state management solution (e.g., Riverpod, Bloc, or Provider) before adding complex features.

## Ticket & Todo Management

チケットは `docs/` 配下のマークダウンファイルで管理する（`001_` 〜 の連番ファイル）。

### Todo の書き方
- 未完了タスク: `- [ ] タスク内容`
- 完了タスク: `- [×] タスク内容`

タスクが完了したら `[ ]` を `[×]` に更新すること。`[x]` ではなく `[×]`（全角バツ）を使う。

---

## Flutter Best Practices

### Widget Design
- Prefer `const` constructors everywhere possible — Flutter uses them to skip rebuilds
- Extract widgets into dedicated classes (not private methods) so `const` optimization and testing work correctly
- Keep each widget small and focused on a single responsibility
- Use `ListView.builder` / `SliverList` for any list that may be long; never pass a large `children:` array

### Riverpod (state management)
- Use code generation (`@riverpod` annotation) — avoids manual `Provider` boilerplate
- `ref.watch` inside `build`; `ref.read` inside callbacks and event handlers — never the reverse
- Use `AsyncNotifier` for providers that load data asynchronously; expose state as `AsyncValue<T>`
- Never store `ref` in a field of a `Notifier`; access it only within the class methods where it is provided

### Null Safety
- Avoid the `!` bang operator unless a null is logically impossible and you can justify it in a comment
- Prefer `?.`, `??`, and `if (x != null)` guards over forced unwrapping

### Async
- Use `async`/`await` over `.then()` chains for readability
- Always cancel `StreamSubscription`s and `Timer`s in `dispose()` to avoid memory leaks

### Error Handling
- Represent loading/error/data states with `AsyncValue` from Riverpod; never silently swallow exceptions
- Show user-facing error messages through a consistent UI pattern (e.g., `SnackBar` or inline error widget)

### Theming & Styling
- Never hardcode colors or text styles; always read from `Theme.of(context)` or your design token constants
- Define light and dark `ThemeData` from the start so dark-mode support is not a retrofit

### Folder Structure
Follow feature-first layout inside `lib/`:
```
lib/
  features/
    category/
      presentation/   # Widgets, screens
      application/    # Riverpod providers, use-cases
      domain/         # Entities, value objects
      infrastructure/ # DB repositories, mappers
    timer/
    history/
    statistics/
    settings/
  shared/             # Common widgets, utilities, theme
  main.dart
```

### Code Style
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`; private members prefixed with `_`
- Run `flutter analyze` and fix all warnings before committing

### Testing
- Unit-test all domain and application logic
- Widget-test screens using `WidgetTester`; test Riverpod providers with `ProviderContainer`
- Avoid mocking the local database in integration tests — use an in-memory instance instead

---

# 自己投資価値見える化アプリ 要件定義書

## 1. アプリ概要

### 1.1 コンセプト
**「自己投資の価値を"見える化"して、勉強・スキルアップのモチベーションを維持するアプリ」**

勉強やスキルアップは将来的な収入につながる「自己投資」だが、即時的な報酬がないため継続が難しい。本アプリは作業時間に時給を設定することで、積み上げた努力の金銭的価値を可視化し、モチベーションを維持する。

### 1.2 ターゲットユーザー
- 資格勉強・プログラミング学習・語学学習など、長期的なスキルアップに取り組む人
- 勉強の成果が見えづらく、モチベーション維持に課題を感じている人

### 1.3 コア価値
「今日の1時間の勉強には、未来の自分にとって○○円の価値がある」と実感できること。

### 1.4 プラットフォーム
- iOS / Android（Flutter による単一コードベース）

---

## 2. 機能要件

### 2.1 MVP（必須機能）

#### ① カテゴリ管理
- カテゴリの作成・編集・削除（例：プログラミング、英語、資格）
- カテゴリごとに時給を設定（例：プログラミング 3,000 円/h、英語 2,000 円/h）
- カテゴリにアイコンとカラーを設定（視覚的識別のため）
- **初期状態**：デフォルトカテゴリを1つだけ作成しておく（ユーザーが後から自由に追加・編集）

#### ② 作業時間の記録（2方式併用）

**(a) タイマー方式**
- カテゴリを選択して「開始」ボタンで計測開始
- 「停止」ボタンで終了 → 自動で記録保存
- **バックグラウンド対応**：計測開始時刻（タイムスタンプ）を保存しておき、アプリ復帰時に「現在時刻 − 開始時刻」で経過時間を算出する方式を採用
  - これによりアプリを閉じてもスマホをスリープしても計測継続が可能
  - 常駐タイマー処理を行わないためバッテリー消費が少ない
- 計測中は通知バーに「計測中：カテゴリ名 / 経過時間」を表示

**(b) 手動入力方式**
- 後から「○月○日 ○時間○分」を入力可能
- 日時の任意指定、過去日の入力にも対応

**共通**
- 記録時にカテゴリを選択 → 時給に基づき金額を自動計算
- メモ欄（任意）：何を勉強したかを記録
- 記録は後から編集・削除可能

#### ③ 累積金額の可視化
- トータル累積金額（全期間 / 今月 / 今週 / 今日）
- カテゴリ別累積金額（円グラフなど）
- 期間別推移グラフ（日次 / 週次 / 月次の棒グラフ・折れ線）

#### ④ カレンダー表示
- 月間カレンダーで日ごとの累積金額を表示
- 日付をタップすると、その日の作業セッション一覧を表示
- 金額に応じた色濃度（ヒートマップ表現）で多い日を強調

#### ⑤ 目標設定
- **累計目標**（例：累計 10 万円分の勉強）
- **期間目標**（例：今月 3 万円分）
- 目標達成率の進捗バー表示
- 目標達成時のお祝い演出（アニメーション・通知）

#### ⑥ 通知・リマインダー
- 指定時刻の学習リマインダー（例：毎日 21 時に通知）
- タイマー稼働中の常駐通知
- 目標達成通知
- 連続学習日数の節目通知（3 日、7 日、30 日など）

### 2.2 将来追加候補（MVP 外）

- クラウド同期 / 複数デバイス対応
- SNS 共有機能
- フレンド・ランキング機能
- 詳細な学習分析（時間帯別・曜日別など）
- データの CSV エクスポート
- 多言語対応（英語など）
- 複数通貨対応

---

## 3. 非機能要件

| 項目 | 内容 |
|---|---|
| プラットフォーム | iOS / Android（Flutter） |
| データ保存 | **初期はローカルのみ。将来クラウド同期を入れる前提でデータ設計** |
| オフライン動作 | 全機能オフラインで利用可能 |
| バックグラウンド動作 | タイマーは開始時刻記録方式で実質的に常時計測継続 |
| 多言語 | 日本語のみ（初期） |
| 通貨 | 円のみ（初期） |
| データバックアップ | 将来的に対応（クラウド同期と合わせて） |

### 3.1 将来のクラウド同期を見据えた設計指針
- 各エンティティに `updatedAt`、`createdAt` を持たせる
- 各エンティティを UUID で識別（自動採番 ID ではなく UUID）
- 削除はソフトデリート（`deletedAt` フラグ）を検討
- これにより、後からクラウド同期を実装する際の差分マージが容易になる

---

## 4. 画面構成

```
┌─ ホーム（ダッシュボード）
│   ├ 累積金額の大きな表示（全期間 or 今月切替）
│   ├ タイマー開始ボタン（カテゴリ選択 → スタート）
│   ├ 今日/今月の金額サマリ
│   └ 目標達成率の進捗バー
│
├─ カレンダー
│   ├ 月間カレンダー（日ごとに金額・色濃度表示)
│   └ 日付タップ → その日のセッション一覧
│
├─ 統計・グラフ
│   ├ 期間切替（週/月/年/全期間）
│   ├ カテゴリ別の累積金額（円グラフ）
│   └ 推移グラフ（折れ線/棒）
│
├─ 履歴・記録一覧
│   ├ セッション一覧（編集/削除可）
│   └ 手動入力ボタン
│
└─ 設定
    ├ カテゴリ管理（CRUD・時給設定）
    ├ 目標設定
    ├ 通知設定
    └ アプリ情報
```

### 4.1 ナビゲーション
- ボトムナビゲーションバーで主要画面（ホーム/カレンダー/統計/履歴/設定）を切替

---

## 5. データモデル

### 5.1 Category（カテゴリ）

| フィールド | 型 | 説明 |
|---|---|---|
| id | String (UUID) | 主キー |
| name | String | カテゴリ名 |
| hourlyRate | int | 時給（円） |
| colorCode | String | カラーコード（例：`#FF5733`） |
| iconCode | String | アイコン識別子 |
| createdAt | DateTime | 作成日時 |
| updatedAt | DateTime | 更新日時 |
| deletedAt | DateTime? | 削除日時（ソフトデリート） |

### 5.2 WorkSession（作業セッション）

| フィールド | 型 | 説明 |
|---|---|---|
| id | String (UUID) | 主キー |
| categoryId | String (UUID) | カテゴリ外部キー |
| startTime | DateTime | 作業開始日時 |
| endTime | DateTime | 作業終了日時 |
| durationSec | int | 作業時間（秒） |
| amount | int | 金額（円、確定値を保存） |
| memo | String? | メモ |
| inputMethod | enum | `timer` / `manual` |
| createdAt | DateTime | 作成日時 |
| updatedAt | DateTime | 更新日時 |
| deletedAt | DateTime? | 削除日時 |

**重要な設計方針**：
時給を後から変更しても過去の記録金額が変わらないように、`WorkSession` には **その時点で計算済みの `amount` を保存** する。
（時給変更が遡って累積金額を変動させると、ユーザー体験として不自然になるため）

### 5.3 ActiveTimer（計測中タイマー、シングルトン）

| フィールド | 型 | 説明 |
|---|---|---|
| categoryId | String (UUID) | 計測中のカテゴリ |
| startTime | DateTime | 計測開始時刻 |
| memo | String? | 計測中に入力可能なメモ |

アプリ復帰時、`現在時刻 - startTime` で経過時間を算出して画面に表示する。

### 5.4 Goal（目標）

| フィールド | 型 | 説明 |
|---|---|---|
| id | String (UUID) | 主キー |
| type | enum | `cumulative`（累計）/ `period`（期間） |
| targetAmount | int | 目標金額（円） |
| categoryId | String? | 対象カテゴリ（null の場合は全体） |
| periodStart | DateTime? | 期間開始日（期間目標のみ） |
| periodEnd | DateTime? | 期間終了日（期間目標のみ） |
| achievedAt | DateTime? | 達成日時 |
| createdAt | DateTime | 作成日時 |
| updatedAt | DateTime | 更新日時 |

### 5.5 Setting（設定）

| フィールド | 型 | 説明 |
|---|---|---|
| reminderEnabled | bool | リマインダー有効 |
| reminderTime | String | リマインダー時刻（"HH:mm"） |
| achievementNotificationEnabled | bool | 達成通知 |

---

## 6. Flutter 技術選定

| 領域 | 推奨ライブラリ | 理由 |
|---|---|---|
| 状態管理 | Riverpod | 型安全・テストしやすい・公式推奨の現代的アプローチ |
| ローカル DB | Drift または Isar | クエリしやすく、カレンダーや統計集計に強い |
| グラフ | fl_chart | カスタマイズ性が高く実績豊富 |
| カレンダー | table_calendar | 日本語対応・カスタムマーカー対応 |
| 通知 | flutter_local_notifications | 定番。バックグラウンド通知に対応 |
| ルーティング | go_router | 公式推奨・ディープリンク対応 |
| 日付処理 | intl | 国際化標準。日本語ロケール対応 |
| UUID 生成 | uuid | UUID v4 生成 |

### 6.1 アーキテクチャ方針
- **クリーンアーキテクチャ風のレイヤー分離**
  - `presentation`（UI・Widget）
  - `application`（状態管理・ユースケース）
  - `domain`（エンティティ・ビジネスロジック）
  - `infrastructure`（DB・通知・永続化）
- 将来のクラウド同期実装に備え、`infrastructure` 層を差し替え可能な設計に

---

## 7. 主要なビジネスルール

### 7.1 金額計算
```
amount = (durationSec / 3600) × hourlyRate
```
※小数点以下は四捨五入（円単位で保存）

### 7.2 時給変更時の挙動
- カテゴリの時給を変更しても、**過去のセッションの金額は変動しない**
- 変更以降の新規セッションのみ新時給で計算される

### 7.3 タイマーの開始時刻記録方式
- タイマー開始時に `ActiveTimer` テーブルに開始時刻を保存
- アプリ復帰時・画面更新時は `現在時刻 - startTime` で経過秒数を算出
- 停止時に `WorkSession` を作成し、`ActiveTimer` をクリア
- アプリ強制終了後の再起動時も、`ActiveTimer` が残っていれば計測継続中として復元

### 7.4 1日の集計の境界
- 日付の境界は **デバイスのローカルタイムゾーンの 0:00** で区切る
- 日をまたぐセッションの扱いは MVP では「終了時刻が属する日」に集計（実装の単純化のため）
  ※将来的に「日ごとに按分する」オプションを検討

---

## 8. 開発フェーズ（提案）

### Phase 1：MVP コア（最優先）
1. カテゴリ管理機能
2. タイマー方式の作業記録
3. 手動入力方式の作業記録
4. ホーム画面の累積金額表示
5. ローカル DB 構築

### Phase 2：可視化機能
6. カレンダー表示
7. 統計・グラフ画面
8. 履歴一覧画面

### Phase 3：継続支援機能
9. 目標設定機能
10. 通知・リマインダー機能
11. 達成演出

### Phase 4：将来拡張
- クラウド同期
- データエクスポート
- ソーシャル機能

---

## 9. 未確定・要検討事項

今後の開発段階で詰めるべき項目：

- [ ] アプリ名
- [ ] 具体的なデザインテイスト（モダン / 親しみやすい / シンプル等）
- [ ] アプリアイコン
- [ ] 無料 / 有料 / アプリ内課金の方針
- [ ] アナリティクス導入の有無（Firebase Analytics 等）
- [ ] クラッシュレポート（Sentry, Firebase Crashlytics 等）
- [ ] プライバシーポリシー・利用規約の文面
- [ ] ストア掲載文・スクリーンショット

---

## 改訂履歴

| 日付 | 内容 |
|---|---|
| 2026-05-17 | 初版作成 |
