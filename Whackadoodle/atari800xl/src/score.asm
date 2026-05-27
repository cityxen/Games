#importonce
// ============================================================
// Score / Lives display in the text area (4 rows at TXT_SCREEN)
//
// SC(c) is defined in config.asm: screen_code = ATASCII_char - $20
//   Space = 0,  '0' = $10,  'A' = $21,  ':' = $1A
//
// Text rows in mixed-mode display (4 rows × 40 chars):
//   Row 0 (TXT_LINE0): SCORE:XX  LIVES:X  MODE:XXXXXX
//   Row 1 (TXT_LINE1): in-game messages (GET READY / MISS / etc.)
//   Row 2 (TXT_LINE2): (spare)
//   Row 3 (TXT_LINE3): attract: >> FIRE TO START <<
// ============================================================

// ─── draw_score_line ─────────────────────────────────────────
// Write "SCORE:XX  LIVES:X  MODE:XXXXXX" to TXT_LINE0.
// Trashes A, X, Y.
draw_score_line:
    ldy #0

    lda #SC('S')
    sta TXT_LINE0,y
    iny
    lda #SC('C')
    sta TXT_LINE0,y
    iny
    lda #SC('O')
    sta TXT_LINE0,y
    iny
    lda #SC('R')
    sta TXT_LINE0,y
    iny
    lda #SC('E')
    sta TXT_LINE0,y
    iny
    lda #SC(':')
    sta TXT_LINE0,y
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
    pha                         // save ones digit
    txa
    clc
    adc #SC('0')
    sta TXT_LINE0,y
    iny
    pla
    clc
    adc #SC('0')
    sta TXT_LINE0,y
    iny

    lda #0
    sta TXT_LINE0,y
    iny
    lda #0
    sta TXT_LINE0,y
    iny

    lda #SC('L')
    sta TXT_LINE0,y
    iny
    lda #SC('I')
    sta TXT_LINE0,y
    iny
    lda #SC('V')
    sta TXT_LINE0,y
    iny
    lda #SC('E')
    sta TXT_LINE0,y
    iny
    lda #SC('S')
    sta TXT_LINE0,y
    iny
    lda #SC(':')
    sta TXT_LINE0,y
    iny

    // Lives: two digits (omit leading zero)
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
    clc
    adc #SC('0')
    sta TXT_LINE0,y
    iny
    jmp dsl_lv_digit
dsl_lv_skip_tens:
    lda #0                      // leading space
    sta TXT_LINE0,y
    iny
dsl_lv_digit:
    pla
    clc
    adc #SC('0')
    sta TXT_LINE0,y
    iny

    lda #0
    sta TXT_LINE0,y
    iny
    lda #0
    sta TXT_LINE0,y
    iny

    lda #SC('M')
    sta TXT_LINE0,y
    iny
    lda #SC('O')
    sta TXT_LINE0,y
    iny
    lda #SC('D')
    sta TXT_LINE0,y
    iny
    lda #SC('E')
    sta TXT_LINE0,y
    iny
    lda #SC(':')
    sta TXT_LINE0,y
    iny

    lda whack_mode
    cmp #MODE_EASY
    beq dsl_easy
    cmp #MODE_HARD
    beq dsl_hard

    lda #SC('N')
    sta TXT_LINE0,y
    iny
    lda #SC('O')
    sta TXT_LINE0,y
    iny
    lda #SC('R')
    sta TXT_LINE0,y
    iny
    lda #SC('M')
    sta TXT_LINE0,y
    iny
    lda #SC('A')
    sta TXT_LINE0,y
    iny
    lda #SC('L')
    sta TXT_LINE0,y
    rts

dsl_easy:
    lda #SC('E')
    sta TXT_LINE0,y
    iny
    lda #SC('A')
    sta TXT_LINE0,y
    iny
    lda #SC('S')
    sta TXT_LINE0,y
    iny
    lda #SC('Y')
    sta TXT_LINE0,y
    iny
    lda #0
    sta TXT_LINE0,y
    iny
    lda #0
    sta TXT_LINE0,y
    rts

dsl_hard:
    lda #SC('H')
    sta TXT_LINE0,y
    iny
    lda #SC('A')
    sta TXT_LINE0,y
    iny
    lda #SC('R')
    sta TXT_LINE0,y
    iny
    lda #SC('D')
    sta TXT_LINE0,y
    iny
    lda #0
    sta TXT_LINE0,y
    iny
    lda #0
    sta TXT_LINE0,y
    rts

// ─── clear_message_row ───────────────────────────────────────
// Blank TXT_LINE1 (40 spaces, screen code 0).
clear_message_row:
    ldy #39
    lda #0
cmr_loop:
    sta TXT_LINE1,y
    dey
    bpl cmr_loop
    rts

// ─── draw_message_row ────────────────────────────────────────
// Write $FF-terminated Atari screen-code string to TXT_LINE1.
// ZP_PTR_LO/HI → string.
draw_message_row:
    ldy #0
dmr_loop:
    lda (ZP_PTR_LO),y
    cmp #$FF            // $FF = null terminator (0 = space, not null)
    beq dmr_done
    sta TXT_LINE1,y
    iny
    cpy #40
    bne dmr_loop
dmr_done:
    rts
