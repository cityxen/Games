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
//   - COLPF1 (shadow COLOR1) sets the foreground pixel luminance
//   - COLPF2 (shadow COLOR2) sets the bitmap background color
//   - COLBK  (shadow COLOR4) sets the border color
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

// ─── Text row address tables (up to 24 rows) ─────────────────
// Rows are contiguous 40-byte lines: row N at TXT_SCREEN + N*40.
// The mixed display shows only rows 0-3; the text-only instruction
// display (text_display_list) shows all 24.
txt_row_lo:
    .fill 24, <(TXT_SCREEN + i*40)

txt_row_hi:
    .fill 24, >(TXT_SCREEN + i*40)

// ─── Display List ────────────────────────────────────────────
// Must not cross a 1KB boundary; .align 1024 guarantees safety.
.align 1024
display_list:
    .byte $70, $70, $70                        // 3×8 blank lines (24 total)
    .byte $4E, <GFX_BASE, >GFX_BASE           // mode E row 0 with LMS
    .fill 102, $0E                            // mode E rows 1-102
    // ANTIC's playfield memory counter wraps at every 4KB boundary, so a
    // 6400-byte GR.8 screen based at $4000 would mirror its top onto its
    // bottom past $5000.  Reload the address with a second LMS at row 103
    // (linear address $5018) to keep the whole bitmap contiguous.
    .byte $4E, <(GFX_BASE + 103*GFX_BYTES_PER_ROW), >(GFX_BASE + 103*GFX_BYTES_PER_ROW)
    .fill GFX_ROWS - 104, $0E                 // mode E rows 104-159
    .byte $42, <TXT_SCREEN, >TXT_SCREEN       // text row 0 with LMS
    .byte $02, $02, $02                        // text rows 1-3
    .byte $41, <display_list, >display_list   // JMP+VBL back to start

// ─── Text-only Display List (instruction page) ───────────────
// 24 rows of ANTIC mode 2 (40-col text) from TXT_SCREEN — no GFX
// bitmap. Used only for draw_screen_instruct so it can show a full
// screen of rules text. Fits in the same 1KB block as display_list.
text_display_list:
    .byte $70, $70, $70                        // 24 blank scan lines (top)
    .byte $42, <TXT_SCREEN, >TXT_SCREEN       // mode 2 row 0 with LMS
    .fill 23, $02                             // mode 2 rows 1-23
    .byte $41, <text_display_list, >text_display_list  // JMP+VBL

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
    // ANTIC mode E (4-color). Doodle pixels use:
    //   %00 = COLBK (background, lets the P/M circle show through)
    //   %01 = COLPF0 = black doodle outline
    //   %10 = COLPF1 = doodle fill (hue cycled at runtime -> rainbow)
    //   %11 = COLPF2 = unused
    lda #$00            // black background (COLBK) + unused COLPF2
    sta COLOR4
    sta COLOR2
    sta COLOR0         // COLPF0 = black outline
    lda #$0E            // COLPF1 = white fill initially (cycled -> rainbow)
    sta COLOR1
    rts

// ─── set_gfx_dl / set_text_dl ────────────────────────────────
// Swap the active display list (SDLSTL/H are OS shadows, so the
// change takes effect cleanly at the next VBL). set_gfx_dl = the
// mixed mode-E + 4-text-row screen; set_text_dl = full 24-row text.
set_gfx_dl:
    lda #<display_list
    sta SDLSTL
    lda #>display_list
    sta SDLSTH
    rts

set_text_dl:
    lda #<text_display_list
    sta SDLSTL
    lda #>text_display_list
    sta SDLSTH
    rts

// ─── cycle_doodle_hue ────────────────────────────────────────
// Advance the doodle FILL hue one step. Adding $10 bumps COLPF1's hue
// nibble and wraps cleanly, leaving the low nibble (luminance $0E)
// intact — so the mode-E doodle fill rainbows while the HUD text, which
// takes its hue from COLPF2 and only its luminance from COLPF1, stays a
// steady white (no DLI needed). Call once per frame after wait_vbl.
cycle_doodle_hue:
    lda doodle_hue
    clc
    adc #$10
    sta doodle_hue
    sta COLOR1
    rts

// ─── gfx_clear ───────────────────────────────────────────────
// Zero-fill the GFX bitmap: 160 rows × 40 bytes = 6400 bytes.
// 6400 = 25 × 256, so we do 25 full-page zero-fills.
gfx_clear:
    lda #<GFX_BASE
    sta ZP_TMP
    lda #>GFX_BASE
    sta ZP_TMP2
    ldy #0
    ldx #25             // 25 pages × 256 bytes = 6400 bytes
    lda #0              // fill value 0 (A was clobbered by the pointer setup above)
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
    ldy #0
tc_loop:
    sta TXT_SCREEN,y   // 160 bytes > 127, so count up with cpy:
    iny                // a dey/bpl loop would exit early (159 = $9F < 0)
    cpy #160
    bne tc_loop
    rts

// ─── screen_clear ────────────────────────────────────────────
// Clear the whole display surface: GFX bitmap + text rows.
screen_clear:
    jsr gfx_clear
    jsr txt_clear
    rts

// ─── txt_clear_full ──────────────────────────────────────────
// Clear all 24 text rows ($5900-$5CFF, 1024 bytes covers 24x40=960)
// for the text-only instruction screen.
txt_clear_full:
    lda #<TXT_SCREEN
    sta ZP_TMP
    lda #>TXT_SCREEN
    sta ZP_TMP2
    ldx #4              // 4 pages (1024 bytes) >= 960, stays below PMG ($6000)
    ldy #0
    lda #0
tcfull_loop:
    sta (ZP_TMP),y
    iny
    bne tcfull_loop
    inc ZP_TMP2
    dex
    bne tcfull_loop
    rts

// ─── draw_doodle_sprite ──────────────────────────────────────
// Blit a 21-row × 6-byte (mode E 2bpp) sprite into the GFX bitmap.
//
// Before calling:
//   doodle_col  = GFX column byte offset (0-34)
//   doodle_row  = GFX start row (0-139 to fit 21 rows)
//   ZP_PTR_LO/HI = address of first byte of 126-byte sprite
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

    ldy #5              // 6 bytes per row (mode E 2bpp), indices 5..0
dds_col:
    lda (ZP_SPR_LO),y
    sta (ZP_TMP),y
    dey
    bpl dds_col

    // Advance sprite pointer by 6
    lda ZP_SPR_LO
    clc
    adc #6
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

    ldy #5              // 6 bytes per row (mode E 2bpp)
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
