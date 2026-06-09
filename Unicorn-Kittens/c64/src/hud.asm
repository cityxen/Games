//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — hud.asm
// The right-hand HUD (columns 30..39 — the sprite-MSB zone), drawn with characters so
// it never collides with the sprites (which stay in the first 256 px).
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// hud_draw_static — clear the HUD columns, draw the divider + labels (once per level)
//////////////////////////////////////////////////////////////////////////////////////
hud_draw_static:
    ldx #0                      // row
!row:
    lda screen_row_lo,x
    sta zp_ptr_screen_lo
    lda screen_row_hi,x
    sta zp_ptr_screen_hi
    lda color_row_lo,x
    sta zp_ptr_color_lo
    lda color_row_hi,x
    sta zp_ptr_color_hi
    ldy #HUD_DIV
!col:
    lda #SC_SPACE
    sta (zp_ptr_screen_lo),y
    lda #WHITE
    sta (zp_ptr_color_lo),y
    iny
    cpy #40
    bne !col-
    // divider bar at column 30
    ldy #HUD_DIV
    lda #SC_BAR
    sta (zp_ptr_screen_lo),y
    lda #DARK_GRAY
    sta (zp_ptr_color_lo),y
    inx
    cpx #25
    bne !row-

    // labels
    PutStr(h_score, 1,  HUD_COL, CYAN)
    PutStr(h_load,  4,  HUD_COL, GREEN)
    PutStr(h_life,  7,  HUD_COL, LIGHT_RED)
    PutStr(h_level, 10, HUD_COL, YELLOW)
    PutStr(h_kitty, 13, HUD_COL, LIGHT_BLUE)
    PutStr(h_goal,  16, HUD_COL, ORANGE)
    rts

//////////////////////////////////////////////////////////////////////////////////////
// hud_update — refresh the numbers/hearts (called every frame)
//////////////////////////////////////////////////////////////////////////////////////
hud_update:
    // SCORE (row 2): 5 digits
    lda screen_row_lo+2
    sta zp_ptr_screen_lo
    lda screen_row_hi+2
    sta zp_ptr_screen_hi
    ldy #HUD_COL
    jsr print_score5

    // LOAD (row 5): "n/5"
    lda screen_row_lo+5
    sta zp_ptr_screen_lo
    lda screen_row_hi+5
    sta zp_ptr_screen_hi
    ldy #HUD_COL
    lda var_load
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny
    lda #SC_SLASH
    sta (zp_ptr_screen_lo),y
    iny
    lda #$35                    // '5'
    sta (zp_ptr_screen_lo),y

    // LIFE (row 8): hearts
    jsr hud_hearts

    // LEVEL (row 11): 3 digits
    lda screen_row_lo+11
    sta zp_ptr_screen_lo
    lda screen_row_hi+11
    sta zp_ptr_screen_hi
    lda var_level
    ldy #HUD_COL
    jsr print_byte_dec3y

    // KITTY (row 14): 3 digits
    lda screen_row_lo+14
    sta zp_ptr_screen_lo
    lda screen_row_hi+14
    sta zp_ptr_screen_hi
    lda var_kittens
    ldy #HUD_COL
    jsr print_byte_dec3y

    // GOAL (row 17): "ddd/ggg"
    lda screen_row_lo+17
    sta zp_ptr_screen_lo
    lda screen_row_hi+17
    sta zp_ptr_screen_hi
    lda var_delivered
    ldy #HUD_COL
    jsr print_byte_dec3y        // cols 31..33, Y now = 34
    lda #SC_SLASH
    sta (zp_ptr_screen_lo),y
    lda var_goal
    ldy #35
    jsr print_byte_dec3y        // cols 35..37
    rts

//////////////////////////////////////////////////////////////////////////////////////
// hud_hearts — draw MAX_HP hearts on row 8; filled (red) up to var_hp, else dim
//////////////////////////////////////////////////////////////////////////////////////
hud_hearts:
    lda screen_row_lo+8
    sta zp_ptr_screen_lo
    lda screen_row_hi+8
    sta zp_ptr_screen_hi
    lda color_row_lo+8
    sta zp_ptr_color_lo
    lda color_row_hi+8
    sta zp_ptr_color_hi
    ldy #HUD_COL
    ldx #0
!h:
    cpx var_hp
    bcs !empty+
    lda #LIGHT_RED
    jmp !put+
!empty:
    lda #DARK_GRAY
!put:
    sta (zp_ptr_color_lo),y
    lda #SC_HEART
    sta (zp_ptr_screen_lo),y
    iny
    inx
    cpx #MAX_HP
    bne !h-
    rts

//////////////////////////////////////////////////////////////////////////////////////
// print_byte_dec3y — A = value (0..255) -> 3 digits at (zp_ptr_screen_lo),Y (Y += 3)
//////////////////////////////////////////////////////////////////////////////////////
print_byte_dec3y:
    ldx #0                      // hundreds
!h:
    cmp #100
    bcc !hd+
    sbc #100
    inx
    jmp !h-
!hd:
    sta var_tmp_b               // remainder < 100
    txa
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny
    ldx #0                      // tens
    lda var_tmp_b
!t:
    cmp #10
    bcc !td+
    sbc #10
    inx
    jmp !t-
!td:
    sta var_tmp_c               // units
    txa
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny
    lda var_tmp_c
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny
    rts

//////////////////////////////////////////////////////////////////////////////////////
// print_score5 — var_score_lo/hi -> 5 digits at (zp_ptr_screen_lo),Y (Y on entry)
//////////////////////////////////////////////////////////////////////////////////////
print_score5:
    sty var_tmp_a               // output column
    lda var_score_lo
    sta var_tmp_b               // working lo
    lda var_score_hi
    sta var_tmp_c               // working hi
    ldx #0                      // power index 0..4
!pow:
    lda #$30                    // this digit, counting up from '0'
    sta var_tmp_d
!sub:
    lda var_tmp_b
    sec
    sbc dec_pow_lo,x
    tay
    lda var_tmp_c
    sbc dec_pow_hi,x
    bcc !nextpow+               // would go negative -> done with this power
    sta var_tmp_c
    sty var_tmp_b
    inc var_tmp_d
    jmp !sub-
!nextpow:
    ldy var_tmp_a
    lda var_tmp_d
    sta (zp_ptr_screen_lo),y
    inc var_tmp_a
    inx
    cpx #5
    bne !pow-
    rts
