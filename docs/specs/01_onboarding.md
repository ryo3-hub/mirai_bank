# オンボーディング画面

## 概要
初回インストール時のみ表示される 2 ステップの全画面フォーム。

1. **カテゴリ設定ステップ**（必須）: 最初のカテゴリと時給を登録、または「あとで設定する」でスキップ
2. **目標設定ステップ**（任意）: issue #102 で追加。カテゴリを実際に作った場合のみ続けて表示。プリセット（短期/中期/長期）から目標を選ぶ。スキップ可能

カテゴリをスキップしたユーザーには目標ステップは出さない（カテゴリ無しでは時給ベースの目標金額が計算できないため）。

## 表示条件
- `shared_preferences` の `onboarding_completed` フラグが **false**
- かつ カテゴリが **0 件**
- 上記両方が満たされた場合のみ `routerProvider` の redirect で `/onboarding` に遷移
- カテゴリ作成直後（目標ステップ表示中）も `/onboarding` に留まる
  - issue #102 で redirect 条件を `onboardingCompleted` のみに変更（hasCategories は使わない）
- どちらのステップでもスキップ後はフラグが立つので、ホームに留まれる

## ステップ 1: カテゴリ設定

### UI 構成
```
[Scaffold]
  body: SingleChildScrollView
    - 円形バッジ（Icons.savings_outlined + 薄い primary 背景）
    - 「ようこそ」ヘッドライン
    - 「まず、カテゴリを 1 つ設定しましょう。あとから自由に変更できます。」
    - SegmentedButton [プリセット | カスタム]   ← issue #97
      （`CategoryEditModeSelector` 共通ウィジェット、13px / w600）
    - ── プリセット の場合 ──
      - プリセット選択カード（タップで CategoryMasterPickerSheet）
        - 未選択: 「プリセットから選ぶ」
        - 選択中: 大カテゴリ / 小カテゴリ + 推奨時給を表示
    - ── カスタム の場合 ──
      - カテゴリ名 TextFormField
      - 時給 TextFormField
    - アイコンセクション（カラー付きピッカー、両モード共通）
    - カラーセクション（カラーピッカー、両モード共通）
    - FilledButton「始める」
    - TextButton「あとで設定する」
  Stack overlay (キーボード表示中):
    - 画面下部に「完了」バー（タップで unfocus）
```

背景タップで `FocusScope.of(context).unfocus()`（キーボード閉じ）。
デフォルトは **プリセット**。プリセット選択時は名前 / 時給入力欄は
画面に出さず、master から自動入力された値で保存される。プリセット未選択で
「始める」を押すとエラートースト「プリセットを選んでください」。アイコン /
カラーは両モードで編集可能（プリセット選択時は major の既定が初期値）。

### 入力フィールド

#### カテゴリ名
- 初期値: 空
- プレースホルダー: 「例：プログラミング、英語、資格」（`floatingLabelBehavior: always`）
- 最大長: **30 文字** (`Category.nameMaxLength`)
- バリデーション:
  - 必須（空 / 空白のみは不可）→ 「カテゴリ名を入力してください」
  - 30 文字超 → 「30文字以内で入力してください」
- `textInputAction: next` → 時給フィールドへフォーカス移動

#### 時給
- 初期値: `1000`
- キーボード: number（数字のみ `FilteringTextInputFormatter.digitsOnly`）
- 範囲: **100 〜 10,000 円** (`Category.hourlyRateMin/Max`)
- バリデーション:
  - 必須 → 「時給を入力してください」
  - 数値以外 → 「数値を入力してください」
  - < 100 → 「100円以上を入力してください」
  - > 10000 → 「10000円以下を入力してください」
- helperText: 「将来の自分にとっての時間価値を入力」

#### アイコン / カラー
- アイコン: 12 種類のプリセットから選択（`CategoryPresets.icons`）
- カラー: 8 色のプリセットから選択（`CategoryPresets.colors`）
- デフォルト: `defaultIcon = 'school'`、`defaultColor = '#2E7D5B'`

### アクション

#### 始める ボタン
1. バリデーション実行
2. `CategoryController.create()` でカテゴリ作成（作成された Category を保持）
3. **目標設定ステップへ遷移**（同じ `/onboarding` ルート内で内部 step を切り替え）

#### あとで設定する リンク
1. `OnboardingState.markCompleted()` のみ実行（カテゴリ作成しない）
2. ルーター redirect により `/home` に遷移
3. ホーム画面のタイマーカードに「カテゴリを追加」ボタンが表示される
4. 目標ステップはスキップされる

## ステップ 2: 目標設定（カテゴリ作成後のみ）

### UI 構成
```
[Scaffold]
  body: SingleChildScrollView
    - 円形バッジ（Icons.flag_outlined + 薄い primary 背景）
    - 「目標を選びましょう」ヘッドライン
    - 「達成予定日と金額の目安を表示します。あとから自由に変更できます。」
    - 直前に作成したカテゴリのチップ（アイコン + 名前）
    - プリセット 3 ボタン（縦並び）
      - 短期目標 (7日間) / 中期目標 (30日間) / 長期目標 (90日間)
      - 各カードに「達成予定: YYYY/M/d」と目標金額を表示
      - 選択中はラジオアイコン + アクセント色枠
    - FilledButton「設定する」（プリセット未選択時は無効）
    - TextButton「あとで設定する」
```

### プリセット金額計算
- カテゴリ指定時（このステップは常に直前のカテゴリ固定）: `時給 × 7 / 30 / 90`
- 達成予定日: 当日 0:00 + プリセット日数

### アクション

#### 設定する ボタン
1. `GoalController.create(type: period, ...)` で目標作成
   - `categoryId` = 直前に作ったカテゴリの id
   - `periodStart` = 当日 0:00、`periodEnd` = 当日 + プリセット日数
   - `targetAmount` = 時給 × プリセット日数
2. `OnboardingState.markCompleted()`
3. ルーター redirect により `/home` に遷移

#### あとで設定する リンク
1. `OnboardingState.markCompleted()` のみ実行
2. `/home` に遷移
3. ホームの目標 0 件カード「目標を追加」から後で設定できる

## 状態
- **Loading**: 各ボタン押下中は `CircularProgressIndicator(strokeWidth: 2)` を表示し、両ボタンを無効化
- **Error**: トーストで失敗を表示（「保存に失敗しました: $e」「初期化に失敗しました: $e」）

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| カテゴリ「始める」 | なし（目標ステップへ） | エラートースト |
| カテゴリ「あとで設定する」 | なし（ホーム遷移） | エラートースト |
| 目標「設定する」 | なし（ホーム遷移） | エラートースト |
| 目標「あとで設定する」 | なし（ホーム遷移） | エラートースト |

## 関連ファイル
- `lib/features/onboarding/presentation/onboarding_page.dart`
- `lib/features/onboarding/application/onboarding_state.dart`
- `lib/features/category/presentation/widgets/category_form_widgets.dart`
- `lib/features/goals/domain/goal.dart`（`GoalPreset` enum）
- `lib/app/router.dart`（redirect ロジック）
