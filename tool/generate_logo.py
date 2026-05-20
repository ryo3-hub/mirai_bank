#!/usr/bin/env python3
"""Generate splash logos and app icons for mirai_bank.

Design concept:
  Three ascending rounded bars representing accumulated value over time,
  topped with a yen (¥) symbol above the tallest bar. Communicates the
  core app concept of "time invested → future money".

Outputs:
  Splash (1024x1024, transparent background):
    assets/splash/logo.png       — indigo symbols (for white BG)
    assets/splash/logo_dark.png  — white symbols   (for dark indigo BG)

  App icon (1024x1024):
    assets/icon/icon.png             — solid indigo BG + white symbols (no alpha)
    assets/icon/icon_foreground.png  — white symbols on transparent
                                       (Android adaptive icon foreground;
                                        scaled smaller to fit inside the safe
                                        zone of the 108dp adaptive canvas)

Re-run this script after design changes, then regenerate native assets:
  python3 tool/generate_logo.py
  dart run flutter_native_splash:create
  dart run flutter_launcher_icons
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

CANVAS = 1024
ROOT = Path(__file__).resolve().parent.parent
SPLASH_DIR = ROOT / "assets" / "splash"
ICON_DIR = ROOT / "assets" / "icon"

INDIGO = (79, 70, 229)  # #4F46E5
WHITE = (255, 255, 255)

# Splash logo geometry (in canvas pixels). The splash sits on a full-screen
# canvas so it can use most of the 1024 region.
SPLASH_BAR_WIDTH = 150
SPLASH_BAR_GAP = 44
SPLASH_BAR_RADIUS = 38
SPLASH_BAR_HEIGHTS = (260, 420, 560)  # short, medium, tall
SPLASH_BASELINE_OFFSET = 160
SPLASH_YEN_TOP = 80
SPLASH_YEN_SIZE = 240

# App icon geometry: scaled down to fit within the iOS / Android safe zones.
# Foreground variant is scaled even smaller because Android's adaptive icon
# may crop ~33% of the foreground at the edges (108dp canvas, 66dp safe).
ICON_BAR_WIDTH = 110
ICON_BAR_GAP = 34
ICON_BAR_RADIUS = 28
ICON_BAR_HEIGHTS = (200, 320, 440)
ICON_BASELINE_OFFSET = 220
ICON_YEN_TOP = 200
ICON_YEN_SIZE = 200

ICON_FG_BAR_WIDTH = 90
ICON_FG_BAR_GAP = 28
ICON_FG_BAR_RADIUS = 22
ICON_FG_BAR_HEIGHTS = (160, 260, 360)
ICON_FG_BASELINE_OFFSET = 280
ICON_FG_YEN_TOP = 260
ICON_FG_YEN_SIZE = 160

# macOS bundled fonts (try in order).
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


def _draw_design(
    draw: ImageDraw.ImageDraw,
    fg_rgb: tuple[int, int, int],
    *,
    bar_width: int,
    bar_gap: int,
    bar_radius: int,
    bar_heights: tuple[int, int, int],
    baseline_offset: int,
    yen_top: int,
    yen_size: int,
) -> None:
    """Draw the bars + yen design centered horizontally."""
    total_width = 3 * bar_width + 2 * bar_gap
    start_x = (CANVAS - total_width) // 2
    baseline_y = CANVAS - baseline_offset
    fill = fg_rgb + (255,)

    for i, h in enumerate(bar_heights):
        x = start_x + i * (bar_width + bar_gap)
        y_top = baseline_y - h
        draw.rounded_rectangle(
            ((x, y_top), (x + bar_width, baseline_y)),
            radius=bar_radius,
            fill=fill,
        )

    font = load_font(yen_size)
    draw.text(
        (CANVAS // 2, yen_top),
        "¥",
        font=font,
        fill=fill,
        anchor="mt",
    )


def draw_splash_logo(out_path: Path, fg_rgb: tuple[int, int, int]) -> None:
    img = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    _draw_design(
        draw,
        fg_rgb,
        bar_width=SPLASH_BAR_WIDTH,
        bar_gap=SPLASH_BAR_GAP,
        bar_radius=SPLASH_BAR_RADIUS,
        bar_heights=SPLASH_BAR_HEIGHTS,
        baseline_offset=SPLASH_BASELINE_OFFSET,
        yen_top=SPLASH_YEN_TOP,
        yen_size=SPLASH_YEN_SIZE,
    )
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path)
    print(f"  -> {out_path.relative_to(ROOT)}")


def draw_app_icon(out_path: Path) -> None:
    """Solid Indigo background + white symbols. No alpha (iOS requirement)."""
    img = Image.new("RGB", (CANVAS, CANVAS), INDIGO)
    draw = ImageDraw.Draw(img)
    _draw_design(
        draw,
        WHITE,
        bar_width=ICON_BAR_WIDTH,
        bar_gap=ICON_BAR_GAP,
        bar_radius=ICON_BAR_RADIUS,
        bar_heights=ICON_BAR_HEIGHTS,
        baseline_offset=ICON_BASELINE_OFFSET,
        yen_top=ICON_YEN_TOP,
        yen_size=ICON_YEN_SIZE,
    )
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path)
    print(f"  -> {out_path.relative_to(ROOT)}")


def draw_adaptive_foreground(out_path: Path) -> None:
    """White symbols on transparent, scaled smaller to fit the adaptive
    icon's safe zone (Android 8.0+ adaptive icons may crop ~33% off the
    edges)."""
    img = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    _draw_design(
        draw,
        WHITE,
        bar_width=ICON_FG_BAR_WIDTH,
        bar_gap=ICON_FG_BAR_GAP,
        bar_radius=ICON_FG_BAR_RADIUS,
        bar_heights=ICON_FG_BAR_HEIGHTS,
        baseline_offset=ICON_FG_BASELINE_OFFSET,
        yen_top=ICON_FG_YEN_TOP,
        yen_size=ICON_FG_YEN_SIZE,
    )
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path)
    print(f"  -> {out_path.relative_to(ROOT)}")


def main() -> None:
    print("Generating splash logos...")
    draw_splash_logo(SPLASH_DIR / "logo.png", INDIGO)
    draw_splash_logo(SPLASH_DIR / "logo_dark.png", WHITE)
    print("Generating app icons...")
    draw_app_icon(ICON_DIR / "icon.png")
    draw_adaptive_foreground(ICON_DIR / "icon_foreground.png")
    print("Done.")


if __name__ == "__main__":
    main()
