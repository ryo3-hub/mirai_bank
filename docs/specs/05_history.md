# 履歴画面 + 手動入力シート

## 概要
過去の作業セッションを日別にグループ化して一覧表示し、編集・削除・新規追加を行う画面。

## 動線（issue #54）
ボトムナビには履歴タブを置かず、**設定 → 履歴** から `/settings/history` に
プッシュ遷移する。AppBar の戻るボタンで設定一覧に戻れる。

なおカレンダー画面の日付タップでもその日のセッション一覧 / 編集シートに到達できる。

## UI 構成

### 履歴一覧画面（HistoryPage）
```
[AppBar] "履歴" + 戻る
[Body]
  CustomScrollView
    - 日付ヘッダー（SliverPersistentHeader, pinned）
    - 各セッション（SessionCard）スワイプ削除可能
[FloatingActionButton]（円形、GitHub Green、＋アイコン）
  → ManualRecordSheet.show()
```

### セッションカード（SessionCard）
- アイコン円（カテゴリカラー + アイコン）
- カテゴリ名（`Expanded + ellipsis`）+ 入力方式バッジ（タイマー / 手動）
- 時間範囲「HH:mm–HH:mm」+ 作業時間
- メモ（任意、maxLines: 2 + ellipsis）
- 金額（primary 色、w700）

### スワイプ削除
- `Dismissible(direction: DismissDirection.endToStart)`
- 背景: 赤背景 + 白いゴミ箱アイコン
- `confirmDismiss`: `showDeleteConfirmDialog` で確認

## 手動入力シート（ManualRecordSheet）

### UI 構成
```
[BottomSheet]（isScrollControlled: true, isDismissible: true）
  - "手動で記録" or "記録を編集"
  - （編集時のみ）🔒 「編集できるのはメモのみです」
  - カテゴリフィールド（新規のみタップで CategoryPickerSheet。編集時は読み取り専用）
  - 日付フィールド（新規のみタップで showDatePicker。編集時は読み取り専用）
  - 時間帯（開始時刻 / 終了時刻、24h 表記。編集時は読み取り専用）
  - メモ TextField（任意、新規・編集どちらも編集可能）
  - ボタン行：
    - 新規: 保存ボタン横幅一杯
    - 編集: 削除 + 保存（均等幅）
```

### 編集制限（issue #51）
履歴の改ざんリスクを抑えるため、**編集モードでは「メモ」のみ書き換え可能**。
カテゴリ・日付・時間帯はロックアイコン (`Icons.lock_outline`) + グレー fill で
読み取り専用であることを明示し、タップしてもピッカーは開かない。
削除は従来どおり可能（編集制限の対象外）。

### カテゴリ
- 必須
- タップで `CategoryPickerSheet`（既存のカテゴリ一覧）
- 編集時は既存セッションの categoryId で初期化、それ以外は先頭カテゴリ
- バリデーション: 未選択 → 「カテゴリを選択してください」

### 日付
- `showDatePicker`（システムデフォルト）
- 範囲: `2020-01-01` 〜 **今日まで**（過去日のみ許可）
- 初期値（新規）: 今日 / 初期値（編集）: セッションの endTime の日付

### 時間帯（開始時刻 / 終了時刻）
- 24時間表記の `showTimePicker`（`alwaysUse24HourFormat: true`）
- 初期値（新規）: 直前 1 時間（now-1h 〜 now、分は `00` にスナップ）
- 初期値（編集）: 既存セッションの startTime / endTime の TimeOfDay
- バリデーション:
  - 終了 ≤ 開始 → 「終了時刻は開始時刻より後にしてください」
  - 日付跨ぎは MVP では非対応（同日内のみ）
- 作業時間（`durationSec`）は `endTime - startTime` で**自動計算**

### メモ
- 任意、複数行（maxLines: 2）
- 空白のみは null として保存

## アクション

### 保存（新規）
- `ManualRecordController.create(categoryId, startTime, endTime, memo)`
- 金額 = `AmountCalculator.calculate(durationSec, hourlyRate)`
- 保存後:
  - ⚡ `AmountFlash`（稼いだ金額アニメ）
  - トースト「記録を追加しました」
  - シートを閉じる

### 保存（編集）
- `ManualRecordController.updateRecord(session, ...)`
- 保存後:
  - トースト「記録を更新しました」
  - シートを閉じる

### 削除（編集モードのみ）
- `showDeleteConfirmDialog` で確認
- `ManualRecordController.delete(id)` でソフトデリート
- トースト「記録を削除しました」
- シートを閉じる

## リスト表示の上限
- 履歴一覧: **全件表示**（CustomScrollView + SliverList、データ量増加時は将来 pagination 検討）
- 日付グループ: 終了時刻 (`endTime`) が属する日でグループ化

## 状態
- **Loading**: `groupsAsync` 読み込み中は中央 `CircularProgressIndicator`
- **Error**: 「読み込みに失敗しました: $e」
- **Empty**: `_EmptyState`（event_note_outlined + 「記録がありません」）

## 通知（トースト）
| 操作 | 成功時 | 失敗時 |
|---|---|---|
| 手動追加 | ⚡ `AmountFlash` + 「記録を追加しました」 | 「保存に失敗しました: $e」 |
| 編集 | 「記録を更新しました」 | 「保存に失敗しました: $e」 |
| 削除（シート内） | 「記録を削除しました」 | 「削除に失敗しました: $e」 |
| スワイプ削除（一覧） | 「記録を削除しました」 | 「削除に失敗しました: $e」 |

## 関連ファイル
- `lib/features/history/presentation/history_page.dart`
- `lib/features/history/presentation/manual_record_sheet.dart`
- `lib/features/history/presentation/widgets/session_card.dart`
- `lib/features/history/application/manual_record_providers.dart`
- `lib/features/history/application/session_list_providers.dart`
- `lib/features/history/domain/work_session.dart`
- `lib/features/history/domain/day_session_group.dart`
- `lib/features/timer/domain/amount_calculator.dart`
