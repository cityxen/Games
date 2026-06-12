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
    jsr cycle_doodle_hue
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

    // Difficulty from the colored direction buttons:
    //   left(0)/up(1) = EASY, down(2) = NORMAL, right(3) = HARD.
    // The white button (slot 4 / fire) starts the game, so it must
    // not also change the difficulty.
    lda joy_slot
    cmp #4
    beq ml_diff_done
    cmp #2
    bcc ml_select_easy
    beq ml_select_normal
    lda #MODE_HARD
    sta whack_mode
    jmp ml_diff_done
ml_select_easy:
    lda #MODE_EASY
    sta whack_mode
    jmp ml_diff_done
ml_select_normal:
    lda #MODE_NORMAL
    sta whack_mode
ml_diff_done:

    // Mode line lives on text row 2 of the main attract page only.
    // Drawing it on every sub-screen would stamp "MODE: XXXX" over the
    // instruction pages' row-2 text after they were cleared.
    lda screen_draw
    bne ml_skip_mode_txt
    jsr ml_draw_mode_txt
ml_skip_mode_txt:

    // Every direction now fires too, so start only on the WHITE
    // button (slot 4 / fire), keeping ">> FIRE TO START <<" literal.
    lda joy_fired
    beq ml_no_start
    lda joy_slot
    cmp #4
    bne ml_no_start
    jmp game_start
ml_no_start:
    jmp main_loop

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
