//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — draw_screens.asm
// Full-screen presentation screens (title for now; game-over / win later).
//////////////////////////////////////////////////////////////////////////////////////
#importonce

draw_screen_title:
    ClearScreen(BLACK)

    PrintXY(m_title, 7, 3)
    PrintXY(m_sub,   6, 5)

    PrintXY(m_l1, 4, 9)
    PrintXY(m_l2, 4, 10)
    PrintXY(m_l3, 4, 12)
    PrintXY(m_l4, 4, 13)

    PrintXY(m_ctrl, 3, 16)
    PrintXY(m_start, 10, 19)
    PrintXY(m_cred,   7, 22)

    jsr sprite_init_title
    rts

//////////////////////////////////////////////////////////////////////////////////////
// draw_screen_over — dormancy (game over), showing the deepest sector reached
//////////////////////////////////////////////////////////////////////////////////////
draw_screen_over:
    lda #$00
    sta SPRITE_ENABLE
    ClearScreen(BLACK)
    PrintXY(m_over_t, 14, 6)
    PrintXY(m_over1, 3, 10)
    PrintXY(m_over2, 3, 12)         // "deepest sector reached:"
    PrintXY(m_press, 15, 18)
    // print the level number right after the text (row 12, col 27)
    lda screen_row_lo+12
    sta zp_ptr_screen_lo
    lda screen_row_hi+12
    sta zp_ptr_screen_hi
    lda color_row_lo+12
    sta zp_ptr_color_lo
    lda color_row_hi+12
    sta zp_ptr_color_hi
    ldy #27
    ldx #2
!col:
    lda #WHITE                     // colour the 3 digits
    sta (zp_ptr_color_lo),y
    iny
    dex
    bpl !col-
    lda var_level
    ldy #27
    jsr print_byte_dec3y
    rts
