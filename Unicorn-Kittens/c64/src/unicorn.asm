//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — unicorn.asm
// Clicky the unicorn: 4-direction flight (joystick 2), wing-flap animation, and the
// sprite-0 update.  Movement is clamped to the first 256 px so the sprite MSB stays 0.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// anim_tick — advance the shared wing-flap frame every ANIM_RATE frames
//////////////////////////////////////////////////////////////////////////////////////
anim_tick:
    inc var_anim_ctr
    lda var_anim_ctr
    cmp #ANIM_RATE
    bcc !done+
    lda #0
    sta var_anim_ctr
    lda var_anim_frame
    eor #1
    sta var_anim_frame
!done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// unicorn_update — read joystick 2, move with clamps + facing, then draw
//////////////////////////////////////////////////////////////////////////////////////
unicorn_update:
    lda JOYSTICK_PORT_2
    sta var_joy

    // left
    and #%00000100
    bne !nl+
    lda var_uni_x
    sec
    sbc #UNI_SPEED
    cmp #UNI_X_MIN
    bcs !lx+
    lda #UNI_X_MIN
!lx:
    sta var_uni_x
    lda #FACE_LEFT
    sta var_facing
!nl:
    // right
    lda var_joy
    and #%00001000
    bne !nr+
    lda var_uni_x
    clc
    adc #UNI_SPEED
    cmp #UNI_X_MAX
    bcc !rx+
    lda #UNI_X_MAX
!rx:
    sta var_uni_x
    lda #FACE_RIGHT
    sta var_facing
!nr:
    // up
    lda var_joy
    and #%00000001
    bne !nu+
    lda var_uni_y
    sec
    sbc #UNI_SPEED
    cmp #UNI_Y_MIN
    bcs !uy+
    lda #UNI_Y_MIN
!uy:
    sta var_uni_y
    lda #FACE_UP
    sta var_facing
!nu:
    // down
    lda var_joy
    and #%00000010
    bne !nd+
    lda var_uni_y
    clc
    adc #UNI_SPEED
    cmp #UNI_Y_MAX
    bcc !dy+
    lda #UNI_Y_MAX
!dy:
    sta var_uni_y
    lda #FACE_DOWN
    sta var_facing
!nd:
    // fall through to draw

//////////////////////////////////////////////////////////////////////////////////////
// unicorn_draw — write Clicky to hardware sprite 0 (always flapping = always flying)
//////////////////////////////////////////////////////////////////////////////////////
unicorn_draw:
    lda var_uni_x
    sta SPRITE_0_X
    lda var_uni_y
    sta SPRITE_0_Y
    ldx var_facing
    lda uni_dir_ptr,x
    clc
    adc var_anim_frame
    sta SPRITE_0_POINTER
    lda #UNI_COLOR
    sta SPRITE_0_COLOR
    rts
