#importonce
// ============================================================
// Score / Lives display in the text area (mixed-mode rows 20-23)
//
// Apple IIe text page 1 line addresses (rows visible in mixed mode):
//   Row 20: $0650    Row 21: $06D0
//   Row 22: $0750    Row 23: $07D0
//
// Characters use Apple II ASCII: set bit 7 for normal (white) display.
// ============================================================

.const TXT_LINE20 = $0650
.const TXT_LINE21 = $06D0
.const TXT_LINE22 = $0750
.const TXT_LINE23 = $07D0

// --- draw_score_line -----------------------------------------
// Write score and lives to text row 20.
// Format:  SCORE:XX  LIVES:X  MODE:XXXXXX
// Trashes A, X, Y.
draw_score_line:
    ldy #0

    lda #('S'|$80)
    sta TXT_LINE20,y
    iny
    lda #('C'|$80)
    sta TXT_LINE20,y
    iny
    lda #('O'|$80)
    sta TXT_LINE20,y
    iny
    lda #('R'|$80)
    sta TXT_LINE20,y
    iny
    lda #('E'|$80)
    sta TXT_LINE20,y
    iny
    lda #(':'|$80)
    sta TXT_LINE20,y
    iny

    // Score tens digit
    lda score
    ldx #0
dsl_tens:
    cmp #10
    bcc dsl_tens_done
    sbc #10
    inx
    jmp dsl_tens
dsl_tens_done:
    pha                     // save ones
    txa
    ora #('0'|$80)
    sta TXT_LINE20,y
    iny
    pla
    ora #('0'|$80)
    sta TXT_LINE20,y
    iny

    lda #(' '|$80)
    sta TXT_LINE20,y
    iny
    lda #(' '|$80)
    sta TXT_LINE20,y
    iny
    lda #('L'|$80)
    sta TXT_LINE20,y
    iny
    lda #('I'|$80)
    sta TXT_LINE20,y
    iny
    lda #('V'|$80)
    sta TXT_LINE20,y
    iny
    lda #('E'|$80)
    sta TXT_LINE20,y
    iny
    lda #('S'|$80)
    sta TXT_LINE20,y
    iny
    lda #(':'|$80)
    sta TXT_LINE20,y
    iny

    // Lives digit
    lda whack_life
    ldx #0
dsl_lv_tens:
    cmp #10
    bcc dsl_lv_ones
    sbc #10
    inx
    jmp dsl_lv_tens
dsl_lv_ones:
    pha
    txa
    beq dsl_lv_skip_tens
    ora #('0'|$80)
    sta TXT_LINE20,y
    iny
    jmp dsl_lv_digit
dsl_lv_skip_tens:
    lda #(' '|$80)
    sta TXT_LINE20,y
    iny
dsl_lv_digit:
    pla
    ora #('0'|$80)
    sta TXT_LINE20,y
    iny

    lda #(' '|$80)
    sta TXT_LINE20,y
    iny
    lda #(' '|$80)
    sta TXT_LINE20,y
    iny
    lda #('M'|$80)
    sta TXT_LINE20,y
    iny
    lda #('O'|$80)
    sta TXT_LINE20,y
    iny
    lda #('D'|$80)
    sta TXT_LINE20,y
    iny
    lda #('E'|$80)
    sta TXT_LINE20,y
    iny
    lda #(':'|$80)
    sta TXT_LINE20,y
    iny

    lda whack_mode
    cmp #MODE_EASY
    beq dsl_easy
    cmp #MODE_HARD
    beq dsl_hard

    lda #('N'|$80)
    sta TXT_LINE20,y
    iny
    lda #('O'|$80)
    sta TXT_LINE20,y
    iny
    lda #('R'|$80)
    sta TXT_LINE20,y
    iny
    lda #('M'|$80)
    sta TXT_LINE20,y
    iny
    lda #('A'|$80)
    sta TXT_LINE20,y
    iny
    lda #('L'|$80)
    sta TXT_LINE20,y
    rts

dsl_easy:
    lda #('E'|$80)
    sta TXT_LINE20,y
    iny
    lda #('A'|$80)
    sta TXT_LINE20,y
    iny
    lda #('S'|$80)
    sta TXT_LINE20,y
    iny
    lda #('Y'|$80)
    sta TXT_LINE20,y
    iny
    lda #(' '|$80)
    sta TXT_LINE20,y
    iny
    lda #(' '|$80)
    sta TXT_LINE20,y
    rts

dsl_hard:
    lda #('H'|$80)
    sta TXT_LINE20,y
    iny
    lda #('A'|$80)
    sta TXT_LINE20,y
    iny
    lda #('R'|$80)
    sta TXT_LINE20,y
    iny
    lda #('D'|$80)
    sta TXT_LINE20,y
    iny
    lda #(' '|$80)
    sta TXT_LINE20,y
    iny
    lda #(' '|$80)
    sta TXT_LINE20,y
    rts

// --- clear_message_row ---------------------------------------
// Blank text row 21.
clear_message_row:
    ldy #39
    lda #(' '|$80)
cmr_loop:
    sta TXT_LINE21,y
    dey
    bpl cmr_loop
    rts

// --- draw_message_row ----------------------------------------
// Write a null-terminated Apple ASCII string to row 21.
// ZP_PTR_LO/HI -> string (chars with bit 7 already set).
draw_message_row:
    ldy #0
dmr_loop:
    lda (ZP_PTR_LO),y
    beq dmr_done
    sta TXT_LINE21,y
    iny
    cpy #40
    bne dmr_loop
dmr_done:
    rts
