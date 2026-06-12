#!/usr/bin/env python3
"""
One-off: convert the Whackadoodle doodle sprites from 1bpp (mode F / GR.8,
24px wide, 3 bytes/row) to 2bpp (mode E, 24 mode-E px wide, 6 bytes/row).

Per pixel:
  fill (was a set 1bpp pixel)            -> 0b10  (COLPF1, rainbow fill)
  outline (clear pixel touching a fill   -> 0b01  (COLPF0, black outline)
           in any of the 8 directions)
  else                                   -> 0b00  (transparent -> P/M circle)

Mode E byte = 4 pixels, 2 bits each, MSB = leftmost pixel.
Reads the .byte block out of src/sprites.asm so the source of truth stays
the existing art.
"""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
# Stable 1bpp source (original art, recovered from git) — NOT the generated
# src/sprites.asm, which this script overwrites with mode-E output.
SPR = os.path.join(HERE, "sprites_1bpp_source.asm")

NAMES = ["Happyface", "Yin-yang", "Heart", "Star",
         "RAD symbol", "Skull", "Poo pile", "Frown"]

W = 24          # input pixels per row (1bpp source)
OUT_W = 24      # output pixels per row (24 = full size; 12 = downscaled 2:1)
ROWS = 21       # rows per sprite

def load_1bpp():
    """Return list of 8 sprites, each ROWS rows of W-bit fill values (0/1 lists)."""
    text = open(SPR, "r", encoding="utf-8", errors="replace").read()
    # grab the body between 'sprite_data:' and 'set_sprite_ptr'
    body = text.split("sprite_data:", 1)[1].split("set_sprite_ptr", 1)[0]
    bytes_all = []
    for line in body.splitlines():
        if ".byte" not in line:
            continue
        vals = re.findall(r"%([01]{8})", line)
        if len(vals) != 3:
            continue
        bytes_all.append([int(v, 2) for v in vals])
    assert len(bytes_all) == 8 * ROWS, f"expected {8*ROWS} rows, got {len(bytes_all)}"
    sprites = []
    for s in range(8):
        rows = []
        for r in range(ROWS):
            b0, b1, b2 = bytes_all[s * ROWS + r]
            bits = []
            for byte in (b0, b1, b2):
                for k in range(7, -1, -1):
                    bits.append((byte >> k) & 1)
            rows.append(bits)            # 24 bits
        sprites.append(rows)
    return sprites

def downscale(rows):
    """Resample horizontal resolution W -> OUT_W. OUT_W==W is a passthrough;
    OUT_W==W/2 halves (out px = OR of the two source px)."""
    if OUT_W == W:
        return rows
    out = []
    for r in range(ROWS):
        orow = []
        for c in range(OUT_W):
            orow.append(1 if (rows[r][2*c] or rows[r][2*c+1]) else 0)
        out.append(orow)
    return out

def outline(rows):
    """Return outline mask: clear pixels adjacent (8-dir) to a fill pixel."""
    out = [[0] * OUT_W for _ in range(ROWS)]
    for r in range(ROWS):
        for c in range(OUT_W):
            if rows[r][c]:
                continue
            touch = False
            for dr in (-1, 0, 1):
                for dc in (-1, 0, 1):
                    if dr == 0 and dc == 0:
                        continue
                    rr, cc = r + dr, c + dc
                    if 0 <= rr < ROWS and 0 <= cc < OUT_W and rows[rr][cc]:
                        touch = True
            out[r][c] = 1 if touch else 0
    return out

def to_2bpp_bytes(fill, out):
    """12 pixels -> 3 bytes, 2bpp MSB-first."""
    px = []
    for c in range(OUT_W):
        if fill[c]:
            px.append(0b10)
        elif out[c]:
            px.append(0b01)
        else:
            px.append(0b00)
    bs = []
    for i in range(0, OUT_W, 4):
        b = (px[i] << 6) | (px[i+1] << 4) | (px[i+2] << 2) | px[i+3]
        bs.append(b)
    return bs

HEADER = '''#importonce
// ============================================================
// Atari 800XL Doodle Sprites — ANTIC mode E (4-color, 2bpp)
//
// Re-encoded from the original 1bpp art by tools/convert_sprites_modee.py
// 24 mode-E px wide x 21 rows, 6 bytes/row (4 px/byte, 2 bits/px),
// MSB = leftmost pixel.  126 bytes per sprite.
//
// Pixel values:
//   %00 = transparent  -> the P/M button circle shows through
//   %01 = COLPF0        -> black outline (static)
//   %10 = COLPF1        -> fill (hue cycled each frame = rainbow)
//
// set_sprite_ptr computes:  ZP_PTR = sprite_data + index * 126
//
// Doodle indices (same as C64 / Apple IIe):
//   0 = Happyface (good)   4 = RAD symbol (bad)
//   1 = Yin-yang  (good)   5 = Skull      (bad)
//   2 = Heart     (good)   6 = Poo pile   (bad)
//   3 = Star      (good)   7 = Frown      (bad)
// ============================================================
'''

FOOTER = '''
// ─── set_sprite_ptr ──────────────────────────────────────────
// In:  A = doodle index (0-7)
// Out: ZP_PTR_LO/HI = sprite_data + index * 126
//
// index*126 = (index*64 - index) * 2 = index*63 then doubled.
set_sprite_ptr:
    sta ZP_TMP          // save index 0-7

    lsr                 // A >> 1
    lsr                 // A >> 2
    sta ZP_SPR_HI       // hi = A >> 2

    lda ZP_TMP
    and #3
    asl
    asl
    asl
    asl
    asl
    asl                 // (index & 3) << 6
    sta ZP_SPR_LO       // lo of index*64

    // index*64 - index = index*63
    lda ZP_SPR_LO
    sec
    sbc ZP_TMP
    sta ZP_SPR_LO
    lda ZP_SPR_HI
    sbc #0
    sta ZP_SPR_HI

    // *2 -> index*126
    asl ZP_SPR_LO
    rol ZP_SPR_HI

    // + sprite_data base
    lda ZP_SPR_LO
    clc
    adc #<sprite_data
    sta ZP_PTR_LO
    lda ZP_SPR_HI
    adc #>sprite_data
    sta ZP_PTR_HI
    rts
'''

def main():
    sprites = load_1bpp()
    lines = [HEADER, "sprite_data:"]
    for s, rows0 in enumerate(sprites):
        rows = downscale(rows0)
        out = outline(rows)
        lines.append(f"\n// ─── {s}: {NAMES[s]} ─── (mode E, 2bpp, 6 bytes/row)")
        for r in range(ROWS):
            bs = to_2bpp_bytes(rows[r], out[r])
            row = ",".join("%" + format(b, "08b") for b in bs)
            lines.append(f"    .byte {row}")
    lines.append(FOOTER)
    out_asm = os.path.join(HERE, "..", "src", "sprites.asm")
    open(out_asm, "w", encoding="utf-8").write("\n".join(lines) + "\n")
    print("wrote", os.path.normpath(out_asm))

if __name__ == "__main__":
    main()
