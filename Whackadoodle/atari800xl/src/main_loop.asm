#importonce
// ============================================================
// Main / attract loop (Atari 800XL)
//
// Shows attract screen (GFX doodles + 4 text rows).
// Joystick left/right selects EASY/NORMAL/HARD difficulty.
// Fire starts the game.
//
// Rotates between main and instruction screens via TIMER_SCREEN.
// ============================================================

main_loop_start:
restart:

    ResetTimerFired(TIMER_FLASH)
    ResetTimer(TIMER_FLASH)

    ResetTimerFired(TIMER_SCREEN)
    ResetTimer(TIMER_SCREEN)

    jsr draw_screen_main

main_loop:

    jsr wait_vbl
    jsr update_timers
    jsr read_joystick

    // Flash external button lights (no-op on software-only port)
    GetTimerFired(TIMER_FLASH)
    cmp #$02
    bne !+
    ResetTimerFired(TIMER_FLASH)
    ResetTimer(TIMER_FLASH)
    jsr randomly_flash_buttons
!:

    // Rotate attract screen
    GetTimerFired(TIMER_SCREEN)
    cmp #$05
    bne ml_scr_check_out
    ResetTimerFired(TIMER_SCREEN)
    ResetTimer(TIMER_SCREEN)
    jsr inc_screen_draw
    jsr ml_draw_screen
ml_scr_check_out:

    // Difficulty selection: slot 0-1 = EASY, 2 = NORMAL, 3-4 = HARD
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

    jsr ml_draw_mode_txt

    lda joy_fired
    bne !+
    jmp main_loop
!:

    jmp game_start

// ─── ml_draw_screen ──────────────────────────────────────────
ml_draw_screen:
    lda screen_draw
    bne !+
    jsr draw_screen_main
!:
    cmp #$01
    bne !+
    jsr draw_screen_instruct
!:
    cmp #$02
    bne !+
    jsr draw_screen_instruct2
!:
    rts
