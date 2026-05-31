#!/usr/bin/env python3
"""mirai_bank の App Store / LP 用マーケスライド 6 枚を生成する。

入力: シミュレータで撮った生スクショ（issue #180 のセットアップ参照）
  - $SRC_DIR/01_home.png
  - $SRC_DIR/02_calendar.png
  - $SRC_DIR/03_statistics.png
  - $SRC_DIR/04_goals.png
  - $SRC_DIR/05_categories.png
  - $SRC_DIR/06_timer_running.png

出力:
  docs/lp/screenshots/full/  1290×2796（App Store Connect の 6.7" スロット互換）
  docs/lp/screenshots/web/    幅 800px（LP 埋め込み用、長辺 1733 程度に縮小）

スライドのレイアウト：
- 縦グラデ背景（Sky #0369A1 → #38BDF8）
- 上部に太字キャッチ + サブテキスト（白）
- 中央〜下に端末スクショを ~5.5° 斜めに配置 + ソフトシャドウ
- 下部に "mirai_bank" のロゴ文字

再撮影手順（生スクショ作成）はリポジトリの issue #180 / PR を参照。
基本フロー：
  1. シミュレータの status bar を Apple 推奨にオーバーレイ
       xcrun simctl status_bar booted override --time "9:41" --batteryLevel 100 ...
  2. デモ用カテゴリ・セッション・目標を SQLite に直接 seed
  3. アプリを再起動して各画面のスクショを撮影
  4. $SRC_DIR に置いて本スクリプトを実行
"""
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SRC = ROOT / "docs" / "lp" / "screenshots" / "raw"
DEFAULT_FULL_OUT = ROOT / "docs" / "lp" / "screenshots" / "full"
DEFAULT_WEB_OUT = ROOT / "docs" / "lp" / "screenshots" / "web"

W, H = 1290, 2796
WEB_W = 800  # 縮小版の長辺基準（横幅）

# 背景: 上 sky-700 → 下 sky-400
SKY_TOP = (3, 105, 161)
SKY_BTM = (56, 189, 248)
WHITE = (255, 255, 255)
SUBTEXT = (235, 245, 255)
BRAND_LABEL = (255, 255, 255, 200)

FONT_BOLD = "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"
FONT_REG = "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc"

# (元ファイル名, ヘッドライン, サブヘッド) — App Store の並び順。
# 元ファイル名は $SRC_DIR/<filename>.png に存在する前提。
SLIDES = [
    ("01_home.png",
     "学びが、お金として\n積み上がる。",
     "時間 × 時給で、自己投資を見える化"),
    ("06_timer_running.png",
     "タイマーを、\n回すだけ。",
     "5 分単位で、自動で積み上がる"),
    ("02_calendar.png",
     "続けるほど、\nカラフルに。",
     "毎日の積み上げが、ヒートマップに"),
    ("03_statistics.png",
     "努力が、\n数字でわかる。",
     "週・月・年で、推移とカテゴリ分布"),
    ("04_goals.png",
     "目標までの距離が、\n明確に。",
     "短期・中期・長期で、進捗を可視化"),
    ("05_categories.png",
     "学びの種類、\nまるごと網羅。",
     "14 大カテゴリ × 65 のプリセット"),
]


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size)


def gradient_bg() -> Image.Image:
    ys = np.linspace(0, 1, H).reshape(-1, 1)
    r = (SKY_TOP[0] * (1 - ys) + SKY_BTM[0] * ys).astype(np.uint8)
    g = (SKY_TOP[1] * (1 - ys) + SKY_BTM[1] * ys).astype(np.uint8)
    b = (SKY_TOP[2] * (1 - ys) + SKY_BTM[2] * ys).astype(np.uint8)
    row = np.concatenate([r, g, b], axis=1).reshape(H, 1, 3)
    arr = np.broadcast_to(row, (H, W, 3)).copy()
    return Image.fromarray(arr, "RGB").convert("RGBA")


def rounded(img: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, img.width - 1, img.height - 1), radius=radius, fill=255
    )
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0), mask)
    return out


def soft_shadow(silhouette: Image.Image, blur: int = 70, opacity: int = 180) -> Image.Image:
    pad = blur * 2
    a = silhouette.split()[3]
    big = Image.new("L", (a.width + pad, a.height + pad), 0)
    big.paste(a, (pad // 2, pad // 2))
    big = big.point(lambda v: min(opacity, v))
    blurred = big.filter(ImageFilter.GaussianBlur(radius=blur))
    out = Image.new("RGBA", (a.width + pad, a.height + pad), (0, 0, 0, 0))
    out.putalpha(blurred)
    return out


def draw_multiline_center(
    draw: ImageDraw.ImageDraw,
    text: str,
    x_center: int,
    y_top: int,
    font_obj: ImageFont.FreeTypeFont,
    fill,
    line_gap: float = 1.18,
):
    lines = text.split("\n")
    ascent, descent = font_obj.getmetrics()
    line_h = int((ascent + descent) * line_gap)
    y = y_top
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font_obj)
        w = bbox[2] - bbox[0]
        draw.text((x_center - w / 2, y), line, font=font_obj, fill=fill)
        y += line_h
    return y - y_top


def render_slide(shot_path: Path, headline: str, subhead: str, tilt: float = 5.5) -> Image.Image:
    canvas = gradient_bg()
    draw = ImageDraw.Draw(canvas)

    title_font = font(110, bold=True)
    sub_font = font(46)
    title_top = 220
    title_h = draw_multiline_center(draw, headline, W // 2, title_top, title_font, WHITE)
    sub_top = title_top + title_h + 40
    sub_h = draw_multiline_center(draw, subhead, W // 2, sub_top, sub_font, SUBTEXT)

    target_w = int(W * 0.78)
    shot = Image.open(shot_path).convert("RGBA")
    scale = target_w / shot.width
    target_h = int(shot.height * scale)
    shot = shot.resize((target_w, target_h), Image.LANCZOS)
    shot = rounded(shot, radius=64)

    shadow = soft_shadow(shot, blur=60, opacity=170)
    tilted = shot.rotate(tilt, resample=Image.BICUBIC, expand=True)
    tilted_shadow = shadow.rotate(tilt, resample=Image.BICUBIC, expand=True)

    available_top = sub_top + sub_h + 90
    sy = available_top
    sx = (W - tilted.width) // 2
    sxs = sx - (tilted_shadow.width - tilted.width) // 2
    sys = sy + 30
    canvas.alpha_composite(tilted_shadow, (sxs, sys))
    canvas.alpha_composite(tilted, (sx, sy))

    brand_font = font(40, bold=True)
    brand_text = "mirai_bank"
    bbox = draw.textbbox((0, 0), brand_text, font=brand_font)
    draw.text(
        ((W - (bbox[2] - bbox[0])) / 2, H - 130),
        brand_text,
        font=brand_font,
        fill=BRAND_LABEL,
    )

    return canvas.convert("RGB")


def make_web_version(full: Image.Image) -> Image.Image:
    new_h = int(full.height * (WEB_W / full.width))
    return full.resize((WEB_W, new_h), Image.LANCZOS)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--src", default=str(DEFAULT_SRC))
    parser.add_argument("--full-out", default=str(DEFAULT_FULL_OUT))
    parser.add_argument("--web-out", default=str(DEFAULT_WEB_OUT))
    args = parser.parse_args()

    src = Path(args.src)
    full_out = Path(args.full_out)
    web_out = Path(args.web_out)
    full_out.mkdir(parents=True, exist_ok=True)
    web_out.mkdir(parents=True, exist_ok=True)

    for i, (src_name, headline, subhead) in enumerate(SLIDES, 1):
        shot_path = src / src_name
        if not shot_path.exists():
            raise FileNotFoundError(shot_path)
        slide = render_slide(shot_path, headline, subhead)
        stem = f"{i:02d}_{Path(src_name).stem.split('_', 1)[1]}"
        full_path = full_out / f"{stem}.png"
        web_path = web_out / f"{stem}.png"
        slide.save(full_path, "PNG", optimize=True)
        make_web_version(slide).save(web_path, "PNG", optimize=True)
        print(f"  -> {full_path.relative_to(ROOT)} + {web_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
