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

// ─── Scratch buffers for draw_doodle_or outline ──────────────
// doodle_hbuf: each sprite row dilated horizontally  (21 rows x 4 bytes)
// doodle_dbuf: full 8-neighbour dilated silhouette    (21 rows x 4 bytes)
doodle_hbuf:  .fill 84, 0
doodle_dbuf:  .fill 84, 0
dd_b0:        .byte 0     // current row's 4 sprite bytes
dd_b1:        .byte 0
dd_b2:        .byte 0
dd_b3:        .byte 0
dd_cur:       .byte 0     // hdil input: centre / left / right byte
dd_left:      .byte 0
dd_right:     .byte 0
dd_tmp:       .byte 0     // hdil scratch
dd_rows:      .byte 0     // row counter

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

// ─── hgr_fill_split ───────────────────────────────────────────
// Fill the mixed-mode HGR area (rows 0-159) with a green left half
// and an orange ("red") right half, blended through a small dithered
// band in the middle byte columns.
//
//   Green byte  = $2A (even byte col) / $55 (odd byte col)  -- matches
//                 big_circle_green's fill pattern.
//   Orange byte = green | $80 (HGR palette bit set, same as big_circle_orange).
//   Dither band cols [SPLIT_DLO..SPLIT_DHI]: per-byte checkerboard of
//   green/orange keyed on (col + row) parity.
//
// (ZP_TMP),Y indirect-indexed addressing carries Y into the full 16-bit
// row base, so one base per row covers all 40 byte columns.
// Trashes A, X, Y, ZP_TMP, ZP_TMP2, ZP_TMP3.
.const HGR_FILL_ROWS = 160      // mixed-mode visible HGR rows
.const SPLIT_DLO     = 17       // dither band: first byte column
.const SPLIT_DHI     = 19       // dither band: last  byte column

hgr_green_byte:
    .byte $2A, $55              // [even col, odd col]
hgr_fill_grn:
    .byte 0

hgr_fill_split:
    lda #0
    sta ZP_TMP3                // row = 0
hfs_row:
    ldx ZP_TMP3
    lda hgr_row_lo,x
    sta ZP_TMP
    lda hgr_row_hi,x
    sta ZP_TMP2

    ldy #0                     // col = 0
hfs_col:
    tya
    and #1
    tax
    lda hgr_green_byte,x       // green base for this column's parity
    sta hgr_fill_grn

    cpy #SPLIT_DLO
    bcc hfs_green              // col < SPLIT_DLO  -> green half
    cpy #SPLIT_DHI+1
    bcs hfs_orange             // col > SPLIT_DHI  -> orange half
    tya                        // dither band: checkerboard (col + row) parity
    clc
    adc ZP_TMP3
    and #1
    bne hfs_orange             // odd  -> orange
hfs_green:
    lda hgr_fill_grn           // palette bit clear
    jmp hfs_put
hfs_orange:
    lda hgr_fill_grn
    ora #$80                   // palette bit set
hfs_put:
    sta (ZP_TMP),y
    iny
    cpy #40
    bne hfs_col

    inc ZP_TMP3
    lda ZP_TMP3
    cmp #HGR_FILL_ROWS
    bne hfs_row
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

// ─── draw_doodle_or ───────────────────────────────────────────
// Overlay a doodle onto a button with a 1-pixel black outline around it.
// The doodle's lit pixels are OR'd on top of the button, but a 1-pixel
// black halo is first cleared around the shape so the white doodle reads
// cleanly against the coloured button.
//
// Method:
//   1. Build doodle_hbuf = each sprite row dilated 1px horizontally.
//   2. Build doodle_dbuf = doodle_hbuf OR'd with the rows above/below
//      (full 8-neighbour dilation of the doodle silhouette).
//   3. Per row: screen &= ~dbuf  (punch the dilated silhouette to black),
//      then screen |= sprite     (draw the doodle white on top).
//      The halo (dbuf AND NOT sprite) is the 1px black outline.
//
// Horizontal dilation stays within the 4-byte sprite width and vertical
// dilation within the 21 rows; all current doodles have blank edge rows,
// so the outline is never clipped.
//
// In: ZP_PTR_LO/HI = sprite base; doodle_col/doodle_row = position.
// Trashes A, X, Y, ZP_TMP/2, ZP_SPR_LO/HI, ZP_PTR_LO/HI, dd_* scratch.
draw_doodle_or:
    // ── Phase 1: horizontal dilation of every sprite row into hbuf ──
    lda ZP_PTR_LO
    sta ZP_SPR_LO
    lda ZP_PTR_HI
    sta ZP_SPR_HI
    ldx #0                  // X = flat byte offset into hbuf (0..83)
    lda #21
    sta dd_rows

ddo_h_row:
    ldy #0
    lda (ZP_SPR_LO),y
    sta dd_b0
    iny
    lda (ZP_SPR_LO),y
    sta dd_b1
    iny
    lda (ZP_SPR_LO),y
    sta dd_b2
    iny
    lda (ZP_SPR_LO),y
    sta dd_b3

    lda #0                  // byte 0: no left neighbour
    sta dd_left
    lda dd_b0
    sta dd_cur
    lda dd_b1
    sta dd_right
    jsr hdil
    sta doodle_hbuf,x
    inx

    lda dd_b0               // byte 1
    sta dd_left
    lda dd_b1
    sta dd_cur
    lda dd_b2
    sta dd_right
    jsr hdil
    sta doodle_hbuf,x
    inx

    lda dd_b1               // byte 2
    sta dd_left
    lda dd_b2
    sta dd_cur
    lda dd_b3
    sta dd_right
    jsr hdil
    sta doodle_hbuf,x
    inx

    lda dd_b2               // byte 3: no right neighbour
    sta dd_left
    lda dd_b3
    sta dd_cur
    lda #0
    sta dd_right
    jsr hdil
    sta doodle_hbuf,x
    inx

    lda ZP_SPR_LO
    clc
    adc #4
    sta ZP_SPR_LO
    bcc ddo_h_nc
    inc ZP_SPR_HI
ddo_h_nc:
    dec dd_rows
    beq ddo_h_done
    jmp ddo_h_row
ddo_h_done:

    // ── Phase 2: vertical dilation -> dbuf (8-neighbour silhouette) ──
    ldx #0                  // X = flat offset 0..83
ddo_v:
    lda doodle_hbuf,x
    cpx #4
    bcc ddo_v_no_up         // top row: no row above
    ora doodle_hbuf-4,x
ddo_v_no_up:
    cpx #80
    bcs ddo_v_no_down       // bottom row: no row below
    ora doodle_hbuf+4,x
ddo_v_no_down:
    sta doodle_dbuf,x
    inx
    cpx #84
    bne ddo_v

    // ── Phase 3: clear silhouette to black, then OR the doodle ──
    lda ZP_PTR_LO
    sta ZP_SPR_LO           // ZP_SPR = sprite row pointer
    lda ZP_PTR_HI
    sta ZP_SPR_HI
    lda #<doodle_dbuf
    sta ZP_PTR_LO           // ZP_PTR = dbuf row pointer
    lda #>doodle_dbuf
    sta ZP_PTR_HI
    ldx doodle_row          // X = screen row
    lda #21
    sta dd_rows

ddo_row:
    lda hgr_row_lo,x
    clc
    adc doodle_col
    sta ZP_TMP
    lda hgr_row_hi,x
    adc #0
    sta ZP_TMP2

    ldy #3
ddo_col:
    lda (ZP_PTR_LO),y       // dilated mask byte
    eor #$FF
    and (ZP_TMP),y          // clear the silhouette to black (keeps palette bit)
    sta (ZP_TMP),y
    lda (ZP_SPR_LO),y       // draw the doodle on top
    ora (ZP_TMP),y
    sta (ZP_TMP),y
    dey
    bpl ddo_col

    lda ZP_PTR_LO
    clc
    adc #4
    sta ZP_PTR_LO
    bcc ddo_dbuf_nc
    inc ZP_PTR_HI
ddo_dbuf_nc:
    lda ZP_SPR_LO
    clc
    adc #4
    sta ZP_SPR_LO
    bcc ddo_spr_nc
    inc ZP_SPR_HI
ddo_spr_nc:
    inx
    dec dd_rows
    bne ddo_row
    rts

// ─── hdil ─────────────────────────────────────────────────────
// Horizontally dilate one HGR byte by 1 pixel.
// In:  dd_cur = centre byte, dd_left / dd_right = neighbour bytes (0 if none).
// Out: A = dilated byte.  Trashes A, dd_tmp.
hdil:
    lda dd_cur
    asl
    sta dd_tmp
    lda dd_cur
    lsr
    ora dd_tmp
    ora dd_cur
    and #$7F                // in-byte spread, keep pixel bits 0-6
    sta dd_tmp
    lda dd_left
    and #$40                // left neighbour's rightmost pixel ...
    beq hdil_no_left
    lda dd_tmp
    ora #$01                // ... spreads into this byte's bit0
    sta dd_tmp
hdil_no_left:
    lda dd_right
    and #$01                // right neighbour's leftmost pixel ...
    beq hdil_no_right
    lda dd_tmp
    ora #$40                // ... spreads into this byte's bit6
    sta dd_tmp
hdil_no_right:
    lda dd_tmp
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

// ─── draw_big_sprite ──────────────────────────────────────────
// Draw a 42-row × 8-byte big-circle sprite at (big_spr_col, big_spr_row).
// Caller sets ZP_PTR_LO/HI to the source sprite (e.g. big_circle_red,
// big_circle_blue, …) before calling.
// big_spr_col must be 0-32; big_spr_row must be 0-117 for mixed-mode HGR.
// Colors are correct only when big_spr_col is EVEN (HGR chroma phase).
// Trashes A, X, Y, ZP_TMP, ZP_TMP2, ZP_TMP3, ZP_SPR_LO/HI.
draw_big_sprite:
    lda ZP_PTR_LO
    sta ZP_SPR_LO
    lda ZP_PTR_HI
    sta ZP_SPR_HI
    ldx big_spr_row
    lda #0
    sta ZP_TMP3
dbs_row:
    lda hgr_row_lo,x
    clc
    adc big_spr_col
    sta ZP_TMP
    lda hgr_row_hi,x
    adc #0
    sta ZP_TMP2
    ldy #7
dbs_col:
    lda (ZP_SPR_LO),y
    sta (ZP_TMP),y
    dey
    bpl dbs_col
    lda ZP_SPR_LO
    clc
    adc #8
    sta ZP_SPR_LO
    bcc dbs_no_carry
    inc ZP_SPR_HI
dbs_no_carry:
    inc ZP_TMP3
    lda ZP_TMP3
    cmp #42
    beq dbs_done
    inx
    jmp dbs_row
dbs_done:
    rts

// ─── erase_big_sprite ─────────────────────────────────────────
// Write $00 over 42 rows × 8 bytes at (big_spr_col, big_spr_row).
// Trashes A, X, Y, ZP_TMP, ZP_TMP2, ZP_TMP3.
erase_big_sprite:
    ldx big_spr_row
    lda #0
    sta ZP_TMP3
ebs_row:
    lda hgr_row_lo,x
    clc
    adc big_spr_col
    sta ZP_TMP
    lda hgr_row_hi,x
    adc #0
    sta ZP_TMP2
    ldy #7
ebs_col:
    lda #$00
    sta (ZP_TMP),y
    dey
    bpl ebs_col
    inc ZP_TMP3
    lda ZP_TMP3
    cmp #42
    beq ebs_done
    inx
    jmp ebs_row
ebs_done:
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
