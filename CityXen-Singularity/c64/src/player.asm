//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — player.asm
// Clicky's movement (8-direction), facing, wall collision (BLOCK_MAP rollback),
// and walk-through-the-gap room transitions.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// player_update — joystick move, collision, edge transitions, sprite refresh
//////////////////////////////////////////////////////////////////////////////////////
player_update:
    lda JOYSTICK_PORT_2
    sta var_tmp_joy
    lda #0
    sta var_moving

    // ── X axis (with rollback) ─────────────────────────────────────────────────
    lda var_player_x
    sta var_old_x
    lda var_player_x_msb
    sta var_old_x_msb
    lda var_tmp_joy
    and #%00001000
    bne !nr+
    jsr move_player_right
!nr:
    lda var_tmp_joy
    and #%00000100
    bne !nl+
    jsr move_player_left
!nl:
    jsr player_blocked
    beq !x_ok+
    lda var_old_x
    sta var_player_x
    lda var_old_x_msb
    sta var_player_x_msb
!x_ok:

    // ── Y axis (with rollback) ─────────────────────────────────────────────────
    lda var_player_y
    sta var_old_y
    lda var_tmp_joy
    and #%00000010
    bne !nd+
    jsr move_player_down
!nd:
    lda var_tmp_joy
    and #%00000001
    bne !nu+
    jsr move_player_up
!nu:
    jsr player_blocked
    beq !y_ok+
    lda var_old_y
    sta var_player_y
!y_ok:

    jsr player_check_edges
    jsr update_player_sprite
    rts

//////////////////////////////////////////////////////////////////////////////////////
// player_blocked — A != 0 (BNE) if the player's centre/feet cell is a wall/solid
//////////////////////////////////////////////////////////////////////////////////////
player_blocked:
    jsr player_to_col
    clc
    adc #1                  // centre of the 3-wide sprite
    cmp #40
    bcc !cok+
    lda #39
!cok:
    sta var_tmp_b
    jsr player_to_row
    clc
    adc #2                  // around the body
    cmp #24
    bcc !rok+
    lda #23
!rok:
    tax
    lda screen_row_lo,x
    sta zp_tmp_lo
    lda screen_row_hi,x
    clc
    adc #BLOCK_OFFSET_HI
    sta zp_tmp_hi
    ldy var_tmp_b
    lda (zp_tmp_lo),y       // 0 = open, nonzero = solid
    rts

//////////////////////////////////////////////////////////////////////////////////////
// Directional movement with clamps (also sets facing + moving)
//////////////////////////////////////////////////////////////////////////////////////
move_player_right:
    lda #FACE_RIGHT
    sta var_facing
    lda #1
    sta var_moving
    lda var_player_x
    clc
    adc #PLAYER_SPEED
    sta var_player_x
    bcc !nc+
    inc var_player_x_msb
!nc:
    lda var_player_x_msb
    cmp #PLAYER_X_MAX_MSB
    bcc !ok+
    bne !clamp+
    lda var_player_x
    cmp #PLAYER_X_MAX_LO
    bcc !ok+
    beq !ok+
!clamp:
    lda #PLAYER_X_MAX_LO
    sta var_player_x
    lda #PLAYER_X_MAX_MSB
    sta var_player_x_msb
!ok:
    rts

move_player_left:
    lda #FACE_LEFT
    sta var_facing
    lda #1
    sta var_moving
    lda var_player_x
    sec
    sbc #PLAYER_SPEED
    sta var_player_x
    bcs !nb+
    lda var_player_x_msb
    beq !clamp+
    dec var_player_x_msb
    jmp !nb+
!clamp:
    lda #PLAYER_X_MIN
    sta var_player_x
    lda #0
    sta var_player_x_msb
    rts
!nb:
    lda var_player_x_msb
    bne !ok+
    lda var_player_x
    cmp #PLAYER_X_MIN
    bcs !ok+
    lda #PLAYER_X_MIN
    sta var_player_x
!ok:
    rts

move_player_down:
    lda #FACE_DOWN
    sta var_facing
    lda #1
    sta var_moving
    lda var_player_y
    clc
    adc #PLAYER_SPEED
    cmp #PLAYER_Y_MAX
    bcc !ok+
    beq !ok+
    lda #PLAYER_Y_MAX
!ok:
    sta var_player_y
    rts

move_player_up:
    lda #FACE_UP
    sta var_facing
    lda #1
    sta var_moving
    lda var_player_y
    sec
    sbc #PLAYER_SPEED
    cmp #PLAYER_Y_MIN
    bcs !ok+
    lda #PLAYER_Y_MIN
!ok:
    sta var_player_y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// player_check_edges — when pinned at an edge gap, transition to the linked room
//////////////////////////////////////////////////////////////////////////////////////
player_check_edges:
    // WEST: at the left edge, aligned with the door rows
    lda var_player_x_msb
    bne !chk_e+
    lda var_player_x
    cmp #(PLAYER_X_MIN+1)
    bcs !chk_e+
    jsr player_to_row
    cmp #10
    bcc !chk_e+
    cmp #15
    bcs !chk_e+
    ldy #7
    jsr room_exit_field
    cmp #NO_EXIT
    beq !chk_e+
    pha
    lda #ENTER_E_X
    sta var_player_x
    lda #1
    sta var_player_x_msb
    pla
    jmp room_go

!chk_e:
    lda var_player_x_msb
    cmp #PLAYER_X_MAX_MSB
    bcc !chk_n+
    lda var_player_x
    cmp #PLAYER_X_MAX_LO
    bcc !chk_n+
    jsr player_to_row
    cmp #10
    bcc !chk_n+
    cmp #15
    bcs !chk_n+
    ldy #6
    jsr room_exit_field
    cmp #NO_EXIT
    beq !chk_n+
    pha
    lda #ENTER_W_X
    sta var_player_x
    lda #0
    sta var_player_x_msb
    pla
    jmp room_go

!chk_n:
    lda var_player_y
    cmp #(PLAYER_Y_MIN+1)
    bcs !chk_s+
    jsr player_to_col
    cmp #17
    bcc !chk_s+
    cmp #23
    bcs !chk_s+
    ldy #4
    jsr room_exit_field
    cmp #NO_EXIT
    beq !chk_s+
    pha
    lda #ENTER_S_Y
    sta var_player_y
    pla
    jmp room_go

!chk_s:
    lda var_player_y
    cmp #PLAYER_Y_MAX
    bcc !none+
    jsr player_to_col
    cmp #17
    bcc !none+
    cmp #23
    bcs !none+
    ldy #5
    jsr room_exit_field
    cmp #NO_EXIT
    beq !none+
    pha
    lda #ENTER_N_Y
    sta var_player_y
    pla
    jmp room_go

!none:
    rts

// room_exit_field — Y = room-record field index → A = that field
room_exit_field:
    jsr room_rec_ptr
    lda (zp_tmp_lo),y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// update_player_sprite — write Clicky's position to VIC sprite 0
//////////////////////////////////////////////////////////////////////////////////////
update_player_sprite:
    lda var_player_x
    sta SPRITE_0_X
    lda SPRITE_MSB_X
    and #%11111110
    ldx var_player_x_msb
    beq !m0+
    ora #%00000001
!m0:
    sta SPRITE_MSB_X
    lda var_player_y
    sta SPRITE_0_Y

    // animated sprite pointer: idle when stopped, else facing walk frame
    lda var_moving
    bne !walk+
    lda #sp_clicky_idle
    jmp !setp+
!walk:
    lda var_facing                 // 0=down,1=up,2=left,3=right
    asl                            // * ANIM_FRAMES (2)
    clc
    adc var_anim_frame
    clc
    adc #sp_clicky_walk
!setp:
    sta SPRITE_0_POINTER
    rts

//////////////////////////////////////////////////////////////////////////////////////
// anim_tick — advance the shared walk-animation frame every ANIM_RATE game frames
//////////////////////////////////////////////////////////////////////////////////////
anim_tick:
    inc var_anim_ctr
    lda var_anim_ctr
    cmp #ANIM_RATE
    bcc !done+
    lda #0
    sta var_anim_ctr
    lda var_anim_frame
    clc
    adc #1
    cmp #ANIM_FRAMES
    bcc !store+
    lda #0
!store:
    sta var_anim_frame
!done:
    rts
