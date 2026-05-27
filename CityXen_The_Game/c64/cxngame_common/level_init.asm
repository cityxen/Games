level_init:

    rts

level_clear:
    lda #$00
    ldx #var_level_data_size
!li_lp:
    sta var_level_data,x
    dex
    bne !li_lp-
    rts

