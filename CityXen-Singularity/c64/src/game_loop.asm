//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — game_loop.asm
// New-game bootstrap, the per-frame loop, and sector (level) progression.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// game_start — reset, seed RNG, generate sector 1, run the loop
//////////////////////////////////////////////////////////////////////////////////////
game_start:
    // Seed the RNG from the raster so each run differs
    lda $D012
    ora #1                      // never 0
    sta var_rng

    // Resources — Clicky must FIND the Reality Inverter (no items at the start)
    lda #<RE_START
    sta var_re_lo
    lda #>RE_START
    sta var_re_hi
    lda #0
    sta var_ci
    sta var_fire_prev
    sta var_items

    lda #1
    sta var_level

    lda #GS_PLAY
    sta var_game_state

    // Enable Clicky (slot 0); clones enable themselves per room
    lda #%00000001
    sta SPRITE_ENABLE

    jsr start_level

//////////////////////////////////////////////////////////////////////////////////////
// game_loop — one iteration per VBL
//////////////////////////////////////////////////////////////////////////////////////
game_loop:
    jsr wait_vbl
    jsr anim_tick               // advance the shared walk-animation frame
    jsr player_update
    jsr entities_update
    jsr search_update
    jsr input_keys
    jsr hud_tick
    jsr hover_update            // bottom-bar "what am I on" hint

    lda var_game_state
    cmp #GS_OVER
    bne game_loop

    // dormancy: show the over screen, wait for fire → title
    jsr draw_screen_over
!wf:
    jsr wait_vbl
    lda JOYSTICK_PORT_2
    and #%00010000
    bne !wf-
!wfr:
    jsr wait_vbl
    lda JOYSTICK_PORT_2
    and #%00010000
    beq !wfr-
    rts

//////////////////////////////////////////////////////////////////////////////////////
// start_level — generate the current sector, draw it, show the objective
//////////////////////////////////////////////////////////////////////////////////////
start_level:
    jsr level_generate
    jsr room_draw
    jsr room_enter
    jsr hud_draw
    jsr update_player_sprite
    lda #MSG_OBJECTIVE
    ldx #MSG_LONG
    jsr msg_show_id
    rts

//////////////////////////////////////////////////////////////////////////////////////
// level_advance — descend to the next, harder sector (called when the gate is used)
//////////////////////////////////////////////////////////////////////////////////////
level_advance:
    inc var_level
    jsr start_level
    rts
