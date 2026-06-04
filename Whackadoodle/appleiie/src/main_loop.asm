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

    //GetTimer(TIMER_SCREEN)
    //PrintHex(0,0)
    //GetTimerFired(TIMER_SCREEN)
    //PrintHex(4,0)

    jsr ml_draw_mode_txt
    jsr wait_vbl
    jsr update_timers
    jsr read_joystick

    // Check for flashing button lights timers
    GetTimerFired(TIMER_FLASH)
    cmp #$02
    bne !+
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


    // Mode selection (sticky): LEFT=EASY, UP=NORMAL, RIGHT=HARD
    lda joy_slot
    cmp #BUTTON_RED         // left
    bne !+
    lda #MODE_EASY
    sta whack_mode
    jmp ml_sel_done
!:
    cmp #BUTTON_PURPLE       // down
    bne !+
    lda #MODE_NORMAL
    sta whack_mode
    jmp ml_sel_done
!:
    cmp #BUTTON_WHITE        // fire
    bne !+
    lda #MODE_HARD
    sta whack_mode
    jmp ml_sel_done
!:
    cmp #BUTTON_BLUE        // right (start game)
    bne !+
    jmp game_start
!:
ml_sel_done:
    jmp main_loop

    

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