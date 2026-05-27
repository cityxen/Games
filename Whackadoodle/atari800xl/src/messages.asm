#importonce
// ============================================================
// In-game message display (TXT_LINE1, visible in mixed mode)
//
// message values:
//   0 = none
//   1 = GET READY
//   2 = MISS
//   3 = POW
//   4 = WRONG!
//
// Atari screen codes: char - $20 (null-terminated with $00).
// ============================================================

// Atari screen-code strings ($FF-terminated; 0 = space screen code, not null)
msg_getready:
    .byte SC('G'),SC('E'),SC('T'),0,SC('R'),SC('E'),SC('A'),SC('D'),SC('Y'),SC('!'),$FF
msg_miss:
    .byte 0,0,0,SC('M'),SC('I'),SC('S'),SC('S'),0,0,0,$FF
msg_pow:
    .byte 0,0,0,SC('P'),SC('O'),SC('W'),SC('!'),0,0,0,$FF
msg_wrong:
    .byte 0,0,SC('W'),SC('R'),SC('O'),SC('N'),SC('G'),SC('!'),0,0,$FF

// ─── set_message ─────────────────────────────────────────────
// A = message index (1-4).  Stores it and resets message timer.
set_message:
    sta message
    ResetTimerFired(TIMER_MESSAGE)
    ResetTimer(TIMER_MESSAGE)
    rts

// ─── show_message ────────────────────────────────────────────
// If message != 0: display it on TXT_LINE1.
// When timer fires: clear message and redraw score.
// Call every frame from game_loop.
show_message:
    lda message
    beq sm_done

    cmp #1
    bne sm_try2
    lda #<msg_getready
    sta ZP_PTR_LO
    lda #>msg_getready
    sta ZP_PTR_HI
    jsr draw_message_row
    jmp sm_check_timer
sm_try2:
    cmp #2
    bne sm_try3
    lda #<msg_miss
    sta ZP_PTR_LO
    lda #>msg_miss
    sta ZP_PTR_HI
    jsr draw_message_row
    jmp sm_check_timer
sm_try3:
    cmp #3
    bne sm_try4
    lda #<msg_pow
    sta ZP_PTR_LO
    lda #>msg_pow
    sta ZP_PTR_HI
    jsr draw_message_row
    jmp sm_check_timer
sm_try4:
    lda #<msg_wrong
    sta ZP_PTR_LO
    lda #>msg_wrong
    sta ZP_PTR_HI
    jsr draw_message_row

sm_check_timer:
    GetTimerFired(TIMER_MESSAGE)
    beq sm_done
    ResetTimerFired(TIMER_MESSAGE)
    lda #0
    sta message
    jsr clear_message_row
    jsr draw_score_line
sm_done:
    rts
