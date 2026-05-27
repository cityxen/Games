*=tile_definitions "tile defs"
tile_defs:
.byte $60,$62,$70,$72
.byte $4D,$4E,$5D,$5E
.byte $67,$68,$77,$78
.byte $60,$61,$70,$71
.byte $61,$62,$71,$72
.byte $6B,$6C,$7B,$7C
.byte $7F,$6F,$7B,$7C
.byte $00,$00,$90,$91
.byte $00,$00,$91,$91
.byte $00,$00,$91,$92
.byte $00,$00,$00,$00
.byte $82,$00,$80,$91
.byte $00,$83,$91,$81
.byte $82,$00,$82,$00
.byte $00,$83,$00,$83
.byte $85,$91,$82,$00
.byte $91,$84,$00,$83
.byte $91,$91,$00,$00
.byte $B0,$A0,$B0,$B0
.byte $B0,$B0,$B0,$B0
.byte $A2,$B0,$B0,$B0
.byte $B0,$B0,$B0,$A3
.byte $A1,$B0,$B0,$B0
.byte $40,$41,$50,$51
.byte $42,$43,$52,$53
.byte $44,$45,$54,$55
.byte $46,$47,$56,$57
.byte $48,$49,$58,$59
.byte $4A,$4B,$5A,$5B
.byte $4C,$00,$5C,$4C
.byte $00,$00,$00,$00
.byte $00,$00,$00,$00

tile_color_table:
.byte 11,11,12,11,11,15,10,12,12,12,12,12,12,12,12,12
.byte 12,12,10,10,10,10,10,15,15,15,15,15,15,15,15,15

tile_mult_table:
.byte 00,04,08,12,16,20,24,28,32, 36, 40, 44, 48, 52, 56, 60
.byte 64,68,72,76,80,84,88,92,96,100,104,108,112,116,120,124


/////////////////////////////////////////////////////////////////////////////////////////////////
// Draw One Tile (a) at (x,y)

draw_tile: // x,y

    sta var_tile_to_draw
    stx var_tile_x
    sty var_tile_y

    lda #<SCREEN_RAM
    sta zp_screen_lo
    lda #>SCREEN_RAM
    sta zp_screen_hi

    lda #<COLOR_RAM
    sta zp_color_lo
    lda #>COLOR_RAM
    sta zp_color_hi

    ldx var_tile_x
    cpx #$00
    beq !++
!:
    dex
    beq !+
    clc
    lda zp_screen_lo
    adc #02
    sta zp_screen_lo
    bcc !-
    inc zp_screen_hi
    bne !-
!:
    ldx var_tile_y
    cpx #$00
    beq !++
!:
    dex
    beq !+
    clc
    lda zp_screen_lo
    adc #80
    sta zp_screen_lo
    bcc !-
    inc zp_screen_hi
    bne !-
!:
    ldx var_tile_x
    cpx #$00
    beq !++
!:
    dex
    beq !+
    clc
    lda zp_color_lo
    adc #02
    sta zp_color_lo
    bcc !-
    inc zp_color_hi
    bne !-
!:
    ldx var_tile_y
    cpx #$00
    beq !++
!:
    dex
    beq !+
    clc
    lda zp_color_lo
    adc #80
    sta zp_color_lo
    bcc !-
    inc zp_color_hi
    bne !-
!:

    ldx var_tile_to_draw
    lda tile_color_table,x
    sta var_tile_color

    lda tile_mult_table,x
    tay

    ldx #$00
    lda tile_defs,y
    sta (zp_screen,x)
    lda var_tile_color
    sta (zp_color,x)

    inc zp_screen_lo
    bne !+
    inc zp_screen_hi
!:
    inc zp_color_lo
    bne !+
    inc zp_color_hi
!:
    iny
    lda tile_defs,y
    sta (zp_screen,x)
    lda var_tile_color
    sta (zp_color,x)

    clc
    lda zp_screen_lo
    adc #39
    sta zp_screen_lo
    bcc !+
    inc zp_screen_hi
!:
    clc
    lda zp_color_lo
    adc #39
    sta zp_color_lo
    bcc !+
    inc zp_color_hi
!:

    iny
    lda tile_defs,y
    sta (zp_screen,x)
    lda var_tile_color
    sta (zp_color,x)

    inc zp_screen_lo
    bne !+
    inc zp_screen_hi
!:
    inc zp_color_lo
    bne !+
    inc zp_color_hi
!:
    iny
    lda tile_defs,y
    sta (zp_screen,x)
    lda var_tile_color
    sta (zp_color,x)
    rts

/////////////////////////////////////////////////////////////////////////////////////////////////
// Draw Room Border (Blank Room to Draw on Top of)
    
draw_room_border:

    lda #<map_border_data
    sta zp_tmp_lo
    lda #>map_border_data
    sta zp_tmp_hi

    ldx #$01
    ldy #$01
    stx var_tx
    sty var_ty
!lp:    
    ldx #$00
    lda (zp_tmp,x)
    ldx var_tx
    ldy var_ty
    iny
    jsr draw_tile

    inc zp_tmp_lo
    bne !+
    inc zp_tmp_hi
!:

    ldx var_tx
    ldy var_ty
    inx
    stx var_tx
    cpx #$11
    bne !lp-
    ldx #$01
    stx var_tx
    iny
    sty var_ty
    cpy #$0c
    bne !lp-
    rts


    
