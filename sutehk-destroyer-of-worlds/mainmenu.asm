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

    jsr mainmenu_init_sprites

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

//////////////////////////////////////////////////////////////////////////////////////
// mainmenu_init_sprites: place 4 animated corner sprites on the title screen
//   Sprite 0: bat       — top-left     (X=24,  Y=50)
//   Sprite 1: dollar    — top-right    (X=320, Y=50)   MSB=1
//   Sprite 2: energy    — bottom-left  (X=24,  Y=218)
//   Sprite 3: emerald   — bottom-right (X=320, Y=218)  MSB=1
mainmenu_init_sprites:
    lda #%11111111
    sta SPRITE_MULTICOLOR
    lda #sprite_multicolor_1
    sta SPRITE_MULTICOLOR_0
    lda #sprite_multicolor_2
    sta SPRITE_MULTICOLOR_1

    // Sprite 0: bat — top-left (X=24, Y=50)
    lda #sprite_pointer_bat_frame1
    sta SPRITE_POINTERS+0
    lda #RED
    sta SPRITE_COLORS+0
    lda #24
    sta SPRITE_LOCATIONS+0
    lda #50
    sta SPRITE_LOCATIONS+1

    // Sprite 1: dollar — top-right (X=320: lo=64, MSB bit 1; Y=50)
    lda #sprite_pointer_dollar_frame1
    sta SPRITE_POINTERS+1
    lda #LIGHT_GREEN
    sta SPRITE_COLORS+1
    lda #64
    sta SPRITE_LOCATIONS+2
    lda #50
    sta SPRITE_LOCATIONS+3

    // Sprite 2: energy — bottom-left (X=24, Y=218)
    lda #sprite_pointer_energy_frame1
    sta SPRITE_POINTERS+2
    lda #RED
    sta SPRITE_COLORS+2
    lda #24
    sta SPRITE_LOCATIONS+4
    lda #218
    sta SPRITE_LOCATIONS+5

    // Sprite 3: emerald — bottom-right (X=320: lo=64, MSB bit 3; Y=218)
    lda #sprite_pointer_emerald_frame1
    sta SPRITE_POINTERS+3
    lda #GREEN
    sta SPRITE_COLORS+3
    lda #64
    sta SPRITE_LOCATIONS+6
    lda #218
    sta SPRITE_LOCATIONS+7

    // MSB X: sprites 1 and 3 have X >= 256 (bits 1 and 3)
    lda #%00001010
    sta SPRITE_MSB_X

    // Enable sprites 0-3
    lda #%00001111
    sta SPRITE_ENABLE

    // Reset animation counters
    lda #0
    sta menu_anim_frame
    sta menu_dollar_frame
    rts

//////////////////////////////////////////////////////////////////////////////////////
// mainmenu_animate: advance corner sprite animation on each TIMER_ENEMY_MOVE tick
mainmenu_animate:
    GetTimerTr(TIMER_ENEMY_MOVE)
    bne mma_tick
    rts
mma_tick:
    FullReset(TIMER_ENEMY_MOVE)

    // Toggle 2-frame counter; A = new frame (0 or 1)
    lda menu_anim_frame
    eor #1
    sta menu_anim_frame

    // Bat (sprite 0): frame1 when 0, frame2 when 1
    bne mma_bat_f2
    lda #sprite_pointer_bat_frame1
    jmp mma_bat_set
mma_bat_f2:
    lda #sprite_pointer_bat_frame2
mma_bat_set:
    sta SPRITE_POINTERS+0

    // Energy (sprite 2)
    lda menu_anim_frame
    bne mma_energy_f2
    lda #sprite_pointer_energy_frame1
    jmp mma_energy_set
mma_energy_f2:
    lda #sprite_pointer_energy_frame2
mma_energy_set:
    sta SPRITE_POINTERS+2

    // Emerald (sprite 3)
    lda menu_anim_frame
    bne mma_emerald_f2
    lda #sprite_pointer_emerald_frame1
    jmp mma_emerald_set
mma_emerald_f2:
    lda #sprite_pointer_emerald_frame2
mma_emerald_set:
    sta SPRITE_POINTERS+3

    // Dollar (sprite 1): 3-frame cycle 0->1->2->0
    lda menu_dollar_frame
    cmp #2
    bne mma_dollar_inc
    lda #0
    jmp mma_dollar_store
mma_dollar_inc:
    clc
    adc #1
mma_dollar_store:
    sta menu_dollar_frame       // A = new frame (0, 1, or 2)
    cmp #1
    bcc mma_dollar_f1           // A < 1 (= 0): frame 1
    beq mma_dollar_f2           // A = 1: frame 2
    lda #sprite_pointer_dollar_frame3
    jmp mma_dollar_set
mma_dollar_f1:
    lda #sprite_pointer_dollar_frame1
    jmp mma_dollar_set
mma_dollar_f2:
    lda #sprite_pointer_dollar_frame2
mma_dollar_set:
    sta SPRITE_POINTERS+1
    rts

.encoding "petscii_upper"
str_credit:
.text "BY DEADLINE / CITYXEN 2026"
.byte 0
