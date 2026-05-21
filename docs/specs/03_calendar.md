# カレンダー画面

## 概要
月別カレンダー上に毎日の積み上げ金額を表示し、日付タップで当日のセッション一覧を確認できる画面。

## UI 構成
```
[AppBar] "カレンダー"
[Column]
  1. カスタムヘッダー（年月 + 日付範囲サブタイトル + 左右矢印）
  2. TableCalendar（曜日ヘッダー + 日付グリッド、headerVisible: false）
  3. Divider
  4. 選択日のセッション一覧
     - "M月d日 (E)" ラベル + 合計金額
     - SessionCard リスト（スワイプ削除なし、タップで編集）
```

## カレンダー設定
- 表示範囲: `firstDay = 2020-01-01` ～ `lastDay = (今年 + 5).12.31`
- 週始まり: **日曜** (`StartingDayOfWeek.sunday`)
- ロケール: `ja_JP`
- `rowHeight: 56` / `daysOfWeekHeight: 28`

### 曜日ヘッダー（dowBuilder）
- フォント: 12px / w600
- 色:
  - 日曜: light `#D32F2F` / dark `#E57373`（赤）
  - 土曜: light `#1976D2` / dark `#64B5F6`（青）
  - 平日: `colorScheme.onSurfaceVariant`

### 日付セル（_DayCell）
- 数字フォント: 15px、`(isToday || isSelected)` で w700、それ以外 w500
- 金額: 日付の下、10px、primary 色、w500
- 金額表記:
  - < 10,000: カンマ区切り（例: 5,123）
  - ≥ 10,000: 「N.N万」形式
- **金額の有無で日付の縦位置がずれないよう、金額スロットは固定 13px を常に予約**（PR #31）
- 背景色（issue #52）:
  - 金額がある日: その日に最も稼いだ **主カテゴリの色** を背景に
  - alpha は月内最大金額に対する比率で `0.10〜0.25` に正規化（簡易ヒートマップ）
  - 金額 0 の日: 透明
- 選択日: 背景色はそのままに `colorScheme.primary` の **枠線 1.5px** で強調（カテゴリ色と区別）
- outside（前月/翌月）の日: 数字 alpha 0.4 で減衰、背景は常に透明

### カスタムヘッダー
- 「2026年5月」（titleMedium, w700）
- サブタイトル「5月1日〜5月31日」（bodySmall, onSurfaceVariant）
- 左右 IconButton（chevron_left / chevron_right）で月切替

## リスト表示の上限
- 選択日のセッション一覧: **制限なし**（その日のセッション全件を ListView.separated で表示）

## 遷移
- 日付タップ → 選択日のセッション一覧を更新
- セッションタップ → `ManualRecordSheet.show()` で編集
- 左右矢印 / スワイプ → 月切替

## 状態
- **Loading**: セッション読み込み中は中央に `CircularProgressIndicator`
- **Error**: 「読み込みに失敗しました: $e」
- **Empty (日別)**: `_EmptyDayView`（event_busy_outlined + 「この日の記録はありません」）

## 通知（トースト）
カレンダー画面自体ではトーストを発生させない。セッション編集は `ManualRecordSheet` 側で発生（[05_history.md](05_history.md) 参照）。

## 関連ファイル
- `lib/features/history/presentation/calendar_page.dart`
- `lib/features/history/application/calendar_providers.dart`
- `lib/shared/utils/weekday_color.dart`
- `lib/shared/widgets/mirai_date_picker_sheet.dart`（同じ意匠を共通化）
