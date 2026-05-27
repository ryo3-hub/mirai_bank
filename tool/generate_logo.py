#!/usr/bin/env python3
"""Generate splash logos and app icons for mirai_bank from a single
brand image.

Source of truth: `assets/source/brand_icon.png` — the official MIRAI BANK
brand artwork (rounded-square design on white background, sky→teal→green
gradient with a sprout, "MIRAI BANK" wordmark). Everything else is a
mechanical resize / format conversion of that single file.

Outputs (all 1024×1024 unless noted):
  Splash (RGBA, transparent corners not needed — source has white corners):
    assets/splash/logo.png       — used on the light splash background
    assets/splash/logo_dark.png  — same image; we keep both names so
                                   `flutter_native_splash` can keep its
                                   light/dark slots even though the
                                   artwork is identical

  App icon:
    assets/icon/icon.png             — opaque RGB (iOS requirement, also
                                       the legacy Android launcher icon)
    assets/icon/icon_foreground.png  — Android adaptive foreground
                                       (full design; the launcher's
                                       `<inset android:inset="16%">`
                                       handles the safe zone)
    assets/icon/icon_background.png  — Android adaptive background;
                                       solid white so the rounded-square
                                       artwork visually "floats" the same
                                       way on every launcher mask

Re-run after changing the source image:
  python3 tool/generate_logo.py
  dart run flutter_native_splash:create
  dart run flutter_launcher_icons
"""

from pathlib import Path

import numpy as np
from PIL import Image

CANVAS = 1024
ROOT = Path(__file__).resolve().parent.parent
SOURCE_PATH = ROOT / "assets" / "source" / "brand_icon.png"
SPLASH_DIR = ROOT / "assets" / "splash"
ICON_DIR = ROOT / "assets" / "icon"


def _load_source() -> Image.Image:
    if not SOURCE_PATH.exists():
        raise FileNotFoundError(
            f"Brand source image not found at {SOURCE_PATH.relative_to(ROOT)}"
        )
    img = Image.open(SOURCE_PATH)
    # Normalize to RGBA so callers can decide whether to flatten or not.
    if img.mode != "RGBA":
        img = img.convert("RGBA")
    return img


def _resize_to_canvas(src: Image.Image) -> Image.Image:
    """High-quality resize the source down/up to CANVAS×CANVAS."""
    if src.size == (CANVAS, CANVAS):
        return src
    return src.resize((CANVAS, CANVAS), Image.LANCZOS)


def _crop_white_margin(src: Image.Image, threshold: int = 240) -> Image.Image:
    """Tightly crop away the near-white outer margin of the brand image.

    The brand artwork sits centered with a small (~2%) white border. The
    Android adaptive foreground gets an additional 16% inset applied by
    `flutter_launcher_icons` at build time, so leaving the source margin
    in place would shrink the visible design twice. Cropping here ensures
    the rounded-square design fills the foreground canvas.
    """
    arr = np.array(src.convert("RGB"))
    mask = (arr < threshold).any(axis=-1)
    ys, xs = np.where(mask)
    if len(xs) == 0:
        return src
    left, right = int(xs.min()), int(xs.max())
    top, bottom = int(ys.min()), int(ys.max())
    return src.crop((left, top, right + 1, bottom + 1))


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


def main() -> None:
    src = _resize_to_canvas(_load_source())

    print("Writing splash logos...")
    _save_rgba(src, SPLASH_DIR / "logo.png")
    # Dark variant is the same image; the splash BG is white in both modes
    # so the rounded-square design is seamless on the white outer ring.
    _save_rgba(src, SPLASH_DIR / "logo_dark.png")

    print("Writing app icons...")
    # icon.png must be opaque (iOS). Flatten onto white to match the
    # source artwork's outer ring.
    _save_rgb(src, ICON_DIR / "icon.png")

    # Adaptive foreground: tightly crop the source's ~2% white margin and
    # resize to fill the canvas. flutter_launcher_icons will then inset
    # this by 16% at build time — without the crop, the design ends up
    # twice-shrunk (~56% of launcher canvas) and looks small next to the
    # OS-default icons.
    cropped = _crop_white_margin(_load_source())
    full_bleed = cropped.resize((CANVAS, CANVAS), Image.LANCZOS)
    _save_rgba(full_bleed, ICON_DIR / "icon_foreground.png")

    # Adaptive background: a plain white square, matching the outer ring
    # of the source artwork so any cropping by the launcher shape blends
    # seamlessly.
    white_bg = Image.new("RGB", (CANVAS, CANVAS), (255, 255, 255))
    white_bg.save(ICON_DIR / "icon_background.png")
    print(f"  -> {(ICON_DIR / 'icon_background.png').relative_to(ROOT)}")

    print("Done.")


if __name__ == "__main__":
    main()
