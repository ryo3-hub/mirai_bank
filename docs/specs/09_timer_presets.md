# タイマープリセット（追加 / 一覧）

## 概要
カウントダウンタイマー (issue #95) で選択する **目標時間プリセット** の編集ページ。
設定 → タイマープリセット (`/settings/timer-presets`) から開く。

## デフォルト
初回起動時 / v5 アップグレード時に以下をシード（`isDefault = true`）：

| 分 | 説明 |
|---|---|
| 15 | さくっと集中 |
| 30 | 集中する |
| 60 | じっくり腰を据えて |

デフォルトもユーザーは削除可能（`isDefault` は保護用フラグではなく由来表示用）。

## UI 構成

### TimerPresetListPage (`/settings/timer-presets`)
```
[AppBar] "タイマープリセット" + 戻る
[ListView]
  - 各プリセット行 (TimerPresetCard)
    - 円形バッジ（数字大字、primaryContainer 背景）
    - title: ラベル（空のときは "N分集中"）
    - subtitle: "N 分"
    - 削除 IconButton (showDeleteConfirmDialog)
[FAB] "+" → TimerPresetEditSheet.show()
```

並び順は `minutes ASC, sortOrder ASC`（短い順）。

### TimerPresetEditSheet
```
[BottomSheet]（showDragHandle, isDismissible）
  - "プリセットを追加" (titleLarge)
  - 時間 CupertinoPicker（5..480 分、5 分刻み、ドラムロール）
  - 説明 TextField（任意、30 文字以内）
  - 「追加」FilledButton
```

編集機能は MVP では実装しない（削除 → 再作成で対応）。

## バリデーション
- 時間: 5..480 分 / 5 分単位（`TimerPreset.validateMinutes`）
- 説明: 任意、30 文字以内
- 不正値 → エラートースト表示

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| 追加 | 「プリセットを追加しました」 | 「保存に失敗しました: $e」 |
| 削除 | 「プリセットを削除しました」 | 「削除に失敗しました: $e」 |

## データモデル

### TimerPresets テーブル（v5 で新設）
| カラム | 型 | 備考 |
|---|---|---|
| id | TEXT PK | UUID |
| minutes | INTEGER | 5..480 |
| label | TEXT | 説明文、空可 |
| sortOrder | INTEGER | 同分数時の安定化用 |
| isDefault | BOOL | シード由来かユーザー追加か |
| createdAt | DATETIME | |
| updatedAt | DATETIME | |
| deletedAt | DATETIME? | ソフトデリート |

新規追加時の `sortOrder` は `max(sortOrder) + 1`。

## ホームとの連動
ホームのタイマーカード（`HomePage`）も同じ `timerPresetListProvider`
を購読し、先頭から **最大 3 件** をプリセットカードとしてインライン表示する。
追加 / 削除は `watchAll` 経由で即時反映。

カード 3 枚は `IntrinsicHeight` + `CrossAxisAlignment.stretch` で常に同じ高さに揃える
（issue #119）。説明（label）の有無でカード高さが変わらないよう、内部の Column は
`mainAxisAlignment: MainAxisAlignment.center` で中央寄せ。

## 関連ファイル
- `lib/features/timer/presentation/timer_preset_list_page.dart`
- `lib/features/timer/presentation/timer_preset_edit_sheet.dart`
- `lib/features/timer/presentation/home_page.dart`（プリセット選択 UI）
- `lib/features/timer/application/timer_preset_providers.dart`
- `lib/features/timer/infrastructure/timer_preset_repository*.dart`
- `lib/features/timer/domain/timer_preset.dart`
- `lib/infrastructure/database/tables.dart` (TimerPresets)
- `lib/app/router.dart` (`/settings/timer-presets`)
