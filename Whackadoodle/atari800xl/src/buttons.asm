#importonce
// ============================================================
// Player/Missile colored "button" circles (Atari 800XL)
//
// Five filled circles, one behind each of the 5 doodle slots,
// each ~2.5x the doodle size (quad-width = ~64 px wide).
//
//   slot 0 -> Player 0   RED
//   slot 1 -> Player 1   GREEN
//   slot 2 -> Player 2   YELLOW
//   slot 3 -> Player 3   BLUE
//   slot 4 -> Missiles (5th player, COLPF3)  WHITE
//
// Circles sit BEHIND the GR.8 doodles (playfield-over-players
// priority), so each white doodle shows on top of its circle.
//
// Single-line P/M resolution: one strip byte = one scan line.
// ============================================================

// GFX slot row -> P/M strip byte. Tuned so the 52-row circle is
// roughly centred on the 21-row doodle at that slot.
.const PM_VOFF   = 16
.const CIRCLE_H  = 52

// Per-slot horizontal position (color clocks) — left edge of the
// 32-color-clock-wide circle, centred on each doodle column.
btn_hpos:  .byte 42, 74, 106, 138, 170

// Per-slot P/M strip byte where the circle starts.
btn_pm_y:  .byte BUTT0_ROW+PM_VOFF, BUTT1_ROW+PM_VOFF, BUTT2_ROW+PM_VOFF, BUTT3_ROW+PM_VOFF, BUTT4_ROW+PM_VOFF

// 8-bit-wide filled circle, 52 rows (bit 7 = leftmost cell).
circle_bitmap:
    .byte %00011000, %00011000, %00011000               // rows 0-2
    .byte %00111100, %00111100, %00111100               // rows 3-5
    .byte %01111110, %01111110, %01111110, %01111110    // rows 6-9
    .byte %11111111, %11111111, %11111111, %11111111    // rows 10-41
    .byte %11111111, %11111111, %11111111, %11111111
    .byte %11111111, %11111111, %11111111, %11111111
    .byte %11111111, %11111111, %11111111, %11111111
    .byte %11111111, %11111111, %11111111, %11111111
    .byte %11111111, %11111111, %11111111, %11111111
    .byte %11111111, %11111111, %11111111, %11111111
    .byte %11111111, %11111111, %11111111, %11111111
    .byte %01111110, %01111110, %01111110, %01111110    // rows 42-45
    .byte %00111100, %00111100, %00111100               // rows 46-48
    .byte %00011000, %00011000, %00011000               // rows 49-51

// ─── pmg_init ────────────────────────────────────────────────
// One-time Player/Missile setup: memory base, widths, colors,
// positions, priority, and DMA enable.  Call after gfx_init.
pmg_init:
    jsr clear_pm_strips

    lda #>PMG_BASE         // P/M memory page ($60)
    sta PMBASE

    lda #$03               // quad width for each player (bits 1-0)
    sta SIZEP0
    sta SIZEP1
    sta SIZEP2
    sta SIZEP3
    lda #$FF               // quad width for all 4 missiles (2 bits each)
    sta SIZEM

    lda #COL_RED
    sta PCOLR0
    lda #COL_GREEN
    sta PCOLR1
    lda #COL_YELLOW
    sta PCOLR2
    lda #COL_BLUE
    sta PCOLR3
    lda #COL_WHITE
    sta COLOR3             // COLPF3 = 5th-player (missile) color

    lda btn_hpos+0
    sta HPOSP0
    lda btn_hpos+1
    sta HPOSP1
    lda btn_hpos+2
    sta HPOSP2
    lda btn_hpos+3
    sta HPOSP3

    // Four quad-width missiles, 8 color clocks apart, form slot 4.
    // M3 = leftmost (bits 7-6) ... M0 = rightmost (bits 1-0).
    lda btn_hpos+4
    sta HPOSM3
    clc
    adc #8
    sta HPOSM2
    adc #8
    sta HPOSM1
    adc #8
    sta HPOSM0

    // In GR.8 (ANTIC mode F / hi-res) the playfield LUMINANCE always
    // overlays players, so we give players priority over the playfield
    // ($01): the colored circle shows, and the white doodle drawn in the
    // bitmap still appears on top.  Plus $10 enables the 5th player.
    lda #$11
    sta GPRIOR

    lda #$3E               // DMACTL: DL + normal PF + 1-line P/M + P + M
    sta SDMCTL

    lda #$03               // GRACTL: enable player + missile DMA
    sta GRACTL
    rts

// ─── draw_circles ────────────────────────────────────────────
// Render all 5 circles into the P/M strips at their slot rows.
// Clears the strips first so previous content is removed.
draw_circles:
    jsr clear_pm_strips

    lda btn_pm_y+0
    sta ZP_PTR_LO
    lda #>PM_PLAYER0
    sta ZP_PTR_HI
    jsr write_circle

    lda btn_pm_y+1
    sta ZP_PTR_LO
    lda #>PM_PLAYER1
    sta ZP_PTR_HI
    jsr write_circle

    lda btn_pm_y+2
    sta ZP_PTR_LO
    lda #>PM_PLAYER2
    sta ZP_PTR_HI
    jsr write_circle

    lda btn_pm_y+3
    sta ZP_PTR_LO
    lda #>PM_PLAYER3
    sta ZP_PTR_HI
    jsr write_circle

    lda btn_pm_y+4
    sta ZP_PTR_LO
    lda #>PM_MISSILE
    sta ZP_PTR_HI
    jsr write_circle
    rts

// ─── clear_circles ───────────────────────────────────────────
// Hide all circles (used on text/instruction screens).
clear_circles:
    jmp clear_pm_strips

// ─── write_circle ────────────────────────────────────────────
// Copy CIRCLE_H bytes of circle_bitmap to (ZP_PTR_LO/HI).
// ZP_PTR points at strip_base + slot Y (strips are page-aligned,
// so ZP_PTR_LO = Y offset and ZP_PTR_HI = strip page).
write_circle:
    ldy #CIRCLE_H-1
wc_loop:
    lda circle_bitmap,y
    sta (ZP_PTR_LO),y
    dey
    bpl wc_loop
    rts

// ─── clear_pm_strips ─────────────────────────────────────────
// Zero the missile + 4 player strips ($6300-$67FF = 5 pages).
clear_pm_strips:
    lda #<PM_MISSILE       // $00
    sta ZP_PTR_LO
    lda #>PM_MISSILE       // $63
    sta ZP_PTR_HI
    ldx #5
    ldy #0
    lda #0
cps_loop:
    sta (ZP_PTR_LO),y
    iny
    bne cps_loop
    inc ZP_PTR_HI
    dex
    bne cps_loop
    rts
