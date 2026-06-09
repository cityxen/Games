//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — draw_screens.asm
// Full-screen presentation screens: the title and the game-over screen.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// draw_screen_title — the front page + how-to-play + the gimmick pitch
//////////////////////////////////////////////////////////////////////////////////////
draw_screen_title:
    lda #0
    sta SPRITE_ENABLE
    lda #WHITE
    sta CURSOR_COLOR
    ClearScreen(BLACK)

    PrintXY(t_title, 6,  2)
    PrintXY(t_sub,   6,  4)
    PrintXY(t_l1,    2,  7)
    PrintXY(t_l2,    2,  8)
    PrintXY(t_l3,    2,  10)
    PrintXY(t_l4,    2,  11)
    PrintXY(t_l5,    1,  13)
    PrintXY(t_gim,   3,  16)
    PrintXY(t_gim2,  4,  17)
    PrintXY(t_start, 7,  20)
    PrintXY(t_cred,  14, 23)
    rts

//////////////////////////////////////////////////////////////////////////////////////
// draw_screen_over — final score + kittens rehomed, wait-for-fire prompt
//////////////////////////////////////////////////////////////////////////////////////
draw_screen_over:
    lda #0
    sta SPRITE_ENABLE
    lda #WHITE
    sta CURSOR_COLOR
    ClearScreen(BLACK)

    PrintXY(t_over1, 11, 6)
    PrintXY(t_over2, 8,  9)
    PrintXY(t_over3, 8,  12)    // "final score:"
    PrintXY(t_over4, 8,  14)    // "kittens rehomed:"
    PrintXY(t_over5, 9,  20)

    // final score (5 digits) after the label
    lda screen_row_lo+12
    sta zp_ptr_screen_lo
    lda screen_row_hi+12
    sta zp_ptr_screen_hi
    ldy #21
    jsr print_score5

    // kittens (3 digits) after its label
    lda screen_row_lo+14
    sta zp_ptr_screen_lo
    lda screen_row_hi+14
    sta zp_ptr_screen_hi
    lda var_kittens
    ldy #25
    jsr print_byte_dec3y
    rts
