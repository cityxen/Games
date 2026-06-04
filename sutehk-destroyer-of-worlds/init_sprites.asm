


//////////////////////////////////////////////////////////////////////////////////////
// init_sprites_main: place 4 animated corner sprites on the title screen
//   Sprite 0: bat       — top-left     (X=24,  Y=50)
//   Sprite 1: dollar    — top-right    (X=320, Y=50)   MSB=1
//   Sprite 2: energy    — bottom-left  (X=24,  Y=218)
//   Sprite 3: emerald   — bottom-right (X=320, Y=218)  MSB=1
init_sprites_main:
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
// game_init_screen: set up colors, sprites, and bat state for the game screen
game_init_screen:
    lda #$93            // clear screen
    jsr KERNAL_CHROUT
    lda #BLACK
    sta BACKGROUND_COLOR
    sta BORDER_COLOR
    lda #%00000001
    sta SPRITE_ENABLE           // orb sprites added dynamically by game_draw_orb_sprites
    lda #%01111111
    sta SPRITE_MULTICOLOR       // sprites 0-6 multicolor; sprite 7 (bat) excluded
    lda #sprite_multicolor_1
    sta SPRITE_MULTICOLOR_0
    lda #sprite_multicolor_2
    sta SPRITE_MULTICOLOR_1
    lda #YELLOW
    sta SPRITE_0_COLOR
    lda #GREEN
    sta SPRITE_1_COLOR
    sta SPRITE_2_COLOR
    sta SPRITE_3_COLOR
    sta SPRITE_4_COLOR
    sta SPRITE_5_COLOR
    sta SPRITE_6_COLOR
    lda #sprite_bat_color
    sta SPRITE_7_COLOR          // bat sprite color (slot 7 reserved for bat)
    lda #0
    sta bat_active
    lda #80
    sta bat_spawn_delay
    rts