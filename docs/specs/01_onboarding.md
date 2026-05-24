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
    - SaveActionButton「始める」（issue #114 で共通化）
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

issue #108 で 3 問のウィザード形式に変更（Q1 → Q2 → Q3 → 結果）。
各質問は 4 択。回答からその場で目標金額・期間を算出する。

### UI 構成（共通）
```
[Scaffold]
  body: SingleChildScrollView
    - 上段：戻る IconButton + 進捗インジケータ「1/3」「2/3」「3/3」
    - 中段：質問ヘッドライン + 4 つの選択肢カード（emoji + ラベル + 補足）
      - 各質問で「続けやすい」推奨選択肢には小さな「おすすめ」バッジ
        （緑系、ラベルの右）
    - 下段：TextButton「あとで設定する」
  ※ 結果画面は別レイアウト（後述）
```

### おすすめ選択肢（`isRecommended = true`）
習慣形成のスイートスポットを各質問で 1 つずつマーク：

| 質問 | おすすめ | 理由 |
|---|---|---|
| Q1 | 平日中心（週5日） | 毎日は負担、週末のみは習慣化しにくい |
| Q2 | 短時間でテンポよく（30〜60分） | じっくりは負担、スキマは効果が薄い |
| Q3 | 中期的に身につけたい（3ヶ月） | 習慣形成に必要十分な期間 |

### Q1: 学習頻度（ライフスタイル）
ヘッドライン: 「どんなペースで取り組みたいですか？」
（カテゴリ名をサブヘッドで表示）

| 選択肢 | 補足 | 計算で使う週稼働日数 |
|---|---|---|
| 🌱 毎日コツコツ続けたい | 週7日 | 7 |
| 💼 平日中心にしっかりやりたい | 週5日 | 5 |
| 🎯 週末メインで集中したい | 週2日 | 2 |
| 🌊 自分のペースで気が向いたとき | 週3日想定 | 3 |

### Q2: 1 回あたりの作業時間（集中度）
ヘッドライン: 「1回あたりどれくらい取り組みたいですか？」

| 選択肢 | 補足 | 計算で使う 1 日あたり時間 |
|---|---|---|
| ⏳ じっくり腰を据えて | 2時間以上 | 2.5h |
| 🔥 しっかり集中して | 1〜2時間 | 1.5h |
| ⚡ 短時間でテンポよく | 30分〜1時間 | 0.75h |
| ☕ スキマ時間で少しずつ | 15〜30分 | 0.4h |

### Q3: 取り組み期間（コミット度）
ヘッドライン: 「どれくらいの期間続けたいですか？」

| 選択肢 | 補足 | 計算で使う月数 |
|---|---|---|
| 🚀 短期集中で結果を出したい | 1ヶ月 | 1 |
| 📈 中期的に身につけたい | 3ヶ月 | 3 |
| 🌳 半年かけてじっくり | 半年 | 6 |
| ♾️ 長期的に習慣にしたい | 1年以上 | 12 |

### 結果画面
```
- 戻る IconButton（→ Q3 へ）
- 円形バッジ（Icons.flag_outlined）
- 「おすすめの目標」ヘッドライン
- カテゴリチップ
- カード:
  - 「Xヶ月コース」/「半年コース」/「1年以上コース」
  - 「達成予定: YYYY/M/d」
  - 累計目標金額（大きく primary 色）
  - 「月あたり Y 円」
  - 区切り線
  - ペース / 1 回あたり / 期間 の 3 行
- ヒントカード（ハード組み合わせ時のみ表示、後述）
- SaveActionButton「この目標で設定する」（issue #114 で共通化）
- TextButton「あとで設定する」
```

### 飛ばしすぎ警告ヒントカード
`GoalQuestionnaireResult.isHardCombo` が true のときだけ表示。
高頻度（毎日 / 平日）× 高強度（じっくり / しっかり）× 長期（半年 / 1年）の
組み合わせを選んだとき。

文言：
```
1日◯時間 × （毎日|平日） × （半年|1年）は、年間累計 約◯万円分 のすごい自己投資ペースです。
ただ、最初から飛ばしすぎると続かなくなることも。
7割くらいの目標から始めて、慣れてきたら上げていくのもおすすめですよ。
```

- 1日◯時間: 選択した `sessionLength.hoursPerDay`
- （毎日|平日）: `frequency.phrase`
- （半年|1年）: `period.phrase`
- 約◯万円: `annualTargetAmount(hourlyRate) / 10000` を四捨五入

UI はオレンジ系のアクセントカラー枠 + `Icons.tips_and_updates_outlined`。

### 金額計算式
```
期間日数       = 期間月数 × 30
総稼働日数     = 期間日数 × (週稼働日数 ÷ 7)
累計目標金額   = 総稼働日数 × 1日あたり時間 × 時給
月間目標金額   = 累計目標金額 ÷ 期間月数
```

実装は `lib/features/onboarding/domain/goal_questionnaire.dart` の
`GoalQuestionnaireResult.cumulativeTargetAmount(hourlyRate)`。

例：時給 1,000 円 / 毎日 / じっくり / 1ヶ月 = 75,000 円
例：時給 1,000 円 / 毎日 / じっくり / 1年 = 900,000 円
例：時給 1,000 円 / 週末 / スキマ / 1ヶ月 ≈ 3,429 円

### 戻る IconButton（issue #106 / #108）
- **Q1 の戻る**: 直前に作成したカテゴリをソフトデリートし、カテゴリステップへ復帰（案 B: ロールバック）
- **Q2 / Q3 / 結果 の戻る**: 1 つ前の質問に戻る（カテゴリは保持）
- 保存中（`_saving = true`）は無効化

### Goal への保存
- `type` = `GoalType.period`
- `periodStart` = 当日 0:00
- `periodEnd` = 当日 + 期間月数 × 30 日
- `targetAmount` = 計算式の結果
- `categoryId` = 直前に作ったカテゴリの id

### あとで設定する
- 各質問画面 / 結果画面の TextButton「あとで設定する」
- `OnboardingState.markCompleted()` のみ実行 → `/home` に遷移
- ホームの目標 0 件カード「目標を追加」から後で設定できる

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
- `lib/features/onboarding/domain/goal_questionnaire.dart`（質問票と計算式）
- `lib/features/category/presentation/widgets/category_form_widgets.dart`
- `lib/features/goals/domain/goal.dart`
- `lib/app/router.dart`（redirect ロジック）
