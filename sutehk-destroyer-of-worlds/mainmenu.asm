//////////////////////////////////////////////////////////////////////////////////////
// SUTEHK: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//////////////////////////////////////////////////////////////////////////////////////
// mainmenu.asm - Title screen

mainmenu:

    jsr draw_main_screen

mainmenu_wait:
    jsr mainmenu_animate
    jsr KERNAL_GETIN
    cmp #0
    bne mainmenu_start
    lda JOYSTICK_PORT_2
    and #%00010000          // fire button (active low)
    beq mainmenu_start
    jmp mainmenu_wait

mainmenu_start:
    jmp gameon


