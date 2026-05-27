//////////////////////////////////////////////////////////////////////////////////////
// ROGUE ENGINE 64 - C64
// mainmenu.asm - Title screen
//////////////////////////////////////////////////////////////////////////////////////

mainmenu:
    lda #$93
    jsr KERNAL_CHROUT
    lda #BLACK
    sta BACKGROUND_COLOR
    sta BORDER_COLOR

    // Title  row 8, col 9
    ldx #8
    ldy #9
    clc
    jsr KERNAL_PLOT
    lda #YELLOW
    sta CURSOR_COLOR
    Print(str_title)

    // By line  row 10, col 7
    ldx #10
    ldy #7
    clc
    jsr KERNAL_PLOT
    lda #CYAN
    sta CURSOR_COLOR
    Print(str_by)

    // Legend line  row 13, col 4
    ldx #13
    ldy #4
    clc
    jsr KERNAL_PLOT
    lda #LIGHT_GRAY
    sta CURSOR_COLOR
    .encoding "petscii_upper"
    Print(str_legend_move)

    // Legend line 2  row 14
    ldx #14
    ldy #4
    clc
    jsr KERNAL_PLOT
    Print(str_legend_keys)

    // Tiles legend  row 16
    ldx #16
    ldy #4
    clc
    jsr KERNAL_PLOT
    lda #DARK_GRAY
    sta CURSOR_COLOR
    Print(str_legend_tiles)

    // Press fire  row 21, col 7
    ldx #21
    ldy #7
    clc
    jsr KERNAL_PLOT
    lda #WHITE
    sta CURSOR_COLOR
    Print(str_press_fire)

mainmenu_wait:
    jsr KERNAL_GETIN
    cmp #0
    bne mainmenu_go
    lda JOYSTICK_PORT_2
    and #%00010000
    beq mainmenu_go
    jmp mainmenu_wait

mainmenu_go:
    jmp gameon_start


