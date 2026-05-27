main_menu:

    lda #%00010000 // select arrow
    sta sprite_visible
    lda #%00010000
    sta sprites_animated

    AssignSpriteAnim(4,sprite_arrow_thing)
    SetSpriteColor(4,CYAN)

    MoveSprite(4,100,100)
    

    jsr draw_main_menu
    jsr debug_line
    lda #$00
    sta menu_cursor
    jsr main_menu_cursor_update

main_menu_loop:
    jsr update_sprites
    jsr KERNAL_GETIN
    ReadKeyJMP('Q',quit)
    ReadKeyJSR(KEY_CURSOR_UP,mm_key_up)
    ReadKeyJSR(KEY_CURSOR_DOWN,mm_key_down)
    ReadKeyJMP(KEY_RETURN,mm_key_return)
    jmp main_menu_loop

mm_key_return:
    lda menu_cursor
    cmp #$01
    bne !mmkr+
    jmp quit
!mmkr:
    jmp main

main_menu_cursor_update:
    lda menu_cursor
    bne !mmcu+
    MoveSprite(4,110,123)
    PokeStringColor(1024+120+294,main_menu_text_edit_level,YELLOW)
    PokeStringColor(1024+120+120+294,main_menu_text_quit,WHITE)
!mmcu:
    cmp #$01
    bne !mmcu+
    MoveSprite(4,110,148)
    PokeStringColor(1024+120+294,main_menu_text_edit_level,WHITE)
    PokeStringColor(1024+120+120+294,main_menu_text_quit,YELLOW)
!mmcu:
    jsr debug_line
    rts

mm_key_up:
    dec menu_cursor
    lda menu_cursor
    cmp #$ff
    bne !mmku+
    lda #$01
    sta menu_cursor
!mmku:
    jsr main_menu_cursor_update
    rts

mm_key_down:
    inc menu_cursor
    lda menu_cursor
    cmp #$02
    bne !mmkd+
    lda #$00
    sta menu_cursor
!mmkd:
    jsr main_menu_cursor_update
    rts

draw_main_menu:
    
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
    PokeStringColor(1024+131,main_menu_text_title,YELLOW)
    PokeStringColor(1024+291,main_menu_text_level_editor,WHITE)
    PokeStringColor(1024+120+294,main_menu_text_edit_level,WHITE)
    PokeStringColor(1024+120+120+294,main_menu_text_quit,WHITE)
    rts

update_sprites:
    UpdateSprites()
    rts
    