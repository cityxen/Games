*=irq_prgs "irq_stuff"
//////////////////////////////////////////////////////////////////////////
// irq for music
irq1:
    // inc BORDER_COLOR
    lda option_music
    and #$01
    cmp #$01
    bne irq1_b
    jsr music.play
    jmp irq_done
irq1_b:
    lda #$00
    sta SID_VOLUME_FILTER
    jsr music.init
    clc
irq_done:
    // dec BORDER_COLOR
    lda #<irq2
    ldx #>irq2
    sta $0314
    stx $0315
    ldy #$40
    sty $d012
    asl $d019
    jmp $ea31

//////////////////////////////////////////////////////////////////////////
// irq for gfx change
irq2:
    // inc $d020
    lda VIC_CONTROL_REG_2
    ora #$10
    sta VIC_CONTROL_REG_2
    lda #LIGHT_GRAY
    sta $d022
    lda #BLACK
    sta $d023
    lda #<irq3
    ldx #>irq3
    sta $0314
    stx $0315
    ldy #$70
    sty $d012
    asl $d019
    jmp $ea81
irq3:
    // dec $d020
    lda VIC_CONTROL_REG_2
    and #%11101111
    sta VIC_CONTROL_REG_2
    lda #<irq4
    ldx #>irq4
    sta $0314
    stx $0315
    ldy #$f0
    sty $d012
    asl $d019
    jmp $ea81
irq4:
    inc option_timer_joyport
    inc option_timer
    lda option_timer
    cmp #60
    bne irq4_2
    lda #$00
    sta option_timer
    inc option_timer+1
    //jsr debug_line
irq4_2:
    lda #<irq1
    ldx #>irq1
    sta $0314
    stx $0315
    ldy #$10
    sty $d012
    asl $d019
    jmp $ea81
