#importonce
// ============================================================
// Initialize: set up HGR, clear screen, init game state.
// Entry point from main.asm.
// ============================================================

initialize:
    // Kill interrupts during init
    sei

    // Reset game vars
    lda #0
    sta score
    sta whack_life
    sta message
    sta did_hit
    sta joy_fired
    sta joy_btn
    sta joy_prev_btn
    sta joy_prev_input
    lda #$FF
    sta button_actually_hit

    // Default mode: NORMAL
    lda #MODE_NORMAL
    sta whack_mode

    // Initialize software timers
    SetTimerReload(TIMER_FLASH,    60)   // 1 s flash
    SetTimerReload(TIMER_SCREEN,  300)   // 5 s page rotate
    SetTimerReload(TIMER_GAMEOVER,720)   // 12 s auto-return
    SetTimerReload(TIMER_MESSAGE,  80)   // ~1.3 s message

    ResetTimer(TIMER_FLASH)
    ResetTimer(TIMER_SCREEN)
    ResetTimer(TIMER_GAMEOVER)
    ResetTimer(TIMER_MESSAGE)

    // Clear text screen (uses ROM routine)
    jsr ROM_HOME

    // Enable HGR mixed mode
    jsr hgr_init
    jsr hgr_clear

    cli

    jmp main_loop_start
