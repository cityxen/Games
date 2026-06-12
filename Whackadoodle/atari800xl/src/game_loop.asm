#importonce
// ============================================================
// Game loop (Atari 800XL)
// Ported from C64 game_loop.asm / game_start
//
// button_to_hit:       slot doodle is on (0-4)
// button_actually_hit: slot player selected ($FF = no input yet)
// joy_slot:            joystick-selected slot (from read_joystick)
// joy_fired:           1 = fire button just pressed this frame
// ============================================================

game_start:

    // Set lives for mode
    lda initial_life
    sta whack_life
    lda whack_mode
    cmp #MODE_EASY
    bne gs_try_hard
    lda initial_life_easy
    sta whack_life
    jmp gs_lives_done
gs_try_hard:
    cmp #MODE_HARD
    bne gs_lives_done
    lda initial_life_hard
    sta whack_life
gs_lives_done:

    lda #0
    sta score
    sta did_hit
    sta message
    lda #$FF
    sta button_actually_hit
    sta last_slot

    // Refresh display
    jsr set_gfx_dl             // restore mixed DL (fire may start from text page)
    jsr gfx_clear
    jsr txt_clear
    jsr draw_circles
    jsr clear_message_row
    jsr draw_score_line

    // Set initial doodle speed
    lda #<DOODLE_SPEED_INITIAL
    sta doodle_timer_set_lo
    lda #>DOODLE_SPEED_INITIAL
    sta doodle_timer_set_hi

    // GET READY message
    lda #1
    jsr set_message
    jsr show_message

    jsr game_setup_doodle

game_loop:

    jsr wait_vbl
    jsr cycle_doodle_hue
    jsr update_timers
    jsr read_joystick

    lda whack_life
    bne gl_alive
    jmp game_over
gl_alive:

    lda message
    beq gl_no_msg
    jsr show_message
    jmp game_loop
gl_no_msg:

    jsr tick_doodle_timer
    beq gl_doodle_expired
    bne gl_check_input

gl_doodle_expired:
    lda #0
    sta did_hit
    jsr game_setup_doodle
    jsr draw_score_line
    jmp game_loop

gl_check_input:

    lda joy_fired
    beq gl_no_fire

    lda joy_slot
    sta button_actually_hit

    cmp button_to_hit
    bne gl_wrong_button

    lda doodle
    cmp #4
    bcs gl_bad_doodle_hit

    // Good doodle hit → WRONG (-1 score, -1 life)
    lda score
    beq gl_wrong_no_sub
    dec score
gl_wrong_no_sub:
    dec whack_life
    lda #HIT_WRONG_DOOD
    sta did_hit
    lda #4
    jsr set_message
    jsr beep
    jsr draw_score_line
    jsr game_setup_doodle
    jmp game_loop

gl_bad_doodle_hit:
    // Bad doodle hit → POW (+1 score)
    lda score
    cmp #99
    beq gl_pow_no_add
    inc score
gl_pow_no_add:
    lda #HIT_POW
    sta did_hit
    lda #3
    jsr set_message
    jsr beep
    jsr draw_score_line
    jsr game_setup_doodle
    jmp game_loop

gl_wrong_button:
    // Wrong slot → MISS (-1 life)
    dec whack_life
    lda #HIT_WRONG_BTN
    sta did_hit
    lda #2
    jsr set_message
    jsr beep
    jsr draw_score_line
    jsr game_setup_doodle
    jmp game_loop

gl_no_fire:
    jmp game_loop
