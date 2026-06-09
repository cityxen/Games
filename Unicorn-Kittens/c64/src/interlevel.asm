//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — interlevel.asm
// Between-level tally: how many kittens the unicorn has rehomed, with a little kitten
// parading across the screen.  Waits for fire to continue.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

interlevel_show:
    lda #0
    sta SPRITE_ENABLE
    lda #WHITE
    sta CURSOR_COLOR            // cleared color RAM + text in white
    ClearScreen(BLACK)

    PrintXY(t_clr1, 14, 5)
    PrintXY(t_clr2, 8,  9)      // "kittens rehomed so far:"
    PrintXY(t_clr3, 7,  14)
    PrintXY(t_clr4, 6,  20)

    // kitten count just past the row-9 label
    lda screen_row_lo+9
    sta zp_ptr_screen_lo
    lda screen_row_hi+9
    sta zp_ptr_screen_hi
    lda var_kittens
    ldy #32
    jsr print_byte_dec3y

    // a kitten parades left->right until the player presses fire
    lda #sp_kitten
    sta SPRITE_0_POINTER
    lda #YELLOW
    sta SPRITE_0_COLOR
    lda #150
    sta SPRITE_0_Y
    lda #24
    sta var_uni_x               // scratch X for the parade
    lda #%00000001
    sta SPRITE_ENABLE
!anim:
    jsr wait_vbl
    lda #0
    sta SPRITE_MSB_X
    inc var_uni_x
    inc var_uni_x
    lda var_uni_x
    cmp #230
    bcc !ok+
    lda #24
    sta var_uni_x
!ok:
    sta SPRITE_0_X
    lda JOYSTICK_PORT_2
    and #%00010000
    bne !anim-                  // keep parading until fire
    // debounce release so the press doesn't leak into play
!rel:
    jsr wait_vbl
    lda JOYSTICK_PORT_2
    and #%00010000
    beq !rel-
    rts
