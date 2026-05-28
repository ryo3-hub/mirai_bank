#!/usr/bin/env python3
"""Generate splash logos and app icons for mirai_bank from brand images.

Sources of truth:
  assets/source/brand_icon.png    — square MIRAI BANK brand artwork
                                    (rounded-square design with a white
                                    outer ring).
  assets/source/brand_splash.png  — portrait splash artwork (full-bleed,
                                    no rounded corners).

The icon source has rounded internal corners that, when combined with the
OS-level corner mask (iOS auto-rounds, Android adaptive icons are masked
by the launcher), used to leave a visible white ring at the icon edges.
We solve that by **cropping to the inscribed square** inside the
rounded-square design (issue #167 follow-up) before writing the icon
outputs — diagonally scanning from each corner gives us the rounded-corner
extent, from which we derive the safe inner margin.

Outputs (all 1024×1024 unless noted; splash variants keep portrait aspect):
  Splash (from brand_splash.png, RGBA):
    assets/splash/logo.png       — light splash logo
    assets/splash/logo_dark.png  — dark splash logo (same artwork)

  App icon (from brand_icon.png, inscribed-square cropped):
    assets/icon/icon.png             — opaque RGB, full-bleed brand design
    assets/icon/icon_foreground.png  — Android adaptive foreground
    assets/icon/icon_background.png  — Android adaptive background (white)

Re-run after changing source images:
  python3 tool/generate_logo.py
  dart run flutter_native_splash:create
  dart run flutter_launcher_icons
"""

from pathlib import Path

import numpy as np
from PIL import Image

CANVAS = 1024
SPLASH_LONG_EDGE = 2048  # native splash artwork is portrait; this caps
                         # the long edge to keep flutter_native_splash happy
ROOT = Path(__file__).resolve().parent.parent
ICON_SOURCE = ROOT / "assets" / "source" / "brand_icon.png"
SPLASH_SOURCE = ROOT / "assets" / "source" / "brand_splash.png"
SPLASH_DIR = ROOT / "assets" / "splash"
ICON_DIR = ROOT / "assets" / "icon"


def _load(path: Path) -> Image.Image:
    if not path.exists():
        raise FileNotFoundError(
            f"Brand source image not found at {path.relative_to(ROOT)}"
        )
    img = Image.open(path)
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    return img


def _inscribed_square_crop(src: Image.Image, threshold: int = 240) -> Image.Image:
    """Crop the largest axis-aligned square that fits entirely inside the
    rounded-square design (i.e., no white ring at the edges).

    Approach: scan diagonally from each image corner toward the center;
    the first non-white pixel marks where the rounded curve begins. For
    a quarter-circle of radius r, the curve intersects the diagonal at
    distance r·(1 - 1/√2) ≈ 0.293r from the outer corner (along each
    axis), so the diagonal step count `i` directly equals the safe inset
    distance — cropping by `i + safety` pixels from each side places the
    cropped corners inside the curve.

    Returns the cropped image (centered around the design center).
    """
    arr = np.array(src.convert("RGB"))
    h, w = arr.shape[:2]

    def diag(cx: int, cy: int, dx: int, dy: int, steps: int = 500) -> int:
        for i in range(steps):
            x, y = cx + dx * i, cy + dy * i
            if 0 <= x < w and 0 <= y < h:
                if (arr[y, x] < threshold).any():
                    return i
        return 0

    insets = (
        diag(0, 0, 1, 1),
        diag(w - 1, 0, -1, 1),
        diag(0, h - 1, 1, -1),
        diag(w - 1, h - 1, -1, -1),
    )
    inset = max(insets) + 4  # small safety buffer so corners land inside curve

    # Take a centered square crop so the design stays centered if the
    # source image isn't perfectly square.
    side = min(w, h) - 2 * inset
    cx, cy = w // 2, h // 2
    half = side // 2
    return src.crop((cx - half, cy - half, cx + half, cy + half))


def _save_rgba(img: Image.Image, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    print(f"  -> {out.relative_to(ROOT)}")


def _save_rgb(img: Image.Image, out: Path, *, background: tuple = (255, 255, 255)) -> None:
    """Flatten any alpha onto a solid background and save as RGB (iOS-safe)."""
    if img.mode == "RGBA":
        flat = Image.new("RGB", img.size, background)
        flat.paste(img, mask=img.split()[3])
        img = flat
    elif img.mode != "RGB":
        img = img.convert("RGB")
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)
    print(f"  -> {out.relative_to(ROOT)}")


def _resize_keeping_aspect(src: Image.Image, long_edge: int) -> Image.Image:
    """Scale `src` so its longer side equals `long_edge`, preserving aspect."""
    w, h = src.size
    if max(w, h) == long_edge:
        return src
    scale = long_edge / max(w, h)
    return src.resize((int(round(w * scale)), int(round(h * scale))), Image.LANCZOS)


def main() -> None:
    # --- Splash: portrait full-bleed artwork --------------------------------
    print("Writing splash logos...")
    splash = _resize_keeping_aspect(_load(SPLASH_SOURCE), SPLASH_LONG_EDGE)
    _save_rgba(splash, SPLASH_DIR / "logo.png")
    # Dark variant is the same artwork; the splash BG is white in both modes
    # (color / color_dark in pubspec.yaml) for consistency with the brand
    # image's outer ring.
    _save_rgba(splash, SPLASH_DIR / "logo_dark.png")

    # --- Icon: inscribed-square crop + canvas resize -----------------------
    print("Writing app icons...")
    icon_src = _load(ICON_SOURCE)
    inscribed = _inscribed_square_crop(icon_src)
    canvas_sq = inscribed.resize((CANVAS, CANVAS), Image.LANCZOS)

    # iOS / legacy Android icon: opaque RGB. The full-bleed cropped design
    # has no white ring; OS-level corner masks (iOS / launcher) round it
    # cleanly.
    _save_rgb(canvas_sq, ICON_DIR / "icon.png")

    # Android adaptive foreground: same full-bleed design. flutter_launcher_icons
    # inset's it 16% at build time for the safe zone.
    _save_rgba(canvas_sq, ICON_DIR / "icon_foreground.png")

    # Adaptive background: a plain white square. The foreground is now
    # full-bleed so the background only shows where the launcher mask
    # crops outside the foreground extent — white keeps that area neutral.
    white_bg = Image.new("RGB", (CANVAS, CANVAS), (255, 255, 255))
    white_bg.save(ICON_DIR / "icon_background.png")
    print(f"  -> {(ICON_DIR / 'icon_background.png').relative_to(ROOT)}")

    print("Done.")


if __name__ == "__main__":
    main()
