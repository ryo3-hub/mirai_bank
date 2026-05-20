# カテゴリ追加・編集シート

## 概要
学習カテゴリを作成・編集するボトムシート。設定 > カテゴリ管理から、またはホームの「カテゴリを追加」ボタンから開かれる。

## UI 構成
```
[BottomSheet]（showDragHandle: true, isDismissible: true）
  - "新規カテゴリ" or "カテゴリを編集"（titleLarge）
  - カテゴリ名 TextFormField
  - 時給 TextFormField
  - アイコンセクション
  - カラーセクション
  - 保存ボタン（横幅一杯）
```

専用「キャンセル」ボタンなし。シート外タップ / 下スワイプで閉じる。

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
- `lib/features/category/presentation/widgets/category_form_widgets.dart`
- `lib/features/category/application/category_providers.dart`
- `lib/features/category/domain/category.dart`
- `lib/features/category/domain/category_presets.dart`
