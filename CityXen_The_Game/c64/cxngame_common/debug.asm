
debug_line:

    clc
    
    lda option_joyport
    PrintHex(0,24)

    lda option_music
    PrintHex(2,24)

    lda menu_cursor
    PrintHex(4,24)

    lda option_timer+1
    PrintHex(6,24)

    lda zp_screen_hi
    PrintHex(9,24)
    lda zp_screen_lo
    PrintHex(11,24)

    lda zp_color_hi
    PrintHex(14,24)
    lda zp_color_lo
    PrintHex(16,24)

    lda var_tx
    PrintHex(19,24)
    lda var_ty
    PrintHex(22,24)

    

    
    
    rts
