
//////////////////////////////////////////////////////////////////////////////////////
// mainmenu_animate: advance corner sprite animation on each TIMER_ENEMY_MOVE tick
mainmenu_animate:
    GetTimerTr(TIMER_ENEMY_MOVE)
    bne mma_tick
    rts
mma_tick:
    FullReset(TIMER_ENEMY_MOVE)

    // Toggle 2-frame counter; A = new frame (0 or 1)
    lda menu_anim_frame
    eor #1
    sta menu_anim_frame

    // Bat (sprite 0): frame1 when 0, frame2 when 1
    bne mma_bat_f2
    lda #sprite_pointer_bat_frame1
    jmp mma_bat_set
mma_bat_f2:
    lda #sprite_pointer_bat_frame2
mma_bat_set:
    sta SPRITE_POINTERS+0

    // Energy (sprite 2)
    lda menu_anim_frame
    bne mma_energy_f2
    lda #sprite_pointer_energy_frame1
    jmp mma_energy_set
mma_energy_f2:
    lda #sprite_pointer_energy_frame2
mma_energy_set:
    sta SPRITE_POINTERS+2

    // Emerald (sprite 3)
    lda menu_anim_frame
    bne mma_emerald_f2
    lda #sprite_pointer_emerald_frame1
    jmp mma_emerald_set
mma_emerald_f2:
    lda #sprite_pointer_emerald_frame2
mma_emerald_set:
    sta SPRITE_POINTERS+3

    // Dollar (sprite 1): 3-frame cycle 0->1->2->0
    lda menu_dollar_frame
    cmp #2
    bne mma_dollar_inc
    lda #0
    jmp mma_dollar_store
mma_dollar_inc:
    clc
    adc #1
mma_dollar_store:
    sta menu_dollar_frame       // A = new frame (0, 1, or 2)
    cmp #1
    bcc mma_dollar_f1           // A < 1 (= 0): frame 1
    beq mma_dollar_f2           // A = 1: frame 2
    lda #sprite_pointer_dollar_frame3
    jmp mma_dollar_set
mma_dollar_f1:
    lda #sprite_pointer_dollar_frame1
    jmp mma_dollar_set
mma_dollar_f2:
    lda #sprite_pointer_dollar_frame2
mma_dollar_set:
    sta SPRITE_POINTERS+1
    rts



//////////////////////////////////////////////////////////////////////////////////////
// game_animate_player: step sprite 0 one tick toward player_target; call each loop.
game_animate_player:
    GetTimerTr(TIMER_PLAYER_ANIM)
    bne gap_tick
    rts
gap_tick:
    FullReset(TIMER_PLAYER_ANIM)
    lda player_is_moving
    bne gap_do_step
    rts

gap_do_step:
    lda move_dx
    cmp #1
    beq gap_step_right
    cmp #$ff
    beq gap_step_left
    jmp gap_step_y
gap_step_right:
    lda player_sprite_x_lo
    clc
    adc #PLAYER_MOVE_SPEED
    sta player_sprite_x_lo
    lda player_sprite_x_hi
    adc #0
    sta player_sprite_x_hi
    jmp gap_step_y
gap_step_left:
    lda player_sprite_x_lo
    sec
    sbc #PLAYER_MOVE_SPEED
    sta player_sprite_x_lo
    lda player_sprite_x_hi
    sbc #0
    sta player_sprite_x_hi

gap_step_y:
    lda move_dy
    cmp #1
    beq gap_step_down
    cmp #$ff
    beq gap_step_up
    jmp gap_check_done
gap_step_down:
    lda player_sprite_y
    clc
    adc #PLAYER_MOVE_SPEED
    sta player_sprite_y
    jmp gap_check_done
gap_step_up:
    lda player_sprite_y
    sec
    sbc #PLAYER_MOVE_SPEED
    sta player_sprite_y

gap_check_done:
    dec player_move_steps_rem
    bne gap_write_pos

    // Arrived: snap exact, clear flag, switch to static sprite
    lda player_target_x_lo
    sta player_sprite_x_lo
    lda player_target_x_hi
    sta player_sprite_x_hi
    lda player_target_y
    sta player_sprite_y
    lda #0
    sta player_is_moving

    lda move_dy
    bmi gap_static_up
    cmp #1
    beq gap_static_down
    lda move_dx
    bmi gap_static_left
    cmp #1
    beq gap_static_right
    lda #sprite_pointer_sutehk_down
    jmp gap_set_sprite
gap_static_up:
    lda #sprite_pointer_sutehk_up
    jmp gap_set_sprite
gap_static_down:
    lda #sprite_pointer_sutehk_down
    jmp gap_set_sprite
gap_static_left:
    lda #sprite_pointer_sutehk_left
    jmp gap_set_sprite
gap_static_right:
    lda #sprite_pointer_sutehk_right
gap_set_sprite:
    sta SPRITE_0_POINTER

gap_write_pos:
    lda player_sprite_x_hi
    and #1
    beq gap_msb_clear
    lda SPRITE_MSB_X
    ora #%00000001
    sta SPRITE_MSB_X
    jmp gap_write_x
gap_msb_clear:
    lda SPRITE_MSB_X
    and #%11111110
    sta SPRITE_MSB_X
gap_write_x:
    lda player_sprite_x_lo
    sta SPRITE_0_X
    lda player_sprite_y
    sta SPRITE_0_Y
    rts




//////////////////////////////////////////////////////////////////////////////////////
// game_animate_orbs: flip animation frame on the enemy-move timer tick
game_animate_orbs:
    GetTimerTr(TIMER_ENEMY_MOVE)
    bne gao_tick
    rts
gao_tick:
    FullReset(TIMER_ENEMY_MOVE)
    lda orb_anim_frame
    eor #1
    sta orb_anim_frame
    jmp game_draw_orb_sprites

//////////////////////////////////////////////////////////////////////////////////////
// game_start_player_move: begin smooth glide from current pos to new tile
// player_x/y already hold the destination tile coords
game_start_player_move:
    lda #0
    sta player_target_x_hi
    lda player_x
    asl
    rol player_target_x_hi
    asl
    rol player_target_x_hi
    asl
    rol player_target_x_hi
    asl
    rol player_target_x_hi
    clc
    adc #20
    sta player_target_x_lo
    lda player_target_x_hi
    adc #0
    sta player_target_x_hi

    lda player_y
    asl
    asl
    asl
    asl
    clc
    adc #88
    sta player_target_y

    lda #PLAYER_MOVE_STEPS
    sta player_move_steps_rem
    lda #1
    sta player_is_moving

    lda player_walk_frame
    eor #1
    sta player_walk_frame

    lda move_dy
    bmi gspm_up
    cmp #1
    beq gspm_down
    lda move_dx
    bmi gspm_left
    lda player_walk_frame
    beq gspm_right_f1
    lda #sprite_pointer_sutehk_walk_right_frame2
    jmp gspm_set
gspm_right_f1:
    lda #sprite_pointer_sutehk_walk_right_frame1
    jmp gspm_set
gspm_up:
    lda player_walk_frame
    beq gspm_up_f1
    lda #sprite_pointer_sutehk_walk_up_frame2
    jmp gspm_set
gspm_up_f1:
    lda #sprite_pointer_sutehk_walk_up_frame1
    jmp gspm_set
gspm_down:
    lda player_walk_frame
    beq gspm_down_f1
    lda #sprite_pointer_sutehk_walk_down_frame2
    jmp gspm_set
gspm_down_f1:
    lda #sprite_pointer_sutehk_walk_down_frame1
    jmp gspm_set
gspm_left:
    lda player_walk_frame
    beq gspm_left_f1
    lda #sprite_pointer_sutehk_walk_left_frame2
    jmp gspm_set
gspm_left_f1:
    lda #sprite_pointer_sutehk_walk_left_frame1
gspm_set:
    sta SPRITE_0_POINTER
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_bat_update: move bat on TIMER_BAT; count down spawn when inactive
game_bat_update:
    GetTimerTr(TIMER_BAT)
    bne gbu_tick
    rts
gbu_tick:
    FullReset(TIMER_BAT)

    lda bat_active
    bne gbu_moving
    dec bat_spawn_delay
    bne gbu_rts
    jsr game_bat_spawn
gbu_rts:
    rts

gbu_moving:
    inc bat_anim_sub
    lda bat_anim_sub
    and #1
    beq gbu_frame1
    lda #sprite_pointer_bat_frame2
    jmp gbu_set_ptr
gbu_frame1:
    lda #sprite_pointer_bat_frame1
gbu_set_ptr:
    sta SPRITE_POINTERS+7

    lda bat_dx
    bmi gbu_left

    lda bat_x_lo
    clc
    adc #BAT_SPEED
    sta bat_x_lo
    lda bat_x_hi
    adc #0
    sta bat_x_hi
    lda bat_x_hi
    beq gbu_write_pos
    lda bat_x_lo
    cmp #89
    bcc gbu_write_pos
    jmp gbu_deactivate

gbu_left:
    lda bat_x_lo
    sec
    sbc #BAT_SPEED
    sta bat_x_lo
    lda bat_x_hi
    sbc #0
    sta bat_x_hi
    lda bat_x_hi
    cmp #1
    beq gbu_write_pos
    bcc gbu_left_lo             // hi=0: check lo
    jmp gbu_deactivate          // hi=$FF: wrapped past 0
gbu_left_lo:
    lda bat_x_lo
    cmp #20
    bcs gbu_write_pos

gbu_deactivate:
    lda #0
    sta bat_active
    lda SPRITE_ENABLE
    and #%01111111
    sta SPRITE_ENABLE
    lda bat_y_idx
    and #%00000111
    tax
    lda bat_delay_table,x
    sta bat_spawn_delay
    rts

gbu_write_pos:
    lda bat_x_hi
    and #1
    beq gbu_msb0
    lda SPRITE_MSB_X
    ora #%10000000
    sta SPRITE_MSB_X
    jmp gbu_xy
gbu_msb0:
    lda SPRITE_MSB_X
    and #%01111111
    sta SPRITE_MSB_X
gbu_xy:
    lda bat_x_lo
    sta SPRITE_LOCATIONS+14
    lda bat_y
    sta SPRITE_LOCATIONS+15
    lda SPRITE_ENABLE
    ora #%10000000
    sta SPRITE_ENABLE
    jsr game_bat_check_hit
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_bat_spawn: launch bat from one screen edge; skips all-wall rows
game_bat_spawn:
    lda #1
    sta bat_active
    lda #0
    sta bat_anim_sub
    lda #8
    sta gbs_tries

gbs_pick_row:
    lda bat_y_idx
    and #%00000111
    sta gbs_row
    tax
    lda bat_y_table,x
    sta bat_y

    // Scan row for any non-wall tile
    lda gbs_row
    asl
    asl
    sta gbs_row_tmp
    lda gbs_row
    asl
    asl
    asl
    asl
    clc
    adc gbs_row_tmp         // row * 20
    tax
    ldy #LEVEL_W
gbs_row_scan:
    lda game_map,x
    cmp #OBJ_WALL
    bne gbs_row_ok
    inx
    dey
    bne gbs_row_scan
    // All walls: skip row
    inc bat_y_idx
    dec gbs_tries
    bne gbs_pick_row
    lda #0
    sta bat_active
    rts

gbs_row_ok:
    inc bat_y_idx
    lda bat_y_idx
    and #1
    beq gbs_left
    lda #1
    sta bat_dx
    lda #0
    sta bat_x_lo
    sta bat_x_hi
    rts
gbs_left:
    lda #$ff
    sta bat_dx
    lda #88
    sta bat_x_lo
    lda #1
    sta bat_x_hi
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_bat_check_hit: restart level if bat overlaps player sprite position
game_bat_check_hit:
    lda bat_y
    sec
    sbc player_sprite_y
    bcs gbch_ypos
    eor #$ff
    adc #1
gbch_ypos:
    cmp #14
    bcs gbch_miss
    lda bat_x_hi
    cmp player_sprite_x_hi
    bne gbch_miss
    lda bat_x_lo
    sec
    sbc player_sprite_x_lo
    bcs gbch_xpos
    eor #$ff
    adc #1
gbch_xpos:
    cmp #14
    bcs gbch_miss
    jsr game_restart_level
gbch_miss:
    rts