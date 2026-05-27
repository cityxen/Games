main_menu:
    jsr draw_main_menu
    jsr debug_line
main_menu_loop:
    jsr update_sprites
    jsr KERNAL_GETIN
    ReadKeyJMP('Q',quit)
    jmp main_menu_loop

draw_main_menu:
    lda #%00000111
    sta sprite_visible
    lda #$1f
    sta sprites_animated

    ClearScreenColors(BLUE,WHITE)

    lda #$17
    ldx #$07
    ldy #$00
    jsr draw_tile
    lda #$18
    ldx #$08
    ldy #$00
    jsr draw_tile
    lda #$19
    ldx #$09
    ldy #$00
    jsr draw_tile
    lda #$1a
    ldx #$0a
    ldy #$00
    jsr draw_tile
    lda #$1b
    ldx #$0b
    ldy #$00
    jsr draw_tile
    lda #$1c
    ldx #$0c
    ldy #$00
    jsr draw_tile
    lda #$1d
    ldx #$0d
    ldy #$00
    jsr draw_tile
 
!dmsloop:
    PokeStringColor(1024+211,main_menu_text_title,YELLOW)
    PokeStringColor(1024+291,main_menu_text_level_editor,WHITE)
    PokeStringColor(1024+120+294,main_menu_text_edit_level,WHITE)
    PokeStringColor(1024+120+120+294,main_menu_text_quit,WHITE)
    rts


update_sprites:
    UpdateSprites()
    rts
    