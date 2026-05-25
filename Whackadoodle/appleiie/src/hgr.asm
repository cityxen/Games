#importonce
// ============================================================
// Apple IIe Hi-Res Graphics (HGR) primitives
//
// HGR page 1: $2000-$3FFF  (280x192 pixels)
// Each byte covers 7 pixels.  Bit 7 = palette select.
// Bit 0 = leftmost pixel of the byte, bit 6 = rightmost.
//
// Row address formula:
//   hi = $20 + (row & 7)*4 + ((row >> 3) & 7) / 2
//   lo = ((row >> 3) & 1) * $80 + (row >> 6) * $28
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

// ZP scratch owned by hgr.asm:
.const ZP_TMP3   = $0A   // row counter
.const ZP_SPR_LO = $0B   // sprite row pointer lo (advances 8 per row)
.const ZP_SPR_HI = $0C   // sprite row pointer hi

// ─── Precomputed row address tables (192 entries, KickAss script) ─

hgr_row_lo:
    .fill 192, (((i >> 3) & 1) * $80 + (i >> 6) * $28)

hgr_row_hi:
    .fill 192, ($20 + (i & 7) * 4 + ((i >> 3) & 7) / 2)

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
    lda #$00            // A was clobbered by lda #$20 above
hc_inner:
    sta (ZP_PTR_LO),y
    iny
    bne hc_inner
    inc ZP_PTR_HI
    dex
    bne hc_inner
    rts

// ─── draw_doodle_sprite ────────────────────────────────────────
// Draw a 21-row × 4-byte sprite at (doodle_col, doodle_row).
//
// Before calling:
//   doodle_col  = HGR column byte index (0-39)
//   doodle_row  = HGR start row (0-159 for mixed mode)
//   ZP_PTR_LO/HI = address of first byte of 84-byte sprite
//
// ZP usage:
//   ZP_PTR  ($06/$07) — original sprite base (preserved)
//   ZP_TMP  ($08/$09) — HGR row dest base    (clobbered)
//   ZP_TMP3 ($0A)     — row counter 0..20    (clobbered)
//   ZP_SPR  ($0B/$0C) — sprite row pointer   (clobbered)
// Trashes A, X, Y.
draw_doodle_sprite:
    lda ZP_PTR_LO
    sta ZP_SPR_LO
    lda ZP_PTR_HI
    sta ZP_SPR_HI

    ldx doodle_row
    lda #0
    sta ZP_TMP3

dds_row:
    lda hgr_row_lo,x
    clc
    adc doodle_col
    sta ZP_TMP
    lda hgr_row_hi,x
    adc #0
    sta ZP_TMP2

    ldy #3
dds_col:
    lda (ZP_SPR_LO),y
    sta (ZP_TMP),y
    dey
    bpl dds_col

    // Advance sprite row pointer by 4
    lda ZP_SPR_LO
    clc
    adc #4
    sta ZP_SPR_LO
    bcc dds_no_carry
    inc ZP_SPR_HI
dds_no_carry:

    inc ZP_TMP3
    lda ZP_TMP3
    cmp #21
    beq dds_done
    inx
    jmp dds_row
dds_done:
    rts

// ─── erase_doodle_sprite ──────────────────────────────────────
// Write $00 over 21 rows × 4 bytes at (doodle_col, doodle_row).
// Trashes A, X, Y, ZP_TMP, ZP_TMP2, ZP_TMP3.
erase_doodle_sprite:
    ldx doodle_row
    lda #0
    sta ZP_TMP3

eds_row:
    lda hgr_row_lo,x
    clc
    adc doodle_col
    sta ZP_TMP
    lda hgr_row_hi,x
    adc #0
    sta ZP_TMP2

    ldy #3
eds_col:
    lda #$00
    sta (ZP_TMP),y
    dey
    bpl eds_col

    inc ZP_TMP3
    lda ZP_TMP3
    cmp #21
    beq eds_done
    inx
    jmp eds_row
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
