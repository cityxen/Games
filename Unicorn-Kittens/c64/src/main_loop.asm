//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — main_loop.asm
// Title screen.  Waits for fire on joystick 2, then starts a new game.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

main_loop_start:
    lda #GS_TITLE
    sta var_game_state
    jsr draw_screen_title

main_loop_wait:
    jsr wait_vbl
    lda JOYSTICK_PORT_2
    and #%00010000              // fire = bit 4, active low
    bne main_loop_wait

    // Debounce: wait for release before starting
!rel:
    jsr wait_vbl
    lda JOYSTICK_PORT_2
    and #%00010000
    beq !rel-

    jsr game_start
    jmp main_loop_start         // returns here on game over
