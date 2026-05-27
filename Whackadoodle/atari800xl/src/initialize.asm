#importonce
// ============================================================
// Initialize: set up display, clear screens, init game state.
// Entry point from main.asm (called via JMP at $2000).
// ============================================================

initialize:
    sei

    // Reset game vars
    lda #0
    sta score
    sta whack_life
    sta message
    sta did_hit
    sta joy_fired
    sta joy_prev_btn
    lda #$FF
    sta button_actually_hit

    lda #MODE_NORMAL
    sta whack_mode

    // Initialize software timers
    SetTimerReload(TIMER_FLASH,    60)
    SetTimerReload(TIMER_SCREEN,  300)
    SetTimerReload(TIMER_GAMEOVER,720)
    SetTimerReload(TIMER_MESSAGE,  80)

    ResetTimer(TIMER_FLASH)
    ResetTimer(TIMER_SCREEN)
    ResetTimer(TIMER_GAMEOVER)
    ResetTimer(TIMER_MESSAGE)

    // Silence POKEY
    lda #$00
    sta AUDC1
    sta AUDC2
    sta AUDC3
    sta AUDC4
    sta AUDCTL

    // Set up display list and enable DMA
    jsr gfx_init

    // Clear graphics bitmap and text screen
    jsr gfx_clear
    jsr txt_clear

    cli

    jmp main_loop_start
