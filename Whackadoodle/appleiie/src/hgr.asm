#importonce
// ============================================================
// Apple IIe Hi-Res Graphics (HGR) primitives
//
// HGR page 1: $2000-$3FFF  (280x192 pixels)
// Each byte covers 7 pixels.  Bit 7 = palette select.
// Bit 0 = leftmost pixel of the byte, bit 6 = rightmost.
//
// Row address formula:
//   hi = $20 + (row & 7)*4 + (row >> 6)
//   lo = ((row >> 3) & 7) * $28
//
// Mixed mode (GFX_MIXED):
//   HGR rows 0-159 display as graphics.
//   Text rows 20-23 display as text at the bottom.
//
// Zero-page usage (must not conflict with config.asm):
//   ZP_PTR_LO/HI ($06/$07) = source pointer (sprite data)
//   ZP_TMP/ZP_TMP2 ($08/$09) = destination pointer (HGR address)
//   ZP_TMP3 ($0A) = loop counter / scratch
// ============================================================

// Add ZP_TMP3 here since hgr.asm owns it:
.const ZP_TMP3 = $0A

// ─── Precomputed row address tables (192 entries, KickAss script) ─

hgr_row_lo:
    .fill 192, (([i >> 3] & 7) * $28)

hgr_row_hi:
    .fill 192, ($20 + (i & 7) * 4 + (i >> 6))

// ─── hgr_init ─────────────────────────────────────────────────
// Enable HGR page 1, mixed mode (160 px HGR + 4 text rows).
hgr_init:
    bit GFX_ON
    bit GFX_MIXED
    bit GFX_PAGE1
    bit GFX_HIRES
    rts

// ─── hgr_clear ────────────────────────────────────────────────
// Zero-fill HGR page 1 ($2000-$3FFF = 8 KB).
// Trashes A, X, Y.
hgr_clear:
    lda #$00
    sta ZP_PTR_LO
    lda #$20
    sta ZP_PTR_HI
    ldy #$00
    ldx #$20            // 32 pages × 256 bytes
hc_inner:
    sta (ZP_PTR_LO),y
    iny
    bne hc_inner
    inc ZP_PTR_HI
    dex
    bne hc_inner
    rts

// ─── draw_doodle_sprite ────────────────────────────────────────
// Draw an 8-row × 1-byte sprite at (doodle_col, doodle_row).
//
// Before calling:
//   doodle_col = HGR column byte index (0-39)
//   doodle_row = HGR start row (0-159 for mixed mode)
//   ZP_PTR_LO/HI = address of 8-byte sprite bitmap
//
// Pointer pairs:
//   ZP_PTR ($06/$07)  — sprite source  (preserved across call)
//   ZP_TMP ($08/$09)  — HGR dest       (clobbered)
//   ZP_TMP3 ($0A)     — row counter    (clobbered)
// Trashes A, X, Y.
draw_doodle_sprite:
    ldx doodle_row          // X = HGR row index
    lda #0
    sta ZP_TMP3             // sprite row counter 0..7
    ldy #0                  // Y=0 for all indirect ops
dds_loop:
    // Build HGR destination address -> ZP_TMP/ZP_TMP2
    lda hgr_row_lo,x
    clc
    adc doodle_col          // add column byte offset
    sta ZP_TMP              // destination lo
    lda hgr_row_hi,x
    adc #0                  // absorb carry
    sta ZP_TMP2             // destination hi

    // Fetch sprite byte for this row
    lda ZP_TMP3
    tay                     // Y = sprite row index
    lda (ZP_PTR_LO),y       // read sprite[row]
    ldy #0                  // Y back to 0 for indirect store
    sta (ZP_TMP),y          // write to HGR

    inc ZP_TMP3
    lda ZP_TMP3
    cmp #8
    beq dds_done
    inx                     // next HGR row
    jmp dds_loop
dds_done:
    rts

// ─── erase_doodle_sprite ──────────────────────────────────────
// Write $00 over 8 rows at (doodle_col, doodle_row).
// Trashes A, X, Y, ZP_TMP, ZP_TMP2, ZP_TMP3.
erase_doodle_sprite:
    ldx doodle_row
    lda #0
    sta ZP_TMP3
    ldy #0
eds_loop:
    lda hgr_row_lo,x
    clc
    adc doodle_col
    sta ZP_TMP
    lda hgr_row_hi,x
    adc #0
    sta ZP_TMP2
    lda #$00
    sta (ZP_TMP),y          // Y=0 always
    inc ZP_TMP3
    lda ZP_TMP3
    cmp #8
    beq eds_done
    inx
    jmp eds_loop
eds_done:
    rts

// ─── beep ─────────────────────────────────────────────────────
// Short speaker click.  Trashes A, X.
beep:
    ldx #$08
beep_loop:
    bit SPEAKER
    dex
    bne beep_loop
    rts
