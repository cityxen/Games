//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — game_loop.asm
// New-game bootstrap, the per-frame loop, level start/advance, and game over.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// game_start — reset everything for a fresh run, then fall into the loop
//////////////////////////////////////////////////////////////////////////////////////
game_start:
    lda #GS_PLAY
    sta var_game_state
    lda #0
    sta var_score_lo
    sta var_score_hi
    sta var_kittens
    sta var_load
    sta var_fire_prev
    sta var_flash
    lda #1
    sta var_level
    lda #START_HP
    sta var_hp

    jsr start_level

//////////////////////////////////////////////////////////////////////////////////////
// game_loop — one iteration per frame
//////////////////////////////////////////////////////////////////////////////////////
game_loop:
    jsr wait_vbl
    lda #0
    sta SPRITE_MSB_X            // keep every sprite in the first 256 px

    jsr anim_tick
    jsr unicorn_update          // input, move, flap, draw sprite 0
    jsr items_update            // spawn, fall, catch (load/kitten/damage)
    jsr center_check            // deliver the load
    jsr barf_update             // FIRE = rainbow barf gimmick
    jsr items_draw              // position item sprites 1..6
    jsr build_enable            // compose SPRITE_ENABLE
    jsr hud_update
    jsr flash_update

    // dead?
    lda var_hp
    bne !alive+
    jmp game_over
!alive:
    // level cleared?
    lda var_delivered
    cmp var_goal
    bcc game_loop
    jmp level_clear

//////////////////////////////////////////////////////////////////////////////////////
// start_level — recompute difficulty for var_level, reset the field, draw it
//////////////////////////////////////////////////////////////////////////////////////
start_level:
    // goal = GOAL_BASE + (level-1)*GOAL_STEP
    lda var_level
    sec
    sbc #1
    sta var_tmp_a               // level-1
    lda #0
    sta var_tmp_b
!g:
    lda var_tmp_a
    beq !gd+
    lda var_tmp_b
    clc
    adc #GOAL_STEP
    sta var_tmp_b
    dec var_tmp_a
    jmp !g-
!gd:
    lda var_tmp_b
    clc
    adc #GOAL_BASE
    sta var_goal
    lda #0
    sta var_delivered

    // spawn_rate = SPAWN_BASE - (level-1)*4, floored at SPAWN_MIN
    lda var_level
    sec
    sbc #1
    asl
    asl                         // (level-1)*4
    sta var_tmp_a
    lda #SPAWN_BASE
    sec
    sbc var_tmp_a
    bcs !sr1+
    lda #SPAWN_MIN
!sr1:
    cmp #SPAWN_MIN
    bcs !sr2+
    lda #SPAWN_MIN
!sr2:
    sta var_spawn_rate
    sta var_spawn_ctr

    // fall_base = FALL_MIN + (level-1)/3, capped at 4
    lda var_level
    sec
    sbc #1
    ldx #0
!fd:
    cmp #3
    bcc !ff+
    sbc #3
    inx
    jmp !fd-
!ff:
    txa
    clc
    adc #FALL_MIN
    cmp #5
    bcc !fc+
    lda #4
!fc:
    sta var_fall_base

    // bad_weight = 2 + level, capped 9
    lda var_level
    clc
    adc #2
    cmp #10
    bcc !bw+
    lda #9
!bw:
    sta var_bad_weight

    // clear the field
    ldx #(NUM_ITEMS-1)
    lda #0
!ci:
    sta item_active,x
    dex
    bpl !ci-

    // place the unicorn near the top centre
    lda #100
    sta var_uni_x
    lda #70
    sta var_uni_y
    lda #FACE_DOWN
    sta var_facing

    // draw the playfield: black sky + HUD, and park the center sprite
    ClearScreen(BLACK)
    jsr hud_draw_static

    lda #CENTER_X
    sta SPRITE_7_X
    lda #CENTER_Y
    sta SPRITE_7_Y
    lda #sp_center
    sta SPRITE_7_POINTER
    lda #LIGHT_GREEN
    sta SPRITE_7_COLOR

    jsr unicorn_draw
    jsr hud_update
    rts

//////////////////////////////////////////////////////////////////////////////////////
// level_clear / level_advance — tally screen, then ramp up and continue
//////////////////////////////////////////////////////////////////////////////////////
level_clear:
    jsr interlevel_show
    inc var_level
    jsr start_level
    jmp game_loop

//////////////////////////////////////////////////////////////////////////////////////
// flash_update — rainbow the border while a feedback event is active
//////////////////////////////////////////////////////////////////////////////////////
flash_update:
    lda var_flash
    beq !off+
    dec var_flash
    lda var_flash
    and #15
    sta BORDER_COLOR
    rts
!off:
    lda #BLACK
    sta BORDER_COLOR
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_over — show the score, wait for fire, return to the title (via main_loop)
//////////////////////////////////////////////////////////////////////////////////////
game_over:
    lda #GS_OVER
    sta var_game_state
    jsr draw_screen_over
!wf:
    jsr wait_vbl
    lda JOYSTICK_PORT_2
    and #%00010000
    bne !wf-                    // wait for a press
!wr:
    jsr wait_vbl
    lda JOYSTICK_PORT_2
    and #%00010000
    beq !wr-                    // then release
    rts
