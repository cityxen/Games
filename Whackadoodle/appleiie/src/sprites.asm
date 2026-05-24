#importonce
// ============================================================
// 8 doodle sprites, 8 bytes each (7 pixels wide × 8 rows)
//
// HGR byte format: bit 7 = palette (0=orange/violet, 1=blue/green)
// Bits 0-6 = pixels, bit 0 = leftmost pixel.
// Bit 7 = 1 here -> blue/white palette for visibility.
//
// Doodle indices match C64 original:
//   0 = Happyface (good)   4 = RAD symbol (bad)
//   1 = Yin-yang  (good)   5 = Skull      (bad)
//   2 = Heart     (good)   6 = Poo pile   (bad)
//   3 = Star      (good)   7 = Frown      (bad)
// ============================================================

// Sprite table pointer helpers
// sprite_data + doodle*8 = address of sprite bytes

sprite_data:

// ─── 0: Happyface ────────────────────────────────────────────
//  .0111100  outer ring top
//  .1000010  sides
//  .1010010  eyes (bits 4 and 1)
//  .1000010
//  .1100110  mouth corners
//  .1011010  mouth
//  .1000010  sides
//  .0111100  outer ring bottom
.byte %10111100
.byte %11000010
.byte %11010010
.byte %11000010
.byte %11100110
.byte %11011010
.byte %11000010
.byte %10111100

// ─── 1: Yin-yang (simplified) ────────────────────────────────
//  .0111100
//  .0111100
//  .0011100
//  .0001100
//  .1110000
//  .1111100
//  .1111100
//  .0111100
.byte %10111100
.byte %10111100
.byte %10011100
.byte %10001100
.byte %11110000
.byte %11111100
.byte %11111100
.byte %10111100

// ─── 2: Heart ────────────────────────────────────────────────
//  .0110110
//  .1111111
//  .1111111
//  .1111111
//  .0111110
//  .0011100
//  .0001000
//  .0000000
.byte %10110110
.byte %11111111
.byte %11111111
.byte %11111111
.byte %10111110
.byte %10011100
.byte %10001000
.byte %10000000

// ─── 3: Star ─────────────────────────────────────────────────
//  .0001000
//  .0001000
//  .1111111
//  .0011100
//  .0101010
//  .1000001
//  .0000000
//  .0000000
.byte %10001000
.byte %10001000
.byte %11111111
.byte %10011100
.byte %10101010
.byte %11000001
.byte %10000000
.byte %10000000

// ─── 4: RAD (radiation) ──────────────────────────────────────
//  .0011100
//  .0111110
//  .1100011
//  .1000001
//  .1100011
//  .0111110
//  .0100010
//  .1000001
.byte %10011100
.byte %10111110
.byte %11100011
.byte %11000001
.byte %11100011
.byte %10111110
.byte %10100010
.byte %11000001

// ─── 5: Skull ────────────────────────────────────────────────
//  .0111100
//  .1000010
//  .1101110  two eyes
//  .1000010
//  .0111100
//  .0111100  jaw
//  .0000000
//  .0111100
.byte %10111100
.byte %11000010
.byte %11101110
.byte %11000010
.byte %10111100
.byte %10111100
.byte %10000000
.byte %10111100

// ─── 6: Poo pile ─────────────────────────────────────────────
//  .0001000  top curl
//  .0011100
//  .0111110
//  .1111111
//  .1111111
//  .0111110
//  .0011100
//  .0000000
.byte %10001000
.byte %10011100
.byte %10111110
.byte %11111111
.byte %11111111
.byte %10111110
.byte %10011100
.byte %10000000

// ─── 7: Frown ────────────────────────────────────────────────
//  .0111100
//  .1000010
//  .1010010  eyes
//  .1000010
//  .1011010  frown
//  .1100110  frown corners
//  .1000010
//  .0111100
.byte %10111100
.byte %11000010
.byte %11010010
.byte %11000010
.byte %11011010
.byte %11100110
.byte %11000010
.byte %10111100

// ─── Sprite address lookup ────────────────────────────────────
// sprite_lo[n] / sprite_hi[n] = address of sprite n's data.
// Use these to load ZP_PTR_LO/HI before calling draw_doodle_sprite.

.macro LoadSpritePtr(n) {
    lda #<[sprite_data + n*8]
    sta ZP_PTR_LO
    lda #>[sprite_data + n*8]
    sta ZP_PTR_HI
}

// Runtime version: A = doodle index (0-7), sets ZP_PTR_LO/HI
set_sprite_ptr:
    // offset = A * 8 = (A << 3)
    asl             // x2
    asl             // x4
    asl             // x8
    clc
    adc #<sprite_data
    sta ZP_PTR_LO
    lda #>sprite_data
    adc #0
    sta ZP_PTR_HI
    rts
