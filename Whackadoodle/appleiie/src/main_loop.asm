#importonce
// ============================================================
// Main / attract loop
//
// Switches to full 40x24 text mode and shows a complete
// title + instruction screen.  Joystick selects difficulty;
// FIRE starts the game.
// ============================================================

// ─── main_loop_start ─────────────────────────────────────────

main_loop_start:
restart:

    // Reset attract flash timer (drives external LED hardware)
    ResetTimerFired(TIMER_FLASH)
    ResetTimer(TIMER_FLASH)

    // Rotate Attract Screen
    ResetTimerFired(TIMER_SCREEN)
    ResetTimer(TIMER_SCREEN)

    jsr draw_screen_main

main_loop:

    GetTimer(TIMER_SCREEN)
    PrintHex(0,0)
    GetTimerFired(TIMER_SCREEN)
    PrintHex(4,0)

    jsr wait_vbl
    jsr update_timers
    jsr read_joystick

    // Check for flashing button lights timers
    GetTimerFired(TIMER_FLASH)
    cmp #$02
    bne !++
    ResetTimerFired(TIMER_FLASH)
    ResetTimer(TIMER_FLASH)
    jsr randomly_flash_buttons
!:

    // Check for screen change timers
    GetTimerFired(TIMER_SCREEN)
    cmp #$05
    bne ml_scr_check_out
    ResetTimerFired(TIMER_SCREEN)
    ResetTimer(TIMER_SCREEN)
    jsr inc_screen_draw
    jsr ml_draw_screen
ml_scr_check_out:


    // Mode selection: left (0-1)=EASY, center (2)=NORMAL, right (3-4)=HARD
    lda joy_slot
    cmp #2
    bcc ml_select_easy
    beq ml_select_normal
    lda #MODE_HARD
    sta whack_mode
    jmp !+
ml_select_easy:
    lda #MODE_EASY
    sta whack_mode
    jmp !+
ml_select_normal:
    lda #MODE_NORMAL
    sta whack_mode
!:

    lda joy_fired
    bne !+
    jmp main_loop
!:

    jmp game_start

//////////////////////////////////////////////////////
// Screen Draw Routine
ml_draw_screen:

    lda screen_draw
    bne !+
    jsr draw_screen_main
!:
    cmp #$01
    bne !+
    
    jsr draw_screen_instruct
!:
    rts

inc_screen_draw:
    inc screen_draw
    lda screen_draw
    cmp #$02
    bne !+
    lda #$00
    sta screen_draw
!:
    rts