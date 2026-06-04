
// ─── KickAssembler helper: emit null-terminated Apple-ASCII string ─
// Each character has bit 7 set (normal white-on-black display).
.macro applestr(s) {
    .for (var i = 0; i < s.size(); i++) {
        .byte s.charAt(i) | $80
    }
    .byte 0
}

// ─── KickAssembler helper: load ZP_PTR and call print_at ──────
.macro PrintLine(str, row, col) {
    lda #<str
    sta ZP_PTR_LO
    lda #>str
    sta ZP_PTR_HI
    ldx #row
    lda #col
    jsr print_at
}

// ─── Draw a big-circle sprite of a given color at (col, row) ──
// sprite = a big_circle_* label; col 0-32 (even for correct color), row 0-117.
.macro DrawBigCircle(sprite, button) {
    .var col=0
    .var row=0

    .if(button == BUTTON_RED) { 
        .eval col = BUTT0_COL
        .eval row = BUTT0_ROW
    }
    .if(button == BUTTON_GREEN) { 
        .eval col = BUTT1_COL
        .eval row = BUTT1_ROW
    }
    .if(button == BUTTON_PURPLE) { 
        .eval col = BUTT2_COL
        .eval row = BUTT2_ROW
    }
    .if(button == BUTTON_BLUE) { 
        .eval col = BUTT3_COL
        .eval row = BUTT3_ROW
    }
    .if(button == BUTTON_WHITE) { 
        .eval  col = BUTT4_COL
        .eval row = BUTT4_ROW
    }

    lda #<sprite
    sta ZP_PTR_LO
    lda #>sprite
    sta ZP_PTR_HI

    lda #col
    sta big_spr_col

    lda #row
    sta big_spr_row

    jsr draw_big_sprite
}

// ─── Overlay a doodle (0-7) centered on a big circle at (col, row) ──
// Draws the doodle with OR-blit so the circle/button shows around it.
// The doodle (4 bytes x 21 rows) is centered in the circle (8 x 42):
//   doodle_col = col+2, doodle_row = row+10.
.macro OverlayDoodle(sprite, button) {
    .var col=0
    .var row=0

    .if(button == BUTTON_RED) { 
        .eval col = BUTT0_COL
        .eval row = BUTT0_ROW
    }
    .if(button == BUTTON_GREEN) { 
        .eval col = BUTT1_COL
        .eval row = BUTT1_ROW
    }
    .if(button == BUTTON_PURPLE) { 
        .eval col = BUTT2_COL
        .eval row = BUTT2_ROW
    }
    .if(button == BUTTON_BLUE) { 
        .eval col = BUTT3_COL
        .eval row = BUTT3_ROW
    }
    .if(button == BUTTON_WHITE) { 
        .eval  col = BUTT4_COL
        .eval row = BUTT4_ROW
    }

    lda #sprite
    jsr set_sprite_ptr          // ZP_PTR_LO/HI = doodle data address
    lda #col + 2
    sta doodle_col
    lda #row + 10
    sta doodle_row
    jsr draw_doodle_or
}

.macro OverlayDoodleA(button) {
    .var col=0
    .var row=0

    .if(button == BUTTON_RED) { 
        .eval col = BUTT0_COL
        .eval row = BUTT0_ROW
    }
    .if(button == BUTTON_GREEN) { 
        .eval col = BUTT1_COL
        .eval row = BUTT1_ROW
    }
    .if(button == BUTTON_PURPLE) { 
        .eval col = BUTT2_COL
        .eval row = BUTT2_ROW
    }
    .if(button == BUTTON_BLUE) { 
        .eval col = BUTT3_COL
        .eval row = BUTT3_ROW
    }
    .if(button == BUTTON_WHITE) { 
        .eval  col = BUTT4_COL
        .eval row = BUTT4_ROW
    }

    // lda #sprite
    jsr set_sprite_ptr          // ZP_PTR_LO/HI = doodle data address
    lda #col + 2
    sta doodle_col
    lda #row + 10
    sta doodle_row
    jsr draw_doodle_or
}

.macro DrawDoodle(sprite, sx, sy) {
    lda #sprite
    jsr set_sprite_ptr          // ZP_PTR_LO/HI = doodle data address
    lda #sx
    sta doodle_col
    lda #sy
    sta doodle_row
    jsr draw_doodle_or
}

// ─── print_at ─────────────────────────────────────────────────
// Write a null-terminated Apple-ASCII string to the text screen.
// In:  X  = row (0-23)
//      A  = starting column (0-39)
//      ZP_PTR_LO/HI = pointer to string
// ZP_TMP ($08) / ZP_TMP2 ($09) used as destination ptr (clobbered).
// ZP_TMP3 ($0A) used to save column (clobbered).
// Y = string/column offset; starts at 0 (clobbered).
print_at:
    sta ZP_TMP3
    lda txt_row_lo,x
    clc
    adc ZP_TMP3
    sta ZP_TMP
    lda txt_row_hi,x
    adc #0
    sta ZP_TMP2
    ldy #0
pa_loop:
    lda (ZP_PTR_LO),y
    beq pa_done
    sta (ZP_TMP),y
    iny
    bne pa_loop
pa_done:
    rts


randomly_flash_buttons:
    rts