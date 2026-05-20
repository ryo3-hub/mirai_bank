#!/usr/bin/env python3
"""Generate splash screen logos for mirai_bank.

Design concept:
  Three ascending rounded bars representing accumulated value over time,
  topped with a yen (¥) symbol above the tallest bar. Communicates the
  core app concept of "time invested → future money".

Outputs:
  assets/splash/logo.png       — indigo on transparent (for white BG)
  assets/splash/logo_dark.png  — white on transparent (for dark indigo BG)

Both are 1024x1024 PNG with transparent background. flutter_native_splash
resamples them for each native target. Re-run this script whenever the
logo design changes, then run `dart run flutter_native_splash:create`.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

CANVAS = 1024
OUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "splash"

# Logo geometry (in canvas pixels).
BAR_WIDTH = 150
BAR_GAP = 44
BAR_RADIUS = 38
BAR_HEIGHTS = (260, 420, 560)  # short, medium, tall
BASELINE_OFFSET_FROM_BOTTOM = 160  # bars sit on this baseline
YEN_TOP_PADDING = 80  # ¥ glyph top edge from canvas top
YEN_FONT_SIZE = 240

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


def draw_logo(out_path: Path, rgb: tuple[int, int, int]) -> None:
    img = Image.new("RGBA", (CANVAS, CANVAS), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    total_width = 3 * BAR_WIDTH + 2 * BAR_GAP
    start_x = (CANVAS - total_width) // 2
    baseline_y = CANVAS - BASELINE_OFFSET_FROM_BOTTOM
    fill = rgb + (255,)

    # Three ascending bars.
    for i, h in enumerate(BAR_HEIGHTS):
        x = start_x + i * (BAR_WIDTH + BAR_GAP)
        y_top = baseline_y - h
        draw.rounded_rectangle(
            ((x, y_top), (x + BAR_WIDTH, baseline_y)),
            radius=BAR_RADIUS,
            fill=fill,
        )

    # ¥ centered horizontally above the bar group. Use "mt" (middle-top)
    # anchor so the glyph's top edge sits exactly at YEN_TOP_PADDING.
    font = load_font(YEN_FONT_SIZE)
    draw.text(
        (CANVAS // 2, YEN_TOP_PADDING),
        "¥",
        font=font,
        fill=fill,
        anchor="mt",
    )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    img.save(out_path)
    print(f"  -> {out_path.relative_to(out_path.parent.parent.parent)}")


def main() -> None:
    print("Generating splash logos...")
    # Light mode: indigo (#4F46E5) on transparent — visible on white BG.
    draw_logo(OUT_DIR / "logo.png", (79, 70, 229))
    # Dark mode: white on transparent — visible on indigo BG.
    draw_logo(OUT_DIR / "logo_dark.png", (255, 255, 255))
    print("Done.")


if __name__ == "__main__":
    main()
