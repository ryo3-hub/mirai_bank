# mirai_bank Landing Page

App Store 提出に必要な公開 URL（プライバシー / サポート / マーケティング）を
GitHub Pages でホスティングするための静的サイト。issue #176 で導入。

## 構成

| ファイル | 役割 |
|---|---|
| `index.html` | ランディング（アプリ概要 + 特徴 + 各ページへのリンク） |
| `privacy.html` | プライバシーポリシー（`LegalTexts.privacyPolicy` と同期） |
| `terms.html` | 利用規約（`LegalTexts.terms` と同期） |
| `support.html` | サポート（メールリンク + FAQ） |
| `styles.css` | 共通スタイル（Sky → Green のブランドカラー） |
| `assets/brand.png` | ブランドロゴ（`assets/source/brand_icon.png` のコピー） |
| `screenshots/raw/` | シミュレータで撮ったままの生スクショ（再生成のソース、issue #180） |
| `screenshots/full/` | App Store Connect 用のスタイル付きスライド 1290×2796 |
| `screenshots/web/` | LP 埋め込み用に縮小したスライド（幅 800px） |

## GitHub Pages を有効化する手順

1. リポジトリの **Settings → Pages** を開く
2. **Source** を `Deploy from a branch` に設定
3. **Branch** を `main` / `/docs` に設定して **Save**
4. 数十秒待って、以下の URL でアクセスできることを確認：
   - `https://ryo3-hub.github.io/mirai_bank/lp/`
   - `https://ryo3-hub.github.io/mirai_bank/lp/privacy.html`
   - `https://ryo3-hub.github.io/mirai_bank/lp/terms.html`
   - `https://ryo3-hub.github.io/mirai_bank/lp/support.html`

> ⚠️ Pages を有効化すると `docs/` 配下が **全公開** されます。リポジトリ自体が
> public なので spec ドキュメント等が見えても実害なし、と判断しています。
> もし非公開にしたい部分があれば、`docs/` の構成を分離するか別ブランチへ移してください。

## App Store Connect の各 URL に入れる値

| 項目 | URL |
|---|---|
| Marketing URL | `https://ryo3-hub.github.io/mirai_bank/lp/` |
| Privacy Policy URL | `https://ryo3-hub.github.io/mirai_bank/lp/privacy.html` |
| Support URL | `https://ryo3-hub.github.io/mirai_bank/lp/support.html` |

## 文面の同期ルール

- `privacy.html` / `terms.html` の本文は `lib/features/settings/domain/legal_texts.dart` の
  `LegalTexts.privacyPolicy` / `LegalTexts.terms` と **同期する**
- 改訂時は **両方** 同時に更新し、最終更新日（HTML 上の "最終更新日:" 表示と
  Dart 側 `privacyPolicyUpdatedAt` / `termsUpdatedAt`）も揃える
- 大きな改訂（=第三者送信先の追加など）はストアのリリースノートでも告知する

## ローカルでの確認

```bash
# 適当な静的サーバーで確認
cd docs/lp
python3 -m http.server 8000
# → http://localhost:8000/ で表示
```

## スクリーンショットの再生成（issue #180）

### 生スクショ撮影
1. シミュレータ（iPhone 16 Pro 推奨）をブート
2. status bar を Apple 推奨で固定
   ```
   xcrun simctl status_bar booted override \
     --time "9:41" --batteryLevel 100 --batteryState charged \
     --dataNetwork wifi --wifiBars 3 --cellularBars 4
   ```
3. アプリを `flutter run` でインストール → 一旦 terminate
4. シミュレータの SQLite に直接デモデータを seed（`docs/lp/screenshots/raw/` 配下にコミット済みのものはこの手順で作った）
5. アプリを再起動して **ホーム / カレンダー / 統計 / 目標 / カテゴリ / タイマー稼働中** の 6 画面を `xcrun simctl io booted screenshot` で撮影
6. ファイル名は `01_home.png` `02_calendar.png` ... のように番号と画面名を付ける（順番がスライドの並びになる）

### スタイル付きスライドへ
```bash
# raw → full + web に変換
python3 tool/render_marketing_slides.py
# 出力先:
#   docs/lp/screenshots/full/  1290×2796（App Store Connect 用）
#   docs/lp/screenshots/web/   幅 800px（LP 埋め込み用）
```

キャッチコピーは `tool/render_marketing_slides.py` の `SLIDES` 定数で管理しているので、文言だけ変えたいときはここを編集してから再実行。
