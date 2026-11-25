"""Asset processing pipeline for Windbreath Village.
1. Copies raw Nanobanana art sheets from staging/artifacts (if present) into assets/art/raw/.
2. Slices 3x2 / 2x2 sheets cleanly and applies border-connected flood-fill alpha matting
   with edge decontamination so white clothing/egrets stay opaque while white backgrounds
   become crisp transparent RGBA sprites.
3. Generates supersampled flat-top hexagonal tile base textures & glow particles.
"""

from __future__ import annotations

import math
import shutil
from collections import deque
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = ROOT / "assets" / "art" / "raw"
ART_DIR = ROOT / "assets" / "art"

ARTIFACT_BRAIN_FALLBACK = Path(
    r"C:\Users\12405\.gemini\antigravity\brain\9da98ab7-22cb-4fdf-94a2-0dc2a29f8a21"
)

RAW_SOURCES = {
    "menu_bg.jpg": "menu_bg_1795598219350.jpg",
    "app_icon_raw.jpg": "app_icon_raw_1795598233858.jpg",
    "sheet_terrain.jpg": "sheet_terrain_v2_1795598202321.jpg",
    "sheet_landmarks.jpg": "sheet_landmarks_1795598164435.jpg",
    "sheet_characters.jpg": "sheet_characters_clean_1795598185455.jpg",
    "sheet_ui_icons.jpg": "sheet_ui_icons_1795598175274.jpg",
    "sheet_postcards.jpg": "sheet_postcards_1795598194064.jpg",
}


def sync_raw_sources() -> None:
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    for dst_name, src_name in RAW_SOURCES.items():
        dst = RAW_DIR / dst_name
        if not dst.exists() and (ARTIFACT_BRAIN_FALLBACK / src_name).exists():
            shutil.copy2(ARTIFACT_BRAIN_FALLBACK / src_name, dst)


def remove_white_bg(cell: Image.Image, target_size: int = 256, remove_inner_holes: bool = True) -> Image.Image:
    rgba = cell.convert("RGBA")
    arr = np.array(rgba, dtype=np.uint8)
    h, w, _ = arr.shape
    rgb = arr[:, :, :3].astype(np.int16)
    mn = rgb.min(axis=2)
    mx = rgb.max(axis=2)
    sat = mx - mn

    # Background candidate: bright neutral near-white
    is_bg_cand = (mn >= 228) & (sat <= 22)
    bg_mask = np.zeros((h, w), dtype=bool)
    q: deque[tuple[int, int]] = deque()

    for x in range(w):
        if is_bg_cand[0, x]:
            bg_mask[0, x] = True
            q.append((0, x))
        if is_bg_cand[h - 1, x] and not bg_mask[h - 1, x]:
            bg_mask[h - 1, x] = True
            q.append((h - 1, x))
    for y in range(h):
        if is_bg_cand[y, 0] and not bg_mask[y, 0]:
            bg_mask[y, 0] = True
            q.append((y, 0))
        if is_bg_cand[y, w - 1] and not bg_mask[y, w - 1]:
            bg_mask[y, w - 1] = True
            q.append((y, w - 1))

    while q:
        cy, cx = q.popleft()
        for ny, nx in ((cy - 1, cx), (cy + 1, cx), (cy, cx - 1), (cy, cx + 1)):
            if 0 <= ny < h and 0 <= nx < w and not bg_mask[ny, nx] and is_bg_cand[ny, nx]:
                bg_mask[ny, nx] = True
                q.append((ny, nx))

    if remove_inner_holes:
        # Only ultra-pure white interior holes (preserves off-white egret feathers & aprons)
        pure_white = (mn >= 247) & (sat <= 6)
        bg_mask |= pure_white

    alpha = np.where(bg_mask, 0, 255).astype(np.uint8)

    # Anti-aliased soft edge & white-halo decontamination for 1px boundary ring
    fg = ~bg_mask
    eroded = fg.copy()
    eroded[1:, :] &= fg[:-1, :]
    eroded[:-1, :] &= fg[1:, :]
    eroded[:, 1:] &= fg[:, :-1]
    eroded[:, :-1] &= fg[:, 1:]
    edge_ring = fg & (~eroded)

    # Soften very bright pixels right on the outer edge ring
    bright_edge = edge_ring & (mn >= 205) & (sat <= 35)
    t = np.clip((242.0 - mn.astype(np.float32)) / 38.0, 0.0, 1.0)
    alpha = np.where(bright_edge, (t * 255.0).astype(np.uint8), alpha)

    arr[:, :, 3] = alpha
    out = Image.fromarray(arr, mode="RGBA")
    bbox = out.getbbox()
    if bbox:
        out = out.crop(bbox)

    # Fit cleanly inside square target_size with gentle padding
    pad = max(8, target_size // 16)
    max_side = target_size - pad * 2
    scale = min(max_side / max(1, out.width), max_side / max(1, out.height))
    nw = max(1, int(round(out.width * scale)))
    nh = max(1, int(round(out.height * scale)))
    resized = out.resize((nw, nh), Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", (target_size, target_size), (0, 0, 0, 0))
    canvas.paste(resized, ((target_size - nw) // 2, (target_size - nh) // 2), resized)
    return canvas


def slice_grid(
    img_path: Path,
    cols: int,
    rows: int,
    names: list[str],
    out_dir: Path,
    target_size: int = 256,
    remove_bg: bool = True,
    remove_inner_holes: bool = True,
) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    im = Image.open(img_path).convert("RGB")
    cw = im.width / cols
    ch = im.height / rows
    idx = 0
    for r in range(rows):
        for c in range(cols):
            if idx >= len(names):
                break
            x0 = int(round(c * cw))
            y0 = int(round(r * ch))
            x1 = int(round((c + 1) * cw))
            y1 = int(round((r + 1) * ch))
            cell = im.crop((x0, y0, x1, y1))
            if remove_bg:
                # Trim small outer margin so neighbors never bleed
                mw = max(2, int(cell.width * 0.02))
                mh = max(2, int(cell.height * 0.02))
                cell = cell.crop((mw, mh, cell.width - mw, cell.height - mh))
                proc = remove_white_bg(cell, target_size=target_size, remove_inner_holes=remove_inner_holes)
            else:
                # Postcard crop: remove outer white gutter
                arr = np.array(cell)
                non_white = (arr.min(axis=2) < 238)
                ys, xs = np.where(non_white)
                if len(xs) > 10 and len(ys) > 10:
                    cell = cell.crop((int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1))
                proc = cell.resize((640, 480), Image.Resampling.LANCZOS).convert("RGBA")
            proc.save(out_dir / names[idx], "PNG", optimize=True)
            idx += 1


def generate_hex_bases() -> None:
    out_dir = ART_DIR / "tiles"
    out_dir.mkdir(parents=True, exist_ok=True)

    # Supersampled 2x canvas -> 280x244 final (flat-top hex radius = 128 in 280x244, exact fit)
    W, H = 560, 488
    R = 256.0
    cx, cy = W / 2.0, H / 2.0
    pts = [
        (cx + R * math.cos(math.radians(60 * i)), cy + R * math.sin(math.radians(60 * i)))
        for i in range(6)
    ]

    rng = np.random.default_rng(12345)
    themes = {
        "hex_base_grass.png": ((142, 206, 148), (118, 184, 126), (170, 224, 168)),
        "hex_base_farm.png": ((156, 204, 126), (132, 180, 102), (192, 222, 146)),
        "hex_base_blossom.png": ((158, 212, 152), (134, 192, 134), (222, 212, 188)),
        "hex_base_bamboo.png": ((114, 184, 128), (94, 162, 110), (144, 204, 148)),
        "hex_base_water.png": ((124, 198, 162), (98, 178, 152), (148, 216, 184)),
        "hex_base_village.png": ((154, 206, 148), (134, 188, 130), (188, 218, 172)),
    }

    mask_img = Image.new("L", (W, H), 0)
    mdraw = ImageDraw.Draw(mask_img)
    mdraw.polygon(pts, fill=255)
    mask_arr = np.array(mask_img, dtype=np.float32) / 255.0

    # Inner bevel mask
    inner_pts = [
        (cx + (R - 10) * math.cos(math.radians(60 * i)), cy + (R - 10) * math.sin(math.radians(60 * i)))
        for i in range(6)
    ]
    inner_img = Image.new("L", (W, H), 0)
    ImageDraw.Draw(inner_img).polygon(inner_pts, fill=255)
    inner_arr = np.array(inner_img, dtype=np.float32) / 255.0

    yy, xx = np.mgrid[0:H, 0:W]
    grad = np.clip((yy / H) * 0.7 + (xx / W) * 0.3, 0.0, 1.0)
    noise = rng.normal(0.0, 5.5, (H, W))

    for fname, (c_top, c_bot, c_hi) in themes.items():
        arr = np.zeros((H, W, 4), dtype=np.uint8)
        for ch in range(3):
            base = c_top[ch] * (1.0 - grad) + c_bot[ch] * grad + noise
            # Gentle warm sunlit highlight on upper rim
            rim = (mask_arr - inner_arr) * 0.65
            val = base * (1.0 - rim) + c_hi[ch] * rim
            arr[:, :, ch] = np.clip(val, 0, 255).astype(np.uint8)
        arr[:, :, 3] = np.clip(mask_arr * 255.0, 0, 255).astype(np.uint8)

        im = Image.fromarray(arr, mode="RGBA")
        # Subtle watercolor brush speckles composited cleanly without punching alpha holes
        speckle_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
        draw = ImageDraw.Draw(speckle_layer, "RGBA")
        for _ in range(42):
            px = int(cx + rng.uniform(-160, 160))
            py = int(cy + rng.uniform(-140, 140))
            if mask_arr[max(0, min(H - 1, py)), max(0, min(W - 1, px))] > 0.8:
                sr = int(rng.uniform(4, 11))
                col = (c_hi[0], c_hi[1], c_hi[2], int(rng.uniform(22, 48)))
                draw.ellipse((px - sr, py - sr // 2, px + sr, py + sr // 2), fill=col)
        im = Image.alpha_composite(im, speckle_layer)

        final = im.resize((280, 244), Image.Resampling.LANCZOS)
        final.save(out_dir / fname, "PNG", optimize=True)

    # Soft glow particle sprite
    gs = 128
    gy, gx = np.mgrid[0:gs, 0:gs]
    dist = np.sqrt(((gx - gs / 2.0) / (gs / 2.0)) ** 2 + ((gy - gs / 2.0) / (gs / 2.0)) ** 2)
    falloff = np.clip(1.0 - dist, 0.0, 1.0) ** 2.2
    g_arr = np.zeros((gs, gs, 4), dtype=np.uint8)
    g_arr[:, :, 0] = 255
    g_arr[:, :, 1] = 255
    g_arr[:, :, 2] = 255
    g_arr[:, :, 3] = (falloff * 255.0).astype(np.uint8)
    Image.fromarray(g_arr, mode="RGBA").save(ART_DIR / "ui" / "glow_soft.png", "PNG", optimize=True)

    # Cozy cloud puff sprite for outer meadow clouds
    cs = 192
    cloud = Image.new("RGBA", (cs, cs), (0, 0, 0, 0))
    cdraw = ImageDraw.Draw(cloud, "RGBA")
    for ox, oy, cr in [(64, 102, 36), (96, 86, 44), (128, 104, 34), (96, 112, 38)]:
        cdraw.ellipse((ox - cr, oy - cr, ox + cr, oy + cr), fill=(255, 253, 248, 175))
    cloud = cloud.filter(ImageFilter.GaussianBlur(4))
    cloud.save(ART_DIR / "ui" / "cloud_puff.png", "PNG", optimize=True)


def process_key_art_and_icon() -> None:
    ui_dir = ART_DIR / "ui"
    ui_dir.mkdir(parents=True, exist_ok=True)

    menu_src = RAW_DIR / "menu_bg.jpg"
    if menu_src.exists():
        im = Image.open(menu_src).convert("RGB")
        # Fit 720x1280 portrait cleanly
        target_ratio = 720.0 / 1280.0
        cur_ratio = im.width / im.height
        if cur_ratio > target_ratio:
            nw = int(im.height * target_ratio)
            x0 = (im.width - nw) // 2
            im = im.crop((x0, 0, x0 + nw, im.height))
        else:
            nh = int(im.width / target_ratio)
            y0 = (im.height - nh) // 2
            im = im.crop((0, y0, im.width, y0 + nh))
        im.resize((720, 1280), Image.Resampling.LANCZOS).save(ui_dir / "menu_bg.png", "PNG", optimize=True)

    icon_src = RAW_DIR / "app_icon_raw.jpg"
    if icon_src.exists():
        ic = Image.open(icon_src).convert("RGBA")
        side = min(ic.width, ic.height)
        x0 = (ic.width - side) // 2
        y0 = (ic.height - side) // 2
        ic = ic.crop((x0, y0, x0 + side, y0 + side))
        ic.resize((512, 512), Image.Resampling.LANCZOS).save(ui_dir / "launcher_512.png", "PNG", optimize=True)
        ic.resize((192, 192), Image.Resampling.LANCZOS).save(ui_dir / "launcher_192.png", "PNG", optimize=True)


def main() -> None:
    sync_raw_sources()
    process_key_art_and_icon()

    slice_grid(
        RAW_DIR / "sheet_terrain.jpg",
        3,
        2,
        ["prop_meadow.png", "prop_wheat.png", "prop_tea.png", "prop_blossom.png", "prop_bamboo.png", "prop_pond.png"],
        ART_DIR / "tiles",
        target_size=224,
        remove_bg=True,
        remove_inner_holes=True,
    )
    slice_grid(
        RAW_DIR / "sheet_landmarks.jpg",
        3,
        2,
        ["lm_cottage.png", "lm_watermill.png", "lm_teahouse.png", "lm_bridge.png", "lm_hotspring.png", "lm_windchime.png"],
        ART_DIR / "landmarks",
        target_size=240,
        remove_bg=True,
        remove_inner_holes=True,
    )
    slice_grid(
        RAW_DIR / "sheet_characters.jpg",
        3,
        2,
        ["char_villager_basket.png", "char_villager_tea.png", "char_cat_orange.png", "char_egret.png", "char_traveler.png", "char_snowfox.png"],
        ART_DIR / "characters",
        target_size=192,
        remove_bg=True,
        remove_inner_holes=False,  # Preserve white egret feathers & aprons!
    )
    slice_grid(
        RAW_DIR / "sheet_ui_icons.jpg",
        3,
        2,
        ["icon_grain.png", "icon_tea.png", "icon_bamboo.png", "icon_harmony.png", "icon_lantern.png", "icon_postcard.png"],
        ART_DIR / "ui",
        target_size=144,
        remove_bg=True,
        remove_inner_holes=True,
    )
    slice_grid(
        RAW_DIR / "sheet_postcards.jpg",
        2,
        2,
        ["postcard_01.png", "postcard_02.png", "postcard_03.png", "postcard_04.png"],
        ART_DIR / "postcards",
        remove_bg=False,
    )
    generate_hex_bases()
    print("Processed all Nanobanana sheets & procedural hex bases cleanly.")


if __name__ == "__main__":
    main()
