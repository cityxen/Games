#importonce
// ============================================================
// In-game message display (text row 21, visible in mixed mode)
//
// message values:
//   0 = none
//   1 = GET READY
//   2 = MISS
//   3 = POW
//   4 = WRONG!
// ============================================================

// Apple II ASCII strings (bit 7 set, null-terminated with $00)
msg_getready:   .byte 'G'|$80,'E'|$80,'T'|$80,' '|$80,'R'|$80,'E'|$80,'A'|$80,'D'|$80,'Y'|$80,'!'|$80,0
msg_miss:       .byte ' '|$80,' '|$80,' '|$80,'M'|$80,'I'|$80,'S'|$80,'S'|$80,' '|$80,' '|$80,' '|$80,0
msg_pow:        .byte ' '|$80,' '|$80,' '|$80,'P'|$80,'O'|$80,'W'|$80,'!'|$80,' '|$80,' '|$80,' '|$80,0
msg_wrong:      .byte ' '|$80,' '|$80,'W'|$80,'R'|$80,'O'|$80,'N'|$80,'G'|$80,'!'|$80,' '|$80,' '|$80,0

// ─── set_message ──────────────────────────────────────────────
// A = message index (1-4).  Stores it and resets message timer.
set_message:
    sta message
    ResetTimerFired(TIMER_MESSAGE)
    ResetTimer(TIMER_MESSAGE)
    rts

// ─── show_message ─────────────────────────────────────────────
// If message != 0: display it on row 21.
// When timer fires: clear message and redraw score.
// Call every frame from game_loop.
show_message:
    lda message
    beq sm_done             // no active message

    // Point ZP_PTR at appropriate string
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
    // Timer expired — clear message
    ResetTimerFired(TIMER_MESSAGE)
    lda #0
    sta message
    jsr clear_message_row
    jsr draw_score_line
sm_done:
    rts
