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
    lda #0
    sta message_drawn       // not yet shown -> show_message will draw it
    ResetTimerFired(TIMER_MESSAGE)
    ResetTimer(TIMER_MESSAGE)
    rts

// ─── show_message ─────────────────────────────────────────────
// If message != 0: swap to full text mode and show it centered.
// When timer fires: switch back to the play screen and continue.
// Call every frame from game_loop.
//
// The message is drawn once (guarded by message_drawn) so the screen
// isn't cleared and repainted every frame.  All four messages are 10
// chars, so they centre at text row 11, column 15.
show_message:
    lda message
    beq sm_done             // no active message

    lda message_drawn
    bne sm_check_timer      // already on screen — just poll the timer

    // Swap to full 40x24 text mode and clear, then draw the message centered
    bit TXT_ON
    jsr ROM_HOME

    // Point ZP_PTR at appropriate string
    lda message
    cmp #1
    bne sm_try2
    lda #<msg_getready
    sta ZP_PTR_LO
    lda #>msg_getready
    sta ZP_PTR_HI
    jmp sm_draw
sm_try2:
    cmp #2
    bne sm_try3
    lda #<msg_miss
    sta ZP_PTR_LO
    lda #>msg_miss
    sta ZP_PTR_HI
    jmp sm_draw
sm_try3:
    cmp #3
    bne sm_try4
    lda #<msg_pow
    sta ZP_PTR_LO
    lda #>msg_pow
    sta ZP_PTR_HI
    jmp sm_draw
sm_try4:
    lda #<msg_wrong
    sta ZP_PTR_LO
    lda #>msg_wrong
    sta ZP_PTR_HI

sm_draw:
    ldx #11                 // middle row
    lda #15                 // (40 - 10) / 2 = centered
    jsr print_at
    lda #1
    sta message_drawn

sm_check_timer:
    GetTimerFired(TIMER_MESSAGE)
    beq sm_done
    // Timer expired — clear message and return to the play screen.
    // HGR still holds the buttons + active doodle, so just re-enable
    // graphics and repaint the score line (ROM_HOME wiped the text page).
    ResetTimerFired(TIMER_MESSAGE)
    lda #0
    sta message
    sta message_drawn
    jsr hgr_init
    jsr draw_score_line
sm_done:
    rts
