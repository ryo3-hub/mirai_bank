#!/usr/bin/env python3
"""Generate splash logos and app icons for mirai_bank.

The script renders TWO different designs:

  • Splash (assets/splash/logo*.png) — a ¥ coin with a green sprout growing
    from it. "Today's self-investment grows into the future."

  • App icon (assets/icon/*.png) — an upward stock-chart inside a deep
    green frame: ascending gold bars + a white rising-curve arrow + a
    glowing trail of dots. The bars get more opaque as they climb,
    reinforcing growth/accumulation. (Source: rising_graph_icon_green_bg.svg
    from the design brief, re-implemented in PIL.)

Both designs share the brand themes — future / investment / growth /
continuity / money — but the icon uses a darker, more financial-looking
palette so it stands out in a launcher grid.

Re-run after design changes:
  python3 tool/generate_logo.py
  dart run flutter_native_splash:create
  dart run flutter_launcher_icons
"""

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

CANVAS = 1024
ROOT = Path(__file__).resolve().parent.parent
SPLASH_DIR = ROOT / "assets" / "splash"
ICON_DIR = ROOT / "assets" / "icon"


# ---------------------------------------------------------------------------
# Splash palette (matches app theme post issue #87).
# ---------------------------------------------------------------------------
SKY = (14, 165, 233)          # #0EA5E9  sky-500
SKY_DARK = (12, 74, 110)      # #0C4A6E  sky-900 (dark splash BG reference)
GREEN = (45, 164, 78)         # #2DA44E  GitHub Green (FAB / sprout)
GREEN_LIGHT = (74, 222, 128)  # #4ADE80  green-400 (sprout on dark BG)
WHITE = (255, 255, 255)


# ---------------------------------------------------------------------------
# Icon palette (from rising_graph_icon_green_bg.svg).
# Diagonal gradient #2d6a4f → #1b4332 for the BG; gold bars on top.
# ---------------------------------------------------------------------------
ICON_GREEN_TL = (45, 106, 79)   # #2d6a4f  top-left of BG gradient
ICON_GREEN_BR = (27, 67, 50)    # #1b4332  bottom-right of BG gradient
ICON_GOLD_TOP = (255, 214, 10)  # #ffd60a  top of bar gradient
ICON_GOLD_BOT = (224, 159, 0)   # #e09f00  bottom of bar gradient


# ---------------------------------------------------------------------------
# Splash logo geometry (coin + sprout). Three variants:
#   SPLASH — fills more of the 1024 canvas (no safe-zone constraint).
# ---------------------------------------------------------------------------

SPLASH_GEOM = dict(
    coin_diameter=520,
    coin_cy_offset=260,    # coin center y = CANVAS - coin_cy_offset
    yen_size=300,
    stem_width=36,
    stem_height=300,
    leaf_node_offset=24,   # distance below stem top where leaves attach
    leaf_length=300,
    leaf_width=130,
    leaf_angle_deg=32,
)


FONT_CANDIDATES = (
    "/System/Library/Fonts/HelveticaNeue.ttc",
    "/System/Library/Fonts/Helvetica.ttc",
    "/Library/Fonts/Arial.ttf",
    "/System/Library/Fonts/SFNS.ttf",
)


def load_font(size: int) -> ImageFont.FreeTypeFont:
    for path in FONT_CANDIDATES:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    raise RuntimeError(
        "No usable font found. Edit FONT_CANDIDATES in tool/generate_logo.py."
    )


# ===========================================================================
# Splash: coin + sprout
# ===========================================================================


def _make_leaf(length: int, width: int, color: tuple) -> Image.Image:
    """Build a horizontal leaf (almond shape) with the BASE at the center of
    the returned image and the TIP at (center_x + length, center_y).

    The image is square and large enough that rotating around its center
    pivots the leaf around its base.
    """
    pad = length * 2 + 40
    img = Image.new("RGBA", (pad, pad), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx = pad // 2
    cy = pad // 2

    n = 40
    fill = color + (255,)
    points = []
    for i in range(n + 1):
        t = i / n
        x = t * length
        h = (4 * t * (1 - t)) ** 0.65
        y = -(width / 2) * h
        points.append((cx + x, cy + y))
    for i in range(n + 1):
        t = i / n
        x = (1 - t) * length
        h = (4 * (1 - t) * t) ** 0.65
        y = (width / 2) * h
        points.append((cx + x, cy + y))

    draw.polygon(points, fill=fill)
    return img


def _paste_rotated(
    canvas: Image.Image,
    src: Image.Image,
    cx: int,
    cy: int,
    angle_deg: float,
) -> None:
    rot = src.rotate(angle_deg, resample=Image.BICUBIC, expand=True)
    rw, rh = rot.size
    canvas.alpha_composite(rot, (int(cx - rw / 2), int(cy - rh / 2)))


def _draw_coin_sprout(
    canvas: Image.Image,
    *,
    coin_color: tuple,
    yen_color: tuple,
    stem_color: tuple,
    leaf_color: tuple,
    geom: dict,
) -> None:
    draw = ImageDraw.Draw(canvas)
    coin_cx = CANVAS // 2
    coin_cy = CANVAS - geom["coin_cy_offset"]
    coin_r = geom["coin_diameter"] // 2

    stem_half = geom["stem_width"] // 2
    stem_top_y = coin_cy - coin_r - geom["stem_height"]
    stem_bottom_y = coin_cy

    leaf_node_y = stem_top_y + geom["leaf_node_offset"]

    leaf = _make_leaf(geom["leaf_length"], geom["leaf_width"], leaf_color)
    _paste_rotated(canvas, leaf, coin_cx, leaf_node_y, geom["leaf_angle_deg"])
    _paste_rotated(canvas, leaf, coin_cx, leaf_node_y, 180 - geom["leaf_angle_deg"])

    draw.rounded_rectangle(
        (coin_cx - stem_half, stem_top_y, coin_cx + stem_half, stem_bottom_y),
        radius=stem_half,
        fill=stem_color + (255,),
    )

    draw.ellipse(
        (coin_cx - coin_r, coin_cy - coin_r, coin_cx + coin_r, coin_cy + coin_r),
        fill=coin_color + (255,),
    )

    font = load_font(geom["yen_size"])
    draw.text(
        (coin_cx, coin_cy),
        "¥",
        font=font,
        fill=yen_color + (255,),
        anchor="mm",
    )


def draw_splash_logo(
    out_path: Path,
    *,
    coin_color: tuple,
    yen_color: tuple,
    stem_color: tuple,
    leaf_color: tuple,
) -> None:
    img = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    _draw_coin_sprout(
        img,
        coin_color=coin_color,
        yen_color=yen_color,
        stem_color=stem_color,
        leaf_color=leaf_color,
        geom=SPLASH_GEOM,
    )
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path)
    print(f"  -> {out_path.relative_to(ROOT)}")


# ===========================================================================
# App icon: rising bar chart + curve arrow
#
# Coordinate system: everything is authored in the SVG's 240×240 icon-box
# local frame, and we render it onto a canvas of `area_size` pixels placed
# at (area_x, area_y) inside the 1024 canvas. Scale factor = area_size/240.
# ===========================================================================


ICON_BARS = [
    # (x, y, w, h, opacity) in SVG 240-unit space.
    (32, 160, 22, 50, 0.40),
    (64, 135, 22, 75, 0.55),
    (96, 105, 22, 105, 0.70),
    (128, 75, 22, 135, 0.85),
    (160, 40, 22, 170, 1.00),
]
ICON_BAR_RADIUS = 4  # SVG units

# Arrow: quadratic Bezier from start, through control, to end; then a
# straight tail line to the head root.
ICON_CURVE_START = (35, 170)
ICON_CURVE_CONTROL = (90, 140)
ICON_CURVE_END = (140, 90)
ICON_LINE_END = (185, 45)
# Arrow-head corner stroke (M ... L ... L ...): top-right corner.
ICON_ARROW_HEAD = [(170, 35), (195, 35), (195, 60)]
ICON_ARROW_STROKE = 3.5  # SVG units

# Trail dots along the arrow path.
ICON_TRAIL_DOTS = [
    (43, 165, 3, "white", 0.75),
    (75, 140, 3, "white", 0.75),
    (107, 110, 3, "white", 0.85),
    (139, 80, 3, "white", 0.95),
    (171, 45, 4, "gold", 1.00),
]

# Decorative circles (very low opacity, partly outside the icon box).
ICON_DECOR_CIRCLES = [
    (200, 40, 80, "white", 0.06),
    (40, 200, 60, "gold", 0.08),
]

# Faint grid: 3 horizontal + 3 vertical white lines at 12% opacity.
ICON_GRID_H = [60, 120, 180]
ICON_GRID_V = [60, 120, 180]
ICON_GRID_STROKE = 0.5   # SVG units
ICON_GRID_OPACITY = 0.12


def _diagonal_gradient_rgb(size: int, c_tl: tuple, c_br: tuple) -> Image.Image:
    """RGB image filled with a TL→BR linear gradient between two colors."""
    if size <= 0:
        raise ValueError("size must be positive")
    ys, xs = np.indices((size, size), dtype=np.float32)
    t = (xs + ys) / (2 * max(size - 1, 1))
    r = (c_tl[0] * (1 - t) + c_br[0] * t).astype(np.uint8)
    g = (c_tl[1] * (1 - t) + c_br[1] * t).astype(np.uint8)
    b = (c_tl[2] * (1 - t) + c_br[2] * t).astype(np.uint8)
    rgb = np.stack([r, g, b], axis=-1)
    return Image.fromarray(rgb, mode="RGB")


def _vertical_gradient_bar(
    w: int, h: int, c_top: tuple, c_bot: tuple, radius: int, opacity: float
) -> Image.Image:
    """Rounded-corner bar with a vertical color gradient and a flat alpha."""
    w = max(w, 1)
    h = max(h, 1)
    ys = np.arange(h, dtype=np.float32).reshape(h, 1) / max(h - 1, 1)
    r = (c_top[0] * (1 - ys) + c_bot[0] * ys).astype(np.uint8)
    g = (c_top[1] * (1 - ys) + c_bot[1] * ys).astype(np.uint8)
    b = (c_top[2] * (1 - ys) + c_bot[2] * ys).astype(np.uint8)
    rgb_col = np.concatenate([r, g, b], axis=1).reshape(h, 1, 3)
    rgb = np.broadcast_to(rgb_col, (h, w, 3)).copy()
    grad_rgb = Image.fromarray(rgb, mode="RGB")
    alpha = Image.new("L", (w, h), 0)
    ImageDraw.Draw(alpha).rounded_rectangle(
        (0, 0, w - 1, h - 1), radius=max(radius, 0), fill=int(round(255 * opacity))
    )
    out = grad_rgb.convert("RGBA")
    out.putalpha(alpha)
    return out


def _quadratic_bezier(p0, p1, p2, n: int = 120):
    pts = []
    for i in range(n):
        t = i / (n - 1)
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1]
        pts.append((x, y))
    return pts


def _alpha_dot(canvas: Image.Image, cx: float, cy: float, r: float, color: tuple, opacity: float) -> None:
    """Alpha-blend a filled disc onto an RGBA canvas."""
    r = max(r, 0.5)
    pad = int(r * 2) + 4
    tile = Image.new("RGBA", (pad, pad), (0, 0, 0, 0))
    ImageDraw.Draw(tile).ellipse(
        (pad / 2 - r, pad / 2 - r, pad / 2 + r, pad / 2 + r),
        fill=color + (int(round(255 * opacity)),),
    )
    canvas.alpha_composite(tile, (int(round(cx - pad / 2)), int(round(cy - pad / 2))))


def _stroke_polyline(
    canvas: Image.Image, points, width: int, color: tuple, opacity: float
) -> None:
    """Stroke a polyline with round caps (drawn via discs at every vertex)."""
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    fill = color + (int(round(255 * opacity)),)
    od.line(points, fill=fill, width=width, joint="curve")
    canvas.alpha_composite(overlay)
    # Round caps and joints: drop a filled disc at every vertex.
    r = width / 2
    for x, y in points:
        _alpha_dot(canvas, x, y, r, color, opacity)


def _draw_rising_chart(
    canvas: Image.Image,
    area_x: int,
    area_y: int,
    area_size: int,
    *,
    draw_background: bool,
    draw_decor: bool,
    draw_grid: bool,
    draw_bars: bool,
    draw_arrow: bool,
    draw_dots: bool,
) -> None:
    """Render selected layers of the rising-chart design into the given area.

    All content is authored in 240-unit SVG-local coordinates and scaled by
    area_size/240. Layers are alpha-composited in z-order:
      background → decor → grid → bars → arrow → dots
    """
    s = area_size / 240
    color_map = {"white": WHITE, "gold": ICON_GOLD_TOP}

    if draw_background:
        bg = _diagonal_gradient_rgb(area_size, ICON_GREEN_TL, ICON_GREEN_BR)
        canvas.paste(bg, (area_x, area_y))

    # Build all overlay layers in a stage image (transparent), then composite
    # onto the canvas. The stage acts as a clip-path: anything drawn outside
    # area_size×area_size is naturally cropped (mimicking the SVG clipPath).
    if any((draw_decor, draw_grid, draw_bars, draw_arrow, draw_dots)):
        stage = Image.new("RGBA", (area_size, area_size), (0, 0, 0, 0))
        stage_draw = ImageDraw.Draw(stage)

        if draw_decor:
            for cx, cy, r, name, op in ICON_DECOR_CIRCLES:
                _alpha_dot(stage, cx * s, cy * s, r * s, color_map[name], op)

        if draw_grid:
            grid_fill = WHITE + (int(round(255 * ICON_GRID_OPACITY)),)
            gw = max(1, int(round(ICON_GRID_STROKE * s)))
            for y in ICON_GRID_H:
                stage_draw.line(
                    [(0, y * s), (240 * s, y * s)], fill=grid_fill, width=gw
                )
            for x in ICON_GRID_V:
                stage_draw.line(
                    [(x * s, 0), (x * s, 240 * s)], fill=grid_fill, width=gw
                )

        if draw_bars:
            for bx, by, bw, bh, op in ICON_BARS:
                bar = _vertical_gradient_bar(
                    int(round(bw * s)),
                    int(round(bh * s)),
                    ICON_GOLD_TOP,
                    ICON_GOLD_BOT,
                    radius=max(1, int(round(ICON_BAR_RADIUS * s))),
                    opacity=op,
                )
                stage.alpha_composite(bar, (int(round(bx * s)), int(round(by * s))))

        if draw_arrow:
            stroke_w = max(2, int(round(ICON_ARROW_STROKE * s)))
            curve = _quadratic_bezier(
                (ICON_CURVE_START[0] * s, ICON_CURVE_START[1] * s),
                (ICON_CURVE_CONTROL[0] * s, ICON_CURVE_CONTROL[1] * s),
                (ICON_CURVE_END[0] * s, ICON_CURVE_END[1] * s),
            )
            curve.append((ICON_LINE_END[0] * s, ICON_LINE_END[1] * s))
            _stroke_polyline(stage, curve, stroke_w, WHITE, 1.0)
            head = [(p[0] * s, p[1] * s) for p in ICON_ARROW_HEAD]
            _stroke_polyline(stage, head, stroke_w, WHITE, 1.0)

        if draw_dots:
            for cx, cy, r, name, op in ICON_TRAIL_DOTS:
                _alpha_dot(stage, cx * s, cy * s, r * s, color_map[name], op)

        canvas.alpha_composite(stage, (area_x, area_y))


def draw_app_icon(out_path: Path) -> None:
    """iOS app icon — full 1024 RGB with every layer of the rising chart.

    Saved as RGB (no alpha) for iOS compatibility; iOS applies its own
    rounded-corner mask automatically.
    """
    img = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    _draw_rising_chart(
        img,
        area_x=0,
        area_y=0,
        area_size=CANVAS,
        draw_background=True,
        draw_decor=True,
        draw_grid=True,
        draw_bars=True,
        draw_arrow=True,
        draw_dots=True,
    )
    img.convert("RGB").save(out_path)
    print(f"  -> {out_path.relative_to(ROOT)}")


def draw_adaptive_background(out_path: Path) -> None:
    """Android adaptive icon background — just the green gradient, full
    canvas. The decorative circles and grid live in the foreground so they
    stay aligned with the bars regardless of how the launcher masks the
    background shape."""
    img = Image.new("RGB", (CANVAS, CANVAS))
    img.paste(_diagonal_gradient_rgb(CANVAS, ICON_GREEN_TL, ICON_GREEN_BR))
    img.save(out_path)
    print(f"  -> {out_path.relative_to(ROOT)}")


def draw_adaptive_foreground(out_path: Path) -> None:
    """Android adaptive icon foreground — decor + grid + bars + arrow + dots
    on transparent BG, drawn at full 1024 canvas scale.

    `flutter_launcher_icons` wraps this drawable in `<inset android:inset="16%">`
    at build time, which already shrinks the foreground into the adaptive
    safe zone. Adding another inset here would double-count and make the
    chart look tiny next to the background gradient.
    """
    img = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    _draw_rising_chart(
        img,
        area_x=0,
        area_y=0,
        area_size=CANVAS,
        draw_background=False,
        draw_decor=True,
        draw_grid=True,
        draw_bars=True,
        draw_arrow=True,
        draw_dots=True,
    )
    img.save(out_path)
    print(f"  -> {out_path.relative_to(ROOT)}")


# ===========================================================================
# Entry point
# ===========================================================================


def main() -> None:
    print("Generating splash logos (coin + sprout)...")
    draw_splash_logo(
        SPLASH_DIR / "logo.png",
        coin_color=SKY,
        yen_color=WHITE,
        stem_color=GREEN,
        leaf_color=GREEN,
    )
    draw_splash_logo(
        SPLASH_DIR / "logo_dark.png",
        coin_color=WHITE,
        yen_color=SKY_DARK,
        stem_color=GREEN_LIGHT,
        leaf_color=GREEN_LIGHT,
    )
    print("Generating app icons (rising chart)...")
    draw_app_icon(ICON_DIR / "icon.png")
    draw_adaptive_background(ICON_DIR / "icon_background.png")
    draw_adaptive_foreground(ICON_DIR / "icon_foreground.png")
    print("Done.")


if __name__ == "__main__":
    main()
