load_game:
    inc $d021
    jmp main_menu_loop

load_level:
    lda #var_level
    ldx #$00
    ldy #$00
!ll:
    tya
    sta SCREEN_RAM,x
    sta SCREEN_RAM+256,x
    sta SCREEN_RAM+512,x
    sta SCREEN_RAM+768,x
    inx
    iny
    cpx #$00
    bne !ll-
    rts