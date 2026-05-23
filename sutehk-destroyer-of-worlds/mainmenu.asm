//////////////////////////////////////////////////////////////////////////////////////
// SUTEKH: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//////////////////////////////////////////////////////////////////////////////////////
// mainmenu.asm - Title screen

mainmenu:
    // Black screen
    lda #$93
    jsr KERNAL_CHROUT
    lda #BLACK
    sta BACKGROUND_COLOR
    sta BORDER_COLOR

    // Title: row 8 col 6
    ldx #8
    ldy #6
    clc
    jsr KERNAL_PLOT
    lda #YELLOW
    sta CURSOR_COLOR
    Print(str_title)

    // Subtitle: row 10 col 6
    ldx #10
    ldy #6
    clc
    jsr KERNAL_PLOT
    lda #CYAN
    sta CURSOR_COLOR
    Print(str_subtitle)

    // Press start: row 15 col 7
    ldx #15
    ldy #7
    clc
    jsr KERNAL_PLOT
    lda #WHITE
    sta CURSOR_COLOR
    Print(str_press_start)

    // CityXen credit: row 23 col 12
    ldx #23
    ldy #12
    clc
    jsr KERNAL_PLOT
    lda #DARK_GRAY
    sta CURSOR_COLOR
    .encoding "petscii_upper"
    Print(str_credit)

mainmenu_wait:
    jsr KERNAL_GETIN
    cmp #0
    bne mainmenu_start
    lda JOYSTICK_PORT_2
    and #%00010000          // fire button (active low)
    beq mainmenu_start
    jmp mainmenu_wait

mainmenu_start:
    jmp gameon

.encoding "petscii_upper"
str_credit:
.text "BY DEADLINE / CITYXEN 2026"
.byte 0
