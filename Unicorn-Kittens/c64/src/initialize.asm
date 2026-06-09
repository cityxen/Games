//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — initialize.asm
// One-time hardware setup, then jump to the title screen.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

initialize:
    // Black sky during setup
    lda #BLACK
    sta BORDER_COLOR
    sta BACKGROUND_COLOR

    // Seed the RNG from SID voice-3 noise
    jsr random_init_sid

    // Sprites: single-colour, no expansion, drawn in front of the background
    lda #$00
    sta SPRITE_MULTICOLOR
    sta SPRITE_EXPAND_X
    sta SPRITE_EXPAND_Y
    sta SPRITE_PRIORITY
    sta SPRITE_MSB_X            // everything lives in the first 256 px
    sta SPRITE_ENABLE

    // A simple SID voice for blips (set the envelope once; notes just retrigger)
    lda #$0F
    sta SID_VOLUME_FILTER
    lda #$22
    sta SID_V1_ATK_DECAY
    lda #$86
    sta SID_V1_SUS_REL
    lda #$00
    sta SID_V1_FREQ_LOW

    lda #GS_TITLE
    sta var_game_state

    jmp main_loop_start
