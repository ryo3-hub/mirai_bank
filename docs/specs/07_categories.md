# カテゴリ追加・編集シート + カテゴリ管理ページ

## 概要
学習カテゴリを作成・編集するボトムシート。設定 > カテゴリ管理から、またはホームの「カテゴリを追加」ボタンから開かれる。

## カテゴリ管理ページ（CategoryListPage）

`/settings/categories` に対応。`ReorderableListView.builder` で一覧表示し、
長押し → ドラッグ&ドロップでユーザーが任意の順序に並び替え可能（issue #58）。

- ヘッダー: 「カテゴリ N件 / 長押しで並び替え」ガイド
- 並び順は `Category.sortOrder` で永続化（DB schemaVersion v4 で追加）
- 新規追加カテゴリはアクティブカテゴリの末尾（max sortOrder + 1）に挿入される
- 触覚フィードバック: `onReorderStart` = `HapticFeedback.mediumImpact()`、
  `onReorder` = `HapticFeedback.heavyImpact()`（タイマープリセットと同じ強度）
- カテゴリピッカー（タイマー / 手動入力時）も同じ並び順で表示される
  （`watchAll` を通すので自動で反映）
- 共通 `AddActionFab`（Extended FAB、`Icons.add` + 「カテゴリを追加」ラベル、
  primary 色塗り、角丸 16、issue #123 で円形 FAB から差し替え）
- 各カテゴリカード: アイコン / 名前 / 時給 / 削除 IconButton
- 削除前に `showDeleteConfirmDialog` で確認

## UI 構成
```
[BottomSheet]（showDragHandle: true, isDismissible: true）
  - SegmentedButton [プリセット | カスタム]   ← issue #97
    （`CategoryEditModeSelector` 共通ウィジェット、13px / w600）
  - ── プリセット の場合 ──
    - プリセット選択カード
      - 未選択: 「カテゴリを選ぶ」
      - 選択中: 大カテゴリ / 小カテゴリ + 推奨時給を表示
      - タップで CategoryMasterPickerSheet を開く
  - ── カスタム の場合 ──
    - カテゴリ名 TextFormField
    - 時給 TextFormField
  - アイコンセクション（両モード共通、編集可）
  - カラーセクション（両モード共通、編集可）
  - 保存ボタン（横幅一杯）
```

プリセットモードでは名前 / 時給入力欄は画面に出さず、master から自動入力された
値で保存される。プリセット未選択で「保存」を押すとエラートースト「プリセットを
選んでください」。アイコン / カラーは両モードで編集可能（プリセット時は major
の既定が初期値）。

シート上部のタイトル表記（「新規カテゴリ」「カテゴリを編集」）は issue #103 で
削除。ドラッグハンドル + 内容で文脈が伝わるため。

専用「キャンセル」ボタンなし。シート外タップ / 下スワイプで閉じる。

### モード初期値
- 新規 → **プリセットから選ぶ**（初心者向け、時給の相場を提示）
- 編集 → 既存カテゴリに `masterKey` があれば **プリセット**、無ければ **自分で設定**

### CategoryMasterPickerSheet（issue #97）
プリセット選択用の独立シート。`showModalBottomSheet` で別シートとして開き、
内部で大カテゴリ → 小カテゴリの 2 ステップ。
- ステップ 1: 14 個の大カテゴリを 2 列グリッドで表示（五十音順）
- ステップ 2: 選んだ大カテゴリの小カテゴリ一覧（五十音順）+ 推奨時給
- 小カテゴリをタップすると `CategoryMasterMinor` を返してシートを閉じる
- 編集モードで開いた場合は `initialMajorKey` で該当 major のステップ 2 から開始
- マスタデータは `lib/features/category/domain/category_master.dart` に const 定義
  （14 大カテゴリ × 計 55 小カテゴリ）

### プリセット選択後の挙動
- カテゴリ名・時給・アイコン・カラーが master に基づいて自動入力される
- いずれのフィールドも以降は手で編集可能（プリセットからの「ヒント」扱い）
- `Category.masterKey` には選んだ minor の key が保存される（自由入力で
  作成した場合は null）

## 入力フィールド

### カテゴリ名（`CategoryNameField`）
- 初期値（新規）: 空
- 初期値（編集）: 既存のカテゴリ名
- プレースホルダー: 「例：プログラミング、英語、資格」（`floatingLabelBehavior: always`）
- 最大長: **30 文字** (`Category.nameMaxLength`)
- バリデーション:
  - 必須 → 「カテゴリ名を入力してください」
  - 30 文字超 → 「30文字以内で入力してください」

### 時給（`CategoryHourlyRateField`）
- 初期値（新規）: **1000**
- 初期値（編集）: 既存の時給
- キーボード: number、数字のみ
- 範囲: **100 〜 10,000 円** (`Category.hourlyRateMin/Max`)
- バリデーション:
  - 必須 → 「時給を入力してください」
  - 数値以外 → 「数値を入力してください」
  - < 100 → 「100円以上を入力してください」
  - > 10000 → 「10000円以下を入力してください」
- suffix: 「円/h」

### アイコン（`CategoryIconPicker`）
- 12 種類のプリセット (`CategoryPresets.icons`)
  - school / code / language / menu_book / fitness_center / music_note / palette / biotech / calculate / translate / work / self_improvement
- 選択中アイコン: 選択カラーで塗り、白アイコン
- 未選択: 選択カラーの alpha 0.15、`onSurface` のアイコン

### カラー（`CategoryColorPicker`）
- 8 色プリセット (`CategoryPresets.colors`)
  - `#2E7D5B` / `#1976D2` / `#D32F2F` / `#F57C00` / `#7B1FA2` / `#0097A7` / `#5D4037` / `#455A64`
- 選択中: `onSurface` のボーダー + 白チェック

## アクション

### 保存
- 新規: `CategoryController.create()`
- 編集: `CategoryController.updateCategory(initial.copyWith(...))`
- 既存セッションの amount は時給変更で**変更されない**（記録時に確定済み）
- 保存ボタンは共通 `SaveActionButton`（高さ 54、角丸 16、アイコン + ラベル、横幅一杯）
  - 新規時のラベル: 「カテゴリを追加」 / 編集時のラベル: 「カテゴリを更新」
  - 保存中は `CircularProgressIndicator` に差し替え、押下不可

### キーボード完了バー（issue #114, #117）
時給フィールド（number キーボード）にはキーボード上の「return」が無いので、
キーボード表示中（`MediaQuery.viewInsetsOf(context).bottom > 0`）にのみ
シート最下段に共通 `KeyboardDoneBar` を表示する。タップで `unfocus()`。

シートは `showModalBottomSheet(useRootNavigator: true)` で開く（issue #117）。
`AppShell` の `Scaffold` が `resizeToAvoidBottomInset: true` で
`viewInsets.bottom` を消費してしまうため、ルート Navigator に push しないと
シート内の `MediaQuery.viewInsets.bottom` が常に 0 になり、完了バーが描画されない。

### 削除
このシートには削除ボタンはない（削除はカテゴリ一覧の trailing IconButton から実行）。

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| 追加 | 「カテゴリを追加しました」 | 「保存に失敗しました: $e」 |
| 編集 | 「カテゴリを更新しました」 | 「保存に失敗しました: $e」 |
| 削除（一覧から） | 「カテゴリを削除しました」 | 「削除に失敗しました: $e」 |

## 関連ファイル
- `lib/features/category/presentation/category_edit_sheet.dart`
- `lib/features/category/presentation/category_list_page.dart`
- `lib/features/category/presentation/category_master_picker_sheet.dart`
- `lib/features/category/presentation/widgets/category_form_widgets.dart`
- `lib/features/category/presentation/widgets/category_edit_mode_selector.dart`（共通 SegmentedButton + `CategoryEditMode` enum）
- `lib/shared/widgets/save_action_button.dart`（共通保存ボタン）
- `lib/shared/widgets/keyboard_done_bar.dart`（共通キーボード完了バー）
- `lib/features/category/application/category_providers.dart`
- `lib/features/category/domain/category.dart`
- `lib/features/category/domain/category_master.dart`（プリセット master 55 件）
- `lib/features/category/domain/category_presets.dart`
