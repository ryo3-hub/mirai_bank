# 履歴画面

## 概要
過去の作業セッションを日別にグループ化して**閲覧専用**で表示する画面
（issue #85）。記録の作成はホームのタイマー停止時のみ、編集は不可、削除のみ
スワイプジェスチャで実行できる。

## 動線（issue #54）
ボトムナビには履歴タブを置かず、**設定 → 履歴** から `/settings/history` に
プッシュ遷移する。AppBar の戻るボタンで設定一覧に戻れる。

なおカレンダー画面の日付タップでもその日のセッション一覧（閲覧のみ）に
到達できる。

## 履歴ページの位置づけ（issue #85）
履歴は **閲覧専用** のページ。新規記録の追加・既存セッションの編集はできない。
記録の作成はホーム画面のタイマー（停止時の自動保存）からのみ行う。
削除のみスワイプジェスチャで実行できる（誤記録の取り消し用）。

## UI 構成

### 履歴一覧画面（HistoryPage）
```
[AppBar] "履歴" + 戻る
[Body]
  CustomScrollView
    - 日付ヘッダー（SliverPersistentHeader, pinned）
    - 各セッション（SessionCard）スワイプ削除のみ
```

FAB なし。セッションをタップしても何も起きない（編集不可）。

### セッションカード（SessionCard）
- アイコン円（カテゴリカラー + アイコン）
- カテゴリ名（`Expanded + ellipsis`）+ 入力方式バッジ（タイマー / 手動）
- 時間範囲「HH:mm–HH:mm」+ 作業時間（`DurationFormatter.hourMinuteSecond` で秒まで表示：例 「1時間30分45秒」、issue #57）
- メモ（任意、maxLines: 2 + ellipsis）
- 金額（primary 色、w700）
- タップしても何も起きない（issue #85 で onTap を撤去）

### スワイプ削除（唯一のセッション操作）
- `Dismissible(direction: DismissDirection.endToStart)`
- 背景: 赤背景 + 白いゴミ箱アイコン
- `confirmDismiss`: `showDeleteConfirmDialog` で確認
- 削除は `ManualRecordController.delete(id)` でソフトデリート

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
| スワイプ削除（一覧） | 「記録を削除しました」 | 「削除に失敗しました: $e」 |

## 関連ファイル
- `lib/features/history/presentation/history_page.dart`
- `lib/features/history/presentation/widgets/session_card.dart`
- `lib/features/history/application/manual_record_providers.dart`（現在は delete のみ）
- `lib/features/history/application/session_list_providers.dart`
- `lib/features/history/domain/work_session.dart`
- `lib/features/history/domain/day_session_group.dart`
