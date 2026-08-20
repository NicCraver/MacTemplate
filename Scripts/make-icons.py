#!/usr/bin/env python3
"""Build AppIcon.appiconset and a template StatusBarIcon from generated brand PNGs."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = Path(
    "/Users/nic/.cursor/projects/Users-nic-NicProjects-Workspace-MacWorkspace-MacTemplate/assets"
)
BRAND = ROOT / "Resources" / "Brand"
APPICON = ROOT / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"
STATUS = ROOT / "Resources" / "Assets.xcassets" / "StatusBarIcon.imageset"

MAC_SIZES = [
    (16, "icon_16x16.png"),
    (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),
    (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),
    (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),
    (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),
    (1024, "icon_512x512@2x.png"),
]


def copy_brand() -> tuple[Path, Path]:
    BRAND.mkdir(parents=True, exist_ok=True)
    src_app = ASSETS / "app-icon.png"
    src_bar = ASSETS / "statusbar-icon.png"
    dst_app = BRAND / "app-icon.png"
    dst_bar = BRAND / "statusbar-source.png"
    Image.open(src_app).convert("RGB").save(dst_app)
    Image.open(src_bar).convert("RGB").save(dst_bar)
    return dst_app, dst_bar


def write_appicon(src: Path) -> None:
    APPICON.mkdir(parents=True, exist_ok=True)
    image = Image.open(src).convert("RGB")
    for size, name in MAC_SIZES:
        resized = image.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(APPICON / name, "PNG")
    (APPICON / "Contents.json").write_text(
        json.dumps(
            {
                "images": [
                    {"size": "16x16", "idiom": "mac", "filename": "icon_16x16.png", "scale": "1x"},
                    {"size": "16x16", "idiom": "mac", "filename": "icon_16x16@2x.png", "scale": "2x"},
                    {"size": "32x32", "idiom": "mac", "filename": "icon_32x32.png", "scale": "1x"},
                    {"size": "32x32", "idiom": "mac", "filename": "icon_32x32@2x.png", "scale": "2x"},
                    {"size": "128x128", "idiom": "mac", "filename": "icon_128x128.png", "scale": "1x"},
                    {"size": "128x128", "idiom": "mac", "filename": "icon_128x128@2x.png", "scale": "2x"},
                    {"size": "256x256", "idiom": "mac", "filename": "icon_256x256.png", "scale": "1x"},
                    {"size": "256x256", "idiom": "mac", "filename": "icon_256x256@2x.png", "scale": "2x"},
                    {"size": "512x512", "idiom": "mac", "filename": "icon_512x512.png", "scale": "1x"},
                    {"size": "512x512", "idiom": "mac", "filename": "icon_512x512@2x.png", "scale": "2x"},
                ],
                "info": {"version": 1, "author": "xcode"},
            },
            indent=2,
        )
        + "\n"
    )


def template_from_source(src: Path) -> Image.Image:
    rgb = Image.open(src).convert("RGB")
    gray = rgb.convert("L")
    alpha = gray.point(lambda p: 0 if p > 210 else 255)
    black = Image.new("L", rgb.size, 0)
    out = Image.merge("RGBA", (black, black, black, alpha))
    bbox = out.getbbox()
    if bbox is None:
        return out
    cropped = out.crop(bbox)
    side = int(max(cropped.size) * 1.35)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    ox = (side - cropped.size[0]) // 2
    oy = (side - cropped.size[1]) // 2
    canvas.paste(cropped, (ox, oy), cropped)
    return canvas


def write_statusbar(src: Path) -> None:
    STATUS.mkdir(parents=True, exist_ok=True)
    glyph = template_from_source(src)
    for size, name in ((18, "StatusBarIcon.png"), (36, "StatusBarIcon@2x.png")):
        glyph.resize((size, size), Image.Resampling.LANCZOS).save(STATUS / name, "PNG")
    (STATUS / "Contents.json").write_text(
        json.dumps(
            {
                "images": [
                    {"filename": "StatusBarIcon.png", "idiom": "universal", "scale": "1x"},
                    {"filename": "StatusBarIcon@2x.png", "idiom": "universal", "scale": "2x"},
                ],
                "info": {"version": 1, "author": "xcode"},
                "properties": {"template-rendering-intent": "template"},
            },
            indent=2,
        )
        + "\n"
    )


def write_catalog_root() -> None:
    catalog = ROOT / "Resources" / "Assets.xcassets"
    catalog.mkdir(parents=True, exist_ok=True)
    (catalog / "Contents.json").write_text(
        json.dumps({"info": {"version": 1, "author": "xcode"}}, indent=2) + "\n"
    )


def main() -> None:
    app_src, bar_src = copy_brand()
    write_catalog_root()
    write_appicon(app_src)
    write_statusbar(bar_src)
    print(f"Wrote {APPICON}")
    print(f"Wrote {STATUS}")


if __name__ == "__main__":
    main()
