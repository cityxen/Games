//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — entities.asm
// MDCA Clone patrols.  Up to CLONE_MAX clones per room (VIC sprite slots 1..4), each
// smooth-patrolling a rectangle clockwise.  Count + speed scale with sector depth.
// Contact with any clone drains Retronic Energy.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// clone_spawn_for_room — activate this room's clones (up to CLONE_MAX) from clone_table
//////////////////////////////////////////////////////////////////////////////////////
clone_spawn_for_room:
    lda SPRITE_ENABLE
    and #%11100001              // hide clone sprites (slots 1..4)
    sta SPRITE_ENABLE
    ldx #(CLONE_MAX-1)
    lda #0
!ca:
    sta clone_active,x
    dex
    bpl !ca-
    sta var_clone_drain_ctr
    lda #0
    sta var_g0                  // clone_table byte offset
    sta var_g1                  // next free clone slot
!s:
    ldx var_g0
    lda clone_table,x
    cmp #$FF
    beq !done+
    cmp var_room
    bne !next+
    lda var_g1
    cmp #CLONE_MAX
    bcs !next+                  // all slots full
    jsr setup_clone
    inc var_g1
!next:
    lda var_g0
    clc
    adc #CLONE_REC
    sta var_g0
    jmp !s-
!done:
    rts

// setup_clone — var_g0 = clone_table offset, var_g1 = clone slot
setup_clone:
    ldy var_g1
    lda #1
    sta clone_active,y
    lda #CDIR_RIGHT
    sta clone_dir,y
    ldx var_g0
    lda clone_table+1,x         // col
    jsr col_to_px
    ldy var_g1
    sta clone_x,y
    ldx var_g0
    lda clone_table+2,x         // row
    jsr row_to_py
    ldy var_g1
    sta clone_y,y
    // sprite slot s = g1 + 1
    lda var_g1
    clc
    adc #1
    tax                         // s
    lda sprite_bit,x
    ora SPRITE_ENABLE
    sta SPRITE_ENABLE
    lda #sp_clone_idle          // (write_clone_sprite sets the animated frame each tick)
    sta SPRITE_POINTERS,x       // $07F8 + s
    lda #LIGHT_RED
    sta SPRITE_0_COLOR,x        // $D027 + s
    ldx var_g1
    jsr write_clone_sprite
    rts

//////////////////////////////////////////////////////////////////////////////////////
// entities_update — patrol + draw + contact for every active clone
//////////////////////////////////////////////////////////////////////////////////////
entities_update:
    ldx #0
!u:
    lda clone_active,x
    beq !nx+
    txa
    pha
    jsr clone_step_i
    pla
    tax
!nx:
    inx
    cpx #CLONE_MAX
    bne !u-
    jsr update_clone_sprites
    jsr clone_contact_all
    rts

// clone_step_i — X = clone index; smooth clockwise patrol around the rectangle
clone_step_i:
    lda clone_dir,x
    cmp #CDIR_DOWN
    beq !down+
    cmp #CDIR_LEFT
    beq !left+
    cmp #CDIR_UP
    beq !up+
    // RIGHT
    lda clone_x,x
    clc
    adc var_clone_speed
    cmp #ENT_X_MAX
    bcc !srx+
    lda #ENT_X_MAX
    pha
    lda #CDIR_DOWN
    sta clone_dir,x
    pla
!srx:
    sta clone_x,x
    rts
!down:
    lda clone_y,x
    clc
    adc var_clone_speed
    cmp #ENT_Y_MAX
    bcc !sdy+
    lda #ENT_Y_MAX
    pha
    lda #CDIR_LEFT
    sta clone_dir,x
    pla
!sdy:
    sta clone_y,x
    rts
!left:
    lda clone_x,x
    sec
    sbc var_clone_speed
    cmp #ENT_X_MIN
    bcs !slx+
    lda #ENT_X_MIN
    pha
    lda #CDIR_UP
    sta clone_dir,x
    pla
!slx:
    sta clone_x,x
    rts
!up:
    lda clone_y,x
    sec
    sbc var_clone_speed
    cmp #ENT_Y_MIN
    bcs !suy+
    lda #ENT_Y_MIN
    pha
    lda #CDIR_RIGHT
    sta clone_dir,x
    pla
!suy:
    sta clone_y,x
    rts

//////////////////////////////////////////////////////////////////////////////////////
// Sprite position writes
//////////////////////////////////////////////////////////////////////////////////////
update_clone_sprites:
    ldx #0
!u:
    lda clone_active,x
    beq !nx+
    txa
    pha
    jsr write_clone_sprite
    pla
    tax
!nx:
    inx
    cpx #CLONE_MAX
    bne !u-
    rts

// write_clone_sprite — X = clone index i; sprite slot s = i+1.  Sets position AND
// the animated walk-frame pointer (clones are always patrolling = always walking).
write_clone_sprite:
    lda clone_x,x
    sta var_tmp_b
    lda clone_y,x
    sta var_tmp_c
    // animated pointer = sp_clone_walk + cdir_to_anim[dir]*ANIM_FRAMES + frame
    lda clone_dir,x
    tay
    lda cdir_to_anim,y
    asl
    clc
    adc var_anim_frame
    clc
    adc #sp_clone_walk
    sta var_tmp_a
    txa
    clc
    adc #1                      // s
    tay                         // Y = s
    lda var_tmp_a
    sta SPRITE_POINTERS,y       // $07F8 + s : current walk frame
    lda sprite_msb_clear,y      // clone x < 256 → clear MSB bit s
    and SPRITE_MSB_X
    sta SPRITE_MSB_X
    tya
    asl                         // 2s (VIC reg offset)
    tax
    lda var_tmp_b
    sta SPRITE_LOCATIONS,x      // sprite s X
    lda var_tmp_c
    sta SPRITE_LOCATIONS+1,x    // sprite s Y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// Contact / energy drain
//////////////////////////////////////////////////////////////////////////////////////
clone_contact_all:
    ldx #0
!c:
    lda clone_active,x
    beq !nx+
    jsr clone_near_player       // carry set if clone i overlaps the player
    bcs !contact+
!nx:
    inx
    cpx #CLONE_MAX
    bne !c-
    lda #0
    sta var_clone_drain_ctr
    rts
!contact:
    inc var_clone_drain_ctr
    lda var_clone_drain_ctr
    cmp #CLONE_DRAIN_DELAY
    bcc !ret+
    lda #0
    sta var_clone_drain_ctr
    lda #CLONE_DRAIN
    jsr drain_energy            // Z set if energy now zero
    php
    jsr hud_draw
    lda #MSG_CLONE_ZAP
    ldx #MSG_SHORT
    jsr msg_show_id
    plp
    bne !ret+
    jmp clicky_dormant
!ret:
    rts

// clone_near_player — X = clone index; carry set if within NEAR_X/NEAR_Y of player
clone_near_player:
    lda var_player_x_msb
    bne !no+                    // clones live at x < 256
    lda var_player_x
    sec
    sbc clone_x,x
    bpl !dxp+
    eor #$FF
    clc
    adc #1
!dxp:
    cmp #NEAR_X
    bcs !no+
    lda var_player_y
    sec
    sbc clone_y,x
    bpl !dyp+
    eor #$FF
    clc
    adc #1
!dyp:
    cmp #NEAR_Y
    bcs !no+
    sec
    rts
!no:
    clc
    rts

//////////////////////////////////////////////////////////////////////////////////////
// clicky_dormant — out of Retronic Energy: game over
//////////////////////////////////////////////////////////////////////////////////////
clicky_dormant:
    lda #0
    sta var_re_lo
    sta var_re_hi
    jsr hud_draw
    lda #MSG_DORMANT
    ldx #MSG_LONG
    jsr msg_show_id
    lda #GS_OVER
    sta var_game_state
    rts
