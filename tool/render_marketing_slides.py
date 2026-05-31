#!/usr/bin/env python3
"""mirai_bank の App Store / LP 用マーケスライド 6 枚を生成する。

各スライドはレイアウトを変えて単調にならないようにする（issue #180 / 改稿）：

  1. デュアル端末 + 上ヒーロー（ホーム + タイマー）
  2. シングル右斜め + 左に大型コールアウト（カレンダー）
  3. シングル左斜め + 右に大型数字（統計：週 ¥12,450）
  4. デュアル端末ズーム + 進捗強調（目標）
  5. シングル中央 + 周囲にフローティング装飾アイコン（カテゴリ）
  6. クロージング：ブランド + 全体タグライン + CTA

入力: docs/lp/screenshots/raw/0[1-6]_*.png（シミュレータ生スクショ）
出力:
  docs/lp/screenshots/full/   1290×2796（App Store Connect 用）
  docs/lp/screenshots/web/    幅 800px（LP 埋め込み用）
"""
from __future__ import annotations

import argparse
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_SRC = ROOT / "docs" / "lp" / "screenshots" / "raw"
DEFAULT_FULL_OUT = ROOT / "docs" / "lp" / "screenshots" / "full"
DEFAULT_WEB_OUT = ROOT / "docs" / "lp" / "screenshots" / "web"

W, H = 1290, 2796
WEB_W = 800

WHITE = (255, 255, 255)
INK = (15, 23, 42)         # slate-900
INK_SOFT = (51, 65, 85)    # slate-700

FONT_BOLD = "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc"
FONT_REG = "/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REG, size)


def vgrad(top_rgb: tuple, btm_rgb: tuple) -> Image.Image:
    """上→下の縦グラデ背景。"""
    ys = np.linspace(0, 1, H).reshape(-1, 1)
    r = (top_rgb[0] * (1 - ys) + btm_rgb[0] * ys).astype(np.uint8)
    g = (top_rgb[1] * (1 - ys) + btm_rgb[1] * ys).astype(np.uint8)
    b = (top_rgb[2] * (1 - ys) + btm_rgb[2] * ys).astype(np.uint8)
    row = np.concatenate([r, g, b], axis=1).reshape(H, 1, 3)
    arr = np.broadcast_to(row, (H, W, 3)).copy()
    return Image.fromarray(arr, "RGB").convert("RGBA")


def diag_grad(top_left: tuple, bottom_right: tuple) -> Image.Image:
    """斜め（TL→BR）グラデ。"""
    ys, xs = np.indices((H, W), dtype=np.float32)
    t = (xs / (W - 1) + ys / (H - 1)) / 2
    r = (top_left[0] * (1 - t) + bottom_right[0] * t).astype(np.uint8)
    g = (top_left[1] * (1 - t) + bottom_right[1] * t).astype(np.uint8)
    b = (top_left[2] * (1 - t) + bottom_right[2] * t).astype(np.uint8)
    arr = np.stack([r, g, b], axis=-1)
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


def shot(path: Path, target_w: int, corner_radius: int = 64) -> Image.Image:
    img = Image.open(path).convert("RGBA")
    scale = target_w / img.width
    th = int(img.height * scale)
    img = img.resize((target_w, th), Image.LANCZOS)
    return rounded(img, corner_radius)


def place_tilted(canvas: Image.Image, body: Image.Image, cx: int, cy: int, tilt: float,
                 shadow_blur: int = 60, shadow_opacity: int = 170, shadow_dy: int = 30):
    sh = soft_shadow(body, blur=shadow_blur, opacity=shadow_opacity)
    rb = body.rotate(tilt, resample=Image.BICUBIC, expand=True)
    rs = sh.rotate(tilt, resample=Image.BICUBIC, expand=True)
    sx_b = cx - rb.width // 2
    sy_b = cy - rb.height // 2
    sx_s = cx - rs.width // 2
    sy_s = cy - rs.height // 2 + shadow_dy
    canvas.alpha_composite(rs, (sx_s, sy_s))
    canvas.alpha_composite(rb, (sx_b, sy_b))


def draw_multiline(draw, text, x_center, y_top, font_obj, fill, line_gap=1.18, align="center"):
    """改行入りテキストの中央寄せ / 左揃え描画。"""
    lines = text.split("\n")
    ascent, descent = font_obj.getmetrics()
    line_h = int((ascent + descent) * line_gap)
    y = y_top
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font_obj)
        w = bbox[2] - bbox[0]
        if align == "center":
            x = x_center - w / 2
        elif align == "left":
            x = x_center  # x_center = left edge
        else:
            x = x_center - w  # right
        draw.text((x, y), line, font=font_obj, fill=fill)
        y += line_h
    return y - y_top


def draw_pill(draw, text, cx, cy, font_obj, bg, fg, padding=(28, 14)):
    bbox = draw.textbbox((0, 0), text, font=font_obj)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    rx, ry = padding
    x0 = int(cx - tw / 2 - rx)
    x1 = int(cx + tw / 2 + rx)
    y0 = int(cy - th / 2 - ry)
    y1 = int(cy + th / 2 + ry)
    draw.rounded_rectangle((x0, y0, x1, y1), radius=(y1 - y0) // 2, fill=bg)
    draw.text((cx - tw / 2, y0 + ry - bbox[1]), text, font=font_obj, fill=fg)


def draw_floating_dot(canvas, cx, cy, r, color, alpha=255):
    pad = r * 2 + 4
    tile = Image.new("RGBA", (pad, pad), (0, 0, 0, 0))
    ImageDraw.Draw(tile).ellipse((pad / 2 - r, pad / 2 - r, pad / 2 + r, pad / 2 + r),
                                  fill=color + (alpha,))
    canvas.alpha_composite(tile, (int(cx - pad / 2), int(cy - pad / 2)))


# ---------- 個別スライド ----------

def slide_01_hero(home_path: Path, timer_path: Path) -> Image.Image:
    """デュアル端末ヒーロー：ホーム + タイマー。"""
    canvas = vgrad((219, 234, 254), (191, 219, 254))  # blue-100 → blue-200
    # 上に大きな見出し
    draw = ImageDraw.Draw(canvas)
    draw_multiline(draw, "学び時間が、\nお金として積み上がる。", W // 2, 200,
                   font(108, bold=True), (12, 74, 110))  # sky-900
    draw_multiline(draw, "時間 × 時給で、自己投資を見える化", W // 2, 470,
                   font(46), (51, 65, 85))  # slate-700

    # 端末 2 台。左に Home（少し奥 / 後ろ）、右に Timer（手前 / 上）
    home = shot(home_path, target_w=620)
    timer = shot(timer_path, target_w=620)
    place_tilted(canvas, home, cx=420, cy=1670, tilt=8.0, shadow_blur=70, shadow_opacity=160)
    place_tilted(canvas, timer, cx=870, cy=1820, tilt=-6.0, shadow_blur=70, shadow_opacity=180)

    # 下のラベル
    brand_font = font(40, bold=True)
    bb = draw.textbbox((0, 0), "mirai_bank", font=brand_font)
    draw.text(((W - (bb[2] - bb[0])) / 2, H - 140), "mirai_bank",
              font=brand_font, fill=(12, 74, 110, 220))
    return canvas.convert("RGB")


def slide_02_calendar(calendar_path: Path) -> Image.Image:
    """カレンダー強調：左に大型見出し + 右にカレンダー端末。"""
    canvas = diag_grad((167, 243, 208), (110, 231, 183))  # green-200 → green-300
    draw = ImageDraw.Draw(canvas)

    # 左上に大型見出し
    draw_multiline(draw, "続けるほど、\nカラフルに。", 110, 240,
                   font(124, bold=True), (6, 95, 70), align="left")  # green-900
    draw_multiline(draw, "毎日の積み上げが\nヒートマップに残る。", 110, 690,
                   font(50), (52, 73, 94), align="left")

    # カレンダー端末（右寄せ、軽く左斜め）
    cal = shot(calendar_path, target_w=820)
    place_tilted(canvas, cal, cx=730, cy=1820, tilt=-4.0,
                 shadow_blur=80, shadow_opacity=170)

    # 「★」「●」みたいな装飾を左下にいくつか
    draw_floating_dot(canvas, 220, 1900, 22, (110, 231, 183), 220)
    draw_floating_dot(canvas, 160, 2060, 14, (16, 185, 129), 240)
    draw_floating_dot(canvas, 280, 2150, 28, (52, 211, 153), 200)
    return canvas.convert("RGB")


def slide_03_stats(stats_path: Path) -> Image.Image:
    """統計強調：上に大型数字、下に端末をスタック。"""
    canvas = vgrad((12, 74, 110), (3, 105, 161))  # sky-900 → sky-700
    draw = ImageDraw.Draw(canvas)

    # 上に大型数字 + ラベルをセンタリング
    draw_multiline(draw, "今週、", W // 2, 200,
                   font(80, bold=True), (186, 230, 253))  # sky-200
    # ¥12,450 を抜き出し
    big = "¥12,450"
    f_big = font(220, bold=True)
    bb = draw.textbbox((0, 0), big, font=f_big)
    draw.text(((W - (bb[2] - bb[0])) / 2, 320), big, font=f_big,
              fill=(254, 240, 138))  # yellow-200
    draw_multiline(draw, "ぶん、積み上げました。", W // 2, 600,
                   font(72, bold=True), WHITE)
    draw_multiline(draw, "週・月・年で、推移とカテゴリ分布", W // 2, 760,
                   font(42), (186, 230, 253))

    # 端末を下半分に配置（フッターロゴと被らないようサイズ控えめ）
    s = shot(stats_path, target_w=720)
    place_tilted(canvas, s, cx=W // 2, cy=1820, tilt=-2.0,
                 shadow_blur=80, shadow_opacity=200)

    # 下にロゴ
    brand_font = font(40, bold=True)
    bb = draw.textbbox((0, 0), "mirai_bank", font=brand_font)
    draw.text(((W - (bb[2] - bb[0])) / 2, H - 140), "mirai_bank",
              font=brand_font, fill=(255, 255, 255, 200))
    return canvas.convert("RGB")


def slide_04_goals(goals_path: Path, timer_path: Path) -> Image.Image:
    """目標：2 端末で進捗バー強調 + 上見出し。"""
    canvas = vgrad((255, 237, 213), (254, 215, 170))  # orange-100 → orange-200
    draw = ImageDraw.Draw(canvas)

    draw_multiline(draw, "目標までの距離が、\n明確に。", W // 2, 200,
                   font(108, bold=True), (124, 45, 18))  # orange-900
    draw_multiline(draw, "短期・中期・長期で、進捗を可視化", W // 2, 470,
                   font(46), (88, 28, 8))

    # 左に goals 端末、右に timer 端末。ちょっと小さめにして並べる
    g = shot(goals_path, target_w=560)
    t = shot(timer_path, target_w=560)
    place_tilted(canvas, g, cx=390, cy=1720, tilt=-7.0, shadow_blur=60, shadow_opacity=160)
    place_tilted(canvas, t, cx=900, cy=1850, tilt=5.0, shadow_blur=60, shadow_opacity=160)

    # 中央下にピル「70% 達成」みたいな抜き出し
    draw_pill(draw, "短期目標 70% 達成中", W // 2, 2440,
              font(46, bold=True), bg=(255, 255, 255), fg=(124, 45, 18))
    return canvas.convert("RGB")


def slide_05_categories(cat_path: Path) -> Image.Image:
    """カテゴリ：中央に端末、周囲にフローティングのカテゴリアイコン円。"""
    canvas = vgrad((237, 233, 254), (221, 214, 254))  # violet-100 → violet-200
    draw = ImageDraw.Draw(canvas)

    draw_multiline(draw, "学びの種類、\nまるごと網羅。", W // 2, 200,
                   font(108, bold=True), (76, 29, 149))  # violet-800
    draw_multiline(draw, "14 大カテゴリ × 65 のプリセット", W // 2, 470,
                   font(46), (88, 28, 135))

    # 中央に端末。垂直
    s = shot(cat_path, target_w=720)
    place_tilted(canvas, s, cx=W // 2, cy=1700, tilt=0,
                 shadow_blur=80, shadow_opacity=180)

    # 周囲にカテゴリ色のドット（既存ブランドのアクセント色を使う）
    accents = [
        (170, 1100, 56, (14, 165, 233)),   # sky-500
        (1070, 1180, 48, (45, 164, 78)),   # green
        (140, 1620, 42, (217, 70, 89)),    # red-ish
        (1100, 1700, 64, (245, 158, 11)),  # amber
        (200, 2240, 50, (147, 51, 234)),   # violet
        (1040, 2280, 36, (14, 116, 144)),  # cyan
    ]
    for cx, cy, r, col in accents:
        draw_floating_dot(canvas, cx, cy, r, col, 200)
    return canvas.convert("RGB")


def slide_06_closing(home_path: Path) -> Image.Image:
    """クロージング：タグライン + ブランド + 「今すぐ始めよう」CTA + 1 端末小さく。"""
    canvas = vgrad((14, 165, 233), (3, 105, 161))  # sky-500 → sky-700
    draw = ImageDraw.Draw(canvas)

    # 大型タグライン
    draw_multiline(draw, "未来の自分への、\n小さな投資から。", W // 2, 380,
                   font(116, bold=True), WHITE)

    # サブテキスト
    draw_multiline(draw, "今日の 5 分が、半年後の景色を変える。",
                   W // 2, 730, font(50), (224, 242, 254))

    # 端末を中央下に小さめに
    s = shot(home_path, target_w=560)
    place_tilted(canvas, s, cx=W // 2, cy=1820, tilt=2.0,
                 shadow_blur=80, shadow_opacity=200)

    # CTA バッジ
    cta_font = font(56, bold=True)
    draw_pill(draw, "App Store にて配信予定", W // 2, 2480,
              font(46, bold=True), bg=(15, 23, 42), fg=WHITE, padding=(40, 20))
    return canvas.convert("RGB")


# ---------- メイン ----------

SLIDES_CFG = [
    ("01_hero",            slide_01_hero,       ["01_home.png", "06_timer_running.png"]),
    ("02_calendar",        slide_02_calendar,   ["02_calendar.png"]),
    ("03_stats",           slide_03_stats,      ["03_statistics.png"]),
    ("04_goals",           slide_04_goals,      ["04_goals.png", "06_timer_running.png"]),
    ("05_categories",      slide_05_categories, ["05_categories.png"]),
    ("06_closing",         slide_06_closing,    ["01_home.png"]),
]


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

    for name, fn, inputs in SLIDES_CFG:
        paths = [src / p for p in inputs]
        for p in paths:
            if not p.exists():
                raise FileNotFoundError(p)
        slide = fn(*paths)
        full_path = full_out / f"{name}.png"
        web_path = web_out / f"{name}.png"
        slide.save(full_path, "PNG", optimize=True)
        make_web_version(slide).save(web_path, "PNG", optimize=True)
        print(f"  -> {full_path.relative_to(ROOT)} + {web_path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
