#importonce
// ============================================================
// Game over loop
// Shows GAME OVER on text row 21, score on row 22.
// Auto-returns to attract after ~12 seconds (TIMER_GAMEOVER).
// Pressing fire also returns immediately.
// ============================================================

msg_gameover:   .byte 'G'|$80,'A'|$80,'M'|$80,'E'|$80,' '|$80,'O'|$80,'V'|$80,'E'|$80,'R'|$80,'!'|$80,0
msg_press_fire: .byte 'P'|$80,'R'|$80,'E'|$80,'S'|$80,'S'|$80,' '|$80,'F'|$80,'I'|$80,'R'|$80,'E'|$80,0

game_over:

    jsr erase_doodle_sprite
    jsr hgr_clear

    // Print GAME OVER on row 21
    lda #<msg_gameover
    sta ZP_PTR_LO
    lda #>msg_gameover
    sta ZP_PTR_HI
    jsr draw_message_row

    // Print SCORE:XX on row 22
    ldy #0
    lda #('S'|$80)
    sta TXT_LINE22,y
    iny
    lda #('C'|$80)
    sta TXT_LINE22,y
    iny
    lda #('O'|$80)
    sta TXT_LINE22,y
    iny
    lda #('R'|$80)
    sta TXT_LINE22,y
    iny
    lda #('E'|$80)
    sta TXT_LINE22,y
    iny
    lda #(':'|$80)
    sta TXT_LINE22,y
    iny
    lda #(' '|$80)
    sta TXT_LINE22,y
    iny

    // Score tens digit
    lda score
    ldx #0
go_tens:
    cmp #10
    bcc go_ones
    sbc #10
    inx
    jmp go_tens
go_ones:
    pha
    txa
    ora #('0'|$80)
    sta TXT_LINE22,y
    iny
    pla
    ora #('0'|$80)
    sta TXT_LINE22,y

    // Print PRESS FIRE on row 23
    ldy #0
go_pf_loop:
    lda msg_press_fire,y
    beq go_pf_done
    sta TXT_LINE23,y
    iny
    cpy #40
    bne go_pf_loop
go_pf_done:

    jsr beep

    // Reset game-over timer
    ResetTimerFired(TIMER_GAMEOVER)
    ResetTimer(TIMER_GAMEOVER)

game_over_loop:
    jsr wait_vbl
    jsr update_timers
    jsr read_joystick

    // Fire button -> restart immediately
    lda joy_btn
    bne go_restart

    // Auto-return after timer expires
    GetTimerFired(TIMER_GAMEOVER)
    beq game_over_loop
go_restart:
    ResetTimerFired(TIMER_GAMEOVER)
    jmp main_loop_start
