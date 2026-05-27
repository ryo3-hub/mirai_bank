# 統計画面

## 概要
期間を切り替えて、累計金額・カテゴリ別シェア・推移グラフを確認できる画面。

## UI 構成
```
[AppBar] "統計"
[Column]
  1. 期間切替 SegmentedButton（週 / 今月 / 今年 / 全期間）
  2. (Expanded SingleChildScrollView)
     - StatsSummaryCard
     - (空き 12px)
     - StatsTrendChartCard
     - (空き 12px)
     - StatsBreakdownCard
```

## 期間切替（StatsPeriod）
| 値 | ラベル | 範囲 |
|---|---|---|
| `week` | 週 | 過去 7 日（日付バケット） |
| `month` | 今月 | 当月 1 日〜末日（日付バケット） |
| `year` | 今年 | 1月〜12月（月バケット） |
| `all` | 全期間 | 最初の記録〜今日（月バケット） |

デフォルト: `week`

## カード詳細

### StatsSummaryCard
- 「期間サマリ」ラベル
- 合計金額（`AnimatedAmount`、36px、primary、tabular）
- 合計作業時間（`DurationFormatter.hourMinute`）
- 区切り線
- 「最も学習」行
  - カテゴリアイコン + 名前 + 期間内金額
  - **長いカテゴリ名は `…` で省略** (`Flexible + TextOverflow.ellipsis + maxLines:1`)

### StatsTrendChartCard
- 棒グラフ（`fl_chart`）
- Y 軸目盛間隔: **1-2-5 系列から自動選択**（最大値÷c が 5 以下になる最小値）
  - 例: 最大 12,000 → 5,000 刻み / 最大 30,000 → 10,000 刻み / 最大 250,000 → 50,000 刻み
- maxY: `(maxAmount * 1.15)` を interval の倍数に丸めて整数化
- Y 軸ラベル: **カンマ区切り**（例: `5,000`、`10,000`）、reservedSize 56
- X 軸ラベル: バケット数に応じて間引き（≤10: 全て / ≤20: 3 ごと / >20: 5 ごと）
- バー幅: バケット数に応じて段階的に縮小
  - ≤7: 24 / ≤12: 16 / ≤20: 10 / >20: 6
- 空のとき: アイコン + 「データがありません」

### StatsBreakdownCard
- 上段：**ドーナツ円グラフ**（`fl_chart` の `PieChart`、高さ 180px、`centerSpaceRadius: 36`、`sectionsSpace: 2`）
  - 各セクションは `radius: 56`、塗りはカテゴリ色
  - シェアが 8% 以上のセクションだけセンターに `N%` を白字 w700 12px で表示（小さい
    パイは数字を出さない）
  - `swapAnimationDuration: 350ms`
- 下段：カテゴリ別シェア一覧（凡例）
  - 各行: カラードット（12×12、角丸 3px）+ カテゴリ名 (`Expanded + ellipsis`) + 金額 + パーセント
- データが無いときはパイ円グラフを描かず `_BreakdownEmpty`（アイコン + 「データがありません」）を表示

## リスト表示の上限
- StatsBreakdownCard: **全件表示**（制限なし。データが多い場合はスクロール）

## 状態
- **Loading**: 中央に `CircularProgressIndicator`
- **Error**: 「読み込みに失敗しました: $e」
- **Empty (推移グラフ)**: `_ChartEmpty`（bar_chart アイコン + 「データがありません」）
- **Empty (全体)**: 各カードがそれぞれ空状態を表示

## 通知（トースト）
この画面ではトーストは発生しない（閲覧専用）。

## 関連ファイル
- `lib/features/statistics/presentation/statistics_page.dart`
- `lib/features/statistics/presentation/widgets/stats_summary_card.dart`
- `lib/features/statistics/presentation/widgets/stats_trend_chart_card.dart`
- `lib/features/statistics/presentation/widgets/stats_breakdown_card.dart`
- `lib/features/statistics/application/stats_providers.dart`
- `lib/features/statistics/domain/stats_data.dart`
