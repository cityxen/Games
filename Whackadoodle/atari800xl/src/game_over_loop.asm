#importonce
// ============================================================
// Game over loop (Atari 800XL)
//
// Shows GAME OVER! on TXT_LINE0, SCORE:XX on TXT_LINE1,
// PRESS FIRE on TXT_LINE3.
// Auto-returns to attract after TIMER_GAMEOVER fires.
// Pressing fire also returns immediately.
// ============================================================

game_over:

    jsr erase_doodle_sprite
    jsr gfx_clear

    // GAME OVER! on row 0
    ldy #0
    PutChar('G', TXT_LINE0)
    PutChar('A', TXT_LINE0)
    PutChar('M', TXT_LINE0)
    PutChar('E', TXT_LINE0)
    PutSpc(TXT_LINE0)
    PutChar('O', TXT_LINE0)
    PutChar('V', TXT_LINE0)
    PutChar('E', TXT_LINE0)
    PutChar('R', TXT_LINE0)
    PutChar('!', TXT_LINE0)

    // SCORE:XX on row 1
    ldy #0
    PutChar('S', TXT_LINE1)
    PutChar('C', TXT_LINE1)
    PutChar('O', TXT_LINE1)
    PutChar('R', TXT_LINE1)
    PutChar('E', TXT_LINE1)
    PutChar(':', TXT_LINE1)
    PutSpc(TXT_LINE1)

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
    clc
    adc #SC('0')
    sta TXT_LINE1,y
    iny
    pla
    clc
    adc #SC('0')
    sta TXT_LINE1,y

    // PRESS FIRE on row 3
    ldy #0
    PutChar('P', TXT_LINE3)
    PutChar('R', TXT_LINE3)
    PutChar('E', TXT_LINE3)
    PutChar('S', TXT_LINE3)
    PutChar('S', TXT_LINE3)
    PutSpc(TXT_LINE3)
    PutChar('F', TXT_LINE3)
    PutChar('I', TXT_LINE3)
    PutChar('R', TXT_LINE3)
    PutChar('E', TXT_LINE3)

    jsr beep

    ResetTimerFired(TIMER_GAMEOVER)
    ResetTimer(TIMER_GAMEOVER)

game_over_loop:
    jsr wait_vbl
    jsr update_timers
    jsr read_joystick

    lda joy_fired
    bne go_restart

    GetTimerFired(TIMER_GAMEOVER)
    beq game_over_loop
go_restart:
    ResetTimerFired(TIMER_GAMEOVER)
    jmp main_loop_start
