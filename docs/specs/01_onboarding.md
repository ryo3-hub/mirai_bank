# オンボーディング画面

## 概要
初回インストール時のみ表示される、最初のカテゴリと時給を設定するための全画面フォーム。スキップも可能。

## 表示条件
- `shared_preferences` の `onboarding_completed` フラグが **false**
- かつ カテゴリが **0 件**
- 上記両方が満たされた場合のみ `routerProvider` の redirect で `/onboarding` に遷移
- スキップ後はフラグが立つので、カテゴリ 0 件のままでもホームに留まれる

## UI 構成
```
[Scaffold]
  body: SingleChildScrollView
    - 円形バッジ（Icons.savings_outlined + 薄い primary 背景）
    - 「ようこそ」ヘッドライン
    - 「まず、カテゴリを 1 つ設定しましょう。あとから自由に変更できます。」
    - SegmentedButton [プリセットから選ぶ | 自分で設定]   ← issue #97
    - ── プリセットから選ぶの場合 ──
      - プリセット選択カード（タップで CategoryMasterPickerSheet）
        - 未選択: 「プリセットから選ぶ」
        - 選択中: 大カテゴリ / 小カテゴリ + 推奨時給を表示
    - ── 自分で設定の場合 ──
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
デフォルトは「プリセットから選ぶ」。プリセット選択時は名前 / 時給入力欄は
画面に出さず、master から自動入力された値で保存される。アイコン / カラーは
両モードで編集可能（プリセット選択時は major の既定が初期値）。

## 入力フィールド

### カテゴリ名
- 初期値: 空
- プレースホルダー: 「例：プログラミング、英語、資格」（`floatingLabelBehavior: always`）
- 最大長: **30 文字** (`Category.nameMaxLength`)
- バリデーション:
  - 必須（空 / 空白のみは不可）→ 「カテゴリ名を入力してください」
  - 30 文字超 → 「30文字以内で入力してください」
- `textInputAction: next` → 時給フィールドへフォーカス移動

### 時給
- 初期値: `1000`
- キーボード: number（数字のみ `FilteringTextInputFormatter.digitsOnly`）
- 範囲: **100 〜 10,000 円** (`Category.hourlyRateMin/Max`)
- バリデーション:
  - 必須 → 「時給を入力してください」
  - 数値以外 → 「数値を入力してください」
  - < 100 → 「100円以上を入力してください」
  - > 10000 → 「10000円以下を入力してください」
- helperText: 「将来の自分にとっての時間価値を入力」

### アイコン / カラー
- アイコン: 12 種類のプリセットから選択（`CategoryPresets.icons`）
- カラー: 8 色のプリセットから選択（`CategoryPresets.colors`）
- デフォルト: `defaultIcon = 'school'`、`defaultColor = '#2E7D5B'`

## アクション

### 始める ボタン
1. バリデーション実行
2. `CategoryController.create()` でカテゴリ作成
3. `OnboardingState.markCompleted()` でフラグ true 化
4. ルーター redirect により自動で `/home` に遷移

### あとで設定する リンク
1. `OnboardingState.markCompleted()` のみ実行（カテゴリ作成しない）
2. ルーター redirect により `/home` に遷移
3. ホーム画面のタイマーカードに「カテゴリを追加」ボタンが表示される

## 状態
- **Loading**: 各ボタン押下中は `CircularProgressIndicator(strokeWidth: 2)` を表示し、両ボタンを無効化
- **Error**: トーストで失敗を表示（「保存に失敗しました: $e」「初期化に失敗しました: $e」）

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| 始める | なし（ホーム遷移） | エラートースト |
| あとで設定する | なし（ホーム遷移） | エラートースト |

## 関連ファイル
- `lib/features/onboarding/presentation/onboarding_page.dart`
- `lib/features/onboarding/application/onboarding_state.dart`
- `lib/features/category/presentation/widgets/category_form_widgets.dart`
- `lib/app/router.dart`（redirect ロジック）
