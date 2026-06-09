//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — initialize.asm
// One-time hardware setup, then jump to the title screen.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

initialize:
    // Black screen during setup
    lda #BLACK
    sta BORDER_COLOR
    sta BACKGROUND_COLOR

    // 7 timers (the game mostly paces itself with frame counters)
    InitTimers(8, 30, 16, 120, 60, 8, 50)

    // Seed RNG from SID voice 3 noise
    jsr random_init_sid

    // Sprites: single-colour, no expansion, in front of the background
    lda #$00
    sta SPRITE_MULTICOLOR
    sta SPRITE_EXPAND_X
    sta SPRITE_EXPAND_Y
    sta SPRITE_PRIORITY

    // Static sprite colours
    lda #LIGHT_BLUE         // Clicky — a friendly C64 blue
    sta SPRITE_0_COLOR
    lda #LIGHT_RED          // Clone — Miss DOS red
    sta SPRITE_1_COLOR

    // Sprite pointers
    lda #sp_clicky_idle
    sta SPRITE_0_POINTER
    lda #sp_clone_idle
    sta SPRITE_1_POINTER

    lda #GS_TITLE
    sta var_game_state

    jmp main_loop_start
