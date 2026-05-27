#importonce
// ============================================================
// Atari 800XL Graphics — ANTIC Display List + GR.8 Bitmap
//
// Display: mixed-mode ANTIC display list:
//   - 24 blank scan lines (3 × DL_BLANK8) for centering
//   - 160 lines of ANTIC mode F (GR.8: 320-pixel mono bitmap)
//     addressed starting at GFX_BASE ($4000)
//   - 4 rows of ANTIC mode 2 (GR.0: 40-col text, 8 scan lines each)
//     addressed starting at TXT_SCREEN ($5900)
//   - JMP+VBL (DL_JVB) back to display list start
//
// GR.8 pixel format:
//   - Each byte = 8 pixels, bit 7 = leftmost
//   - COLPF2 (shadow COLOR2) sets the foreground pixel color
//   - COLBK  (shadow COLOR4) sets the background color
//   - Row N starts at GFX_BASE + N * 40  (linear, unlike Apple HGR)
//
// Sprite blit (draw_doodle_sprite / erase_doodle_sprite):
//   3 bytes per row × 21 rows = 63 bytes per sprite.
//   C64 sprite bytes are used directly (both C64 and GR.8 are
//   MSB-first — no bit reversal needed, unlike Apple HGR).
//
// Zero-page scratch:
//   ZP_PTR  ($80/$81) — sprite source pointer (preserved across rows)
//   ZP_TMP  ($82/$83) — GFX row destination pointer (clobbered)
//   ZP_TMP3 ($84)     — row counter 0..20 (clobbered)
//   ZP_SPR  ($85/$86) — sprite row pointer advancing 3 bytes/row
//
// Sound:
//   beep — short POKEY click via AUDF1/AUDC1
//
// IMPORTANT: The display list must not straddle a 1KB boundary.
// The .align 1024 below ensures it starts within a 1KB block.
// ============================================================

// ─── Precomputed GFX row address tables ──────────────────────
// GR.8: row N starts at GFX_BASE + N*40.  Linear addressing.

gfx_row_lo:
    .fill GFX_ROWS, <(GFX_BASE + i * GFX_BYTES_PER_ROW)

gfx_row_hi:
    .fill GFX_ROWS, >(GFX_BASE + i * GFX_BYTES_PER_ROW)

// ─── Text row address tables (4 text rows) ───────────────────
txt_row_lo:
    .byte <TXT_LINE0, <TXT_LINE1, <TXT_LINE2, <TXT_LINE3

txt_row_hi:
    .byte >TXT_LINE0, >TXT_LINE1, >TXT_LINE2, >TXT_LINE3

// ─── Display List ────────────────────────────────────────────
// Must not cross a 1KB boundary; .align 1024 guarantees safety.
.align 1024
display_list:
    .byte $70, $70, $70                        // 3×8 blank lines (24 total)
    .byte $4F, <GFX_BASE, >GFX_BASE           // GR.8 row 0 with LMS
    .fill GFX_ROWS - 1, $0F                   // GR.8 rows 1-159
    .byte $42, <TXT_SCREEN, >TXT_SCREEN       // text row 0 with LMS
    .byte $02, $02, $02                        // text rows 1-3
    .byte $41, <display_list, >display_list   // JMP+VBL back to start

// ─── gfx_init ────────────────────────────────────────────────
// Install display list and enable DMA.
// Sets white-on-black pixel colors.
gfx_init:
    lda #<display_list
    sta SDLSTL
    lda #>display_list
    sta SDLSTH
    lda #$22            // normal-width DMA, no P/M DMA
    sta SDMCTL
    lda #$00            // black background
    sta COLOR4
    lda #$0E            // white foreground pixels (hue 0, lum 14)
    sta COLOR2
    rts

// ─── gfx_clear ───────────────────────────────────────────────
// Zero-fill the GFX bitmap: 160 rows × 40 bytes = 6400 bytes.
// 6400 = 25 × 256, so we do 25 full-page zero-fills.
gfx_clear:
    lda #0
    sta ZP_TMP
    lda #>GFX_BASE      // $40
    sta ZP_TMP2
    ldy #0
    ldx #25             // 25 pages × 256 bytes = 6400 bytes
gc_inner:
    sta (ZP_TMP),y
    iny
    bne gc_inner
    inc ZP_TMP2
    dex
    bne gc_inner
    rts

// ─── txt_clear ───────────────────────────────────────────────
// Write space (screen code 0) to all 4 text rows (160 bytes).
txt_clear:
    lda #0              // screen code 0 = space
    ldy #159
tc_loop:
    sta TXT_SCREEN,y
    dey
    bpl tc_loop
    rts

// ─── draw_doodle_sprite ──────────────────────────────────────
// Blit a 21-row × 3-byte sprite into the GFX bitmap.
//
// Before calling:
//   doodle_col  = GFX column byte offset (0-37)
//   doodle_row  = GFX start row (0-139 to fit 21 rows)
//   ZP_PTR_LO/HI = address of first byte of 63-byte sprite
//
// Trashes A, X, Y, ZP_TMP, ZP_TMP2, ZP_TMP3, ZP_SPR_LO/HI.
draw_doodle_sprite:
    lda ZP_PTR_LO
    sta ZP_SPR_LO
    lda ZP_PTR_HI
    sta ZP_SPR_HI

    ldx doodle_row
    lda #0
    sta ZP_TMP3

dds_row:
    lda gfx_row_lo,x
    clc
    adc doodle_col
    sta ZP_TMP
    lda gfx_row_hi,x
    adc #0
    sta ZP_TMP2

    ldy #2              // 3 bytes per row (indices 2, 1, 0)
dds_col:
    lda (ZP_SPR_LO),y
    sta (ZP_TMP),y
    dey
    bpl dds_col

    // Advance sprite pointer by 3
    lda ZP_SPR_LO
    clc
    adc #3
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

// ─── erase_doodle_sprite ─────────────────────────────────────
// Write $00 over 21 rows × 3 bytes at (doodle_col, doodle_row).
erase_doodle_sprite:
    ldx doodle_row
    lda #0
    sta ZP_TMP3

eds_row:
    lda gfx_row_lo,x
    clc
    adc doodle_col
    sta ZP_TMP
    lda gfx_row_hi,x
    adc #0
    sta ZP_TMP2

    ldy #2
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

// ─── beep ────────────────────────────────────────────────────
// Short POKEY tone.  Trashes A, X.
beep:
    lda #$10            // frequency (medium pitch)
    sta AUDF1
    lda #$A8            // pure tone distortion ($A0), volume 8
    sta AUDC1
    ldx #$60            // delay loop
beep_loop:
    dex
    bne beep_loop
    lda #$00            // silence channel 1
    sta AUDC1
    rts
