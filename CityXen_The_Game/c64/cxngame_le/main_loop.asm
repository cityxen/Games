/////////////////////////////////////////////////////////////////////////////////

main:
    jsr init_cursors
    lda #%00001000 // box sprite
    sta sprite_visible
    lda #%00001000
    sta sprites_animated
    AssignSpriteAnim(3,sprite_select_box)
    SetSpriteColor(3,YELLOW)
    MoveSprite(3,100,100)  

    jsr draw_level_edit_menu

    lda #$01 
    sta var_cursor_map_x
    sta var_cursor_map_y
    sta var_cursor_sel_x
    sta var_cursor_sel_y

    jsr draw_room_border
    jsr draw_tiles_for_selection
    jsr draw_edit_tile

/////////////////////////////////////////////////////////////////////////////////

main_game_loop:
    jsr mgl_debugline
    jsr draw_select_box
    jsr update_sprites
    jsr KERNAL_GETIN
    ReadKeyJMP('Q',main_menu)
    ReadKeyJSR(KEY_RETURN,return_key_main)
    ReadKeyJSR(KEY_CURSOR_RIGHT,mv_cursor_right)
    ReadKeyJSR(KEY_CURSOR_DOWN,mv_cursor_down)
    ReadKeyJSR(KEY_CURSOR_LEFT,mv_cursor_left)
    ReadKeyJSR(KEY_CURSOR_UP,mv_cursor_up)
    ReadKeyJSR(KEY_F1,edit_mode)
    jmp main_game_loop

/////////////////////////////////////////////////////////////////////////////////

draw_edit_tile:
    lda var_edit_tile
    ldx #08
    ldy #01
    jsr draw_tile
    rts

return_key_main:
    lda var_edit_mode
    cmp #$01
    beq !rkm++
!rkm:
    // place the tile at x,y in the map
    lda var_edit_tile
    ldx var_cursor_map_x
    inx
    ldy var_cursor_map_y
    iny
    iny
    jsr draw_tile
    rts
!rkm:
    // change the selected tile
    lda var_cursor_sel_x
    sec
    sbc #$01
    sta var_edit_tile
    ldx var_cursor_sel_y
    dex
    beq !rkm++
!rkm:    
    clc
    lda var_edit_tile
    adc #$03
    sta var_edit_tile
    dex
    bne !rkm-
!rkm:
    jsr draw_edit_tile
    rts

/////////////////////////////////////////////////////////////////////////////////

mgl_debugline:
    lda var_cursor_map_x
    PrintHex(0,24)
    lda var_cursor_x_loc
    PrintHex(3,24)
    lda var_cursor_map_y
    PrintHex(6,24)
    lda var_cursor_y_loc
    PrintHex(9,24)
    lda var_edit_mode
    PrintHex(12,24)
    lda var_edit_tile
    PrintHex(15,24)
    rts

/////////////////////////////////////////////////////////////////////////////////

edit_mode:
    inc var_edit_mode
    lda var_edit_mode
    cmp #$02
    bne !em+
    lda #$00
    sta var_edit_mode
!em:
    lda var_edit_mode
    rts

/////////////////////////////////////////////////////////////////////////////////

mv_cursor_right:
    lda var_edit_mode
    cmp #$01
    beq !mcr++
    inc var_cursor_map_x
    lda var_cursor_map_x
    cmp #$0f
    bne !mcr+
    dec var_cursor_map_x
!mcr:
    rts
!mcr:
    inc var_cursor_sel_x
    lda var_cursor_sel_x
    cmp #$04
    bne !mcr+
    dec var_cursor_sel_x
!mcr:
    rts

/////////////////////////////////////////////////////////////////////////////////

mv_cursor_down:
    lda var_edit_mode
    cmp #$01
    beq !mcd++
    inc var_cursor_map_y
    lda var_cursor_map_y
    cmp #$0a
    bne !mcd+
    dec var_cursor_map_y
!mcd:    
    rts
!mcd:
    inc var_cursor_sel_y
    lda var_cursor_sel_y
    cmp #$0b
    bne !mcd+
    dec var_cursor_sel_y
!mcd:    
    rts

/////////////////////////////////////////////////////////////////////////////////

mv_cursor_left:
    lda var_edit_mode
    cmp #$01
    beq !mcl++
    dec var_cursor_map_x
    lda var_cursor_map_x
    cmp #$00
    bne !mcl+
    inc var_cursor_map_x
!mcl:
    rts
!mcl:
    dec var_cursor_sel_x
    lda var_cursor_sel_x
    cmp #$00
    bne !mcl+
    inc var_cursor_sel_x
!mcl:
    rts

/////////////////////////////////////////////////////////////////////////////////

mv_cursor_up:
    lda var_edit_mode
    cmp #$01
    beq !mcu++
    dec var_cursor_map_y
    lda var_cursor_map_y
    cmp #$00
    bne !mcu+
    inc var_cursor_map_y
!mcu:
    rts
!mcu:
    dec var_cursor_sel_y
    lda var_cursor_sel_y
    cmp #$00
    bne !mcu+
    inc var_cursor_sel_y
!mcu:
    rts

/////////////////////////////////////////////////////////////////////////////////

draw_select_box:
    lda var_edit_mode
    cmp #$01
    beq !draw_cursor_select_tile+
    lda #$1a
    sta var_cursor_x_loc
    lda #$3f
    sta var_cursor_y_loc
    lda #%00000000
    and sprite_3_loc
    sta sprite_3_loc
    lda var_cursor_map_x
    tax
!dsb:
    // move sprite 2*8*x,2*8*y
    lda var_cursor_x_loc
    adc #$10
    sta var_cursor_x_loc
    dex
    bne !dsb-

    lda var_cursor_x_loc
    sta sprite_3_loc+1   
    lda var_cursor_map_y
    tax
!dsb:
    lda var_cursor_y_loc
    adc #$10
    sta var_cursor_y_loc
    dex
    bne !dsb-
    lda var_cursor_y_loc
    sta sprite_3_loc+2
    rts
!draw_cursor_select_tile:
    // move sprite 2*8*x + map_width ,2*8*y
    lda #$09
    sta var_cursor_x_loc
    lda #$30
    sta var_cursor_y_loc
    lda #%00001111
    ora sprite_3_loc
    sta sprite_3_loc
    lda var_cursor_sel_x
    tax
!dsb:
    // move sprite 2*8*x,2*8*y
    lda var_cursor_x_loc
    adc #$10
    sta var_cursor_x_loc
    dex
    bne !dsb-

    lda var_cursor_x_loc
    sta sprite_3_loc+1   
    lda var_cursor_sel_y
    tax
!dsb:
    lda var_cursor_y_loc
    adc #$10
    sta var_cursor_y_loc
    dex
    bne !dsb-
    lda var_cursor_y_loc
    sta sprite_3_loc+2
    rts

/////////////////////////////////////////////////////////////////////////////////

init_cursors:
    lda #$00
    sta var_cursor_map_x
    sta var_cursor_map_y
    sta var_cursor_sel_x
    sta var_cursor_sel_y
    sta var_edit_mode // 0=map edit, 1=select tile
    rts

/////////////////////////////////////////////////////////////////////////////////

draw_level_edit_menu:
    ClearScreenColors(BLUE,WHITE)
    lda #$17
    ldx #$01
    ldy #$00
    jsr draw_tile
    lda #$18
    ldx #$02
    ldy #$00
    jsr draw_tile
    lda #$19
    ldx #$03
    ldy #$00
    jsr draw_tile
    lda #$1a
    ldx #$04
    ldy #$00
    jsr draw_tile
    lda #$1b
    ldx #$05
    ldy #$00
    jsr draw_tile
    lda #$1c
    ldx #$06
    ldy #$00
    jsr draw_tile
    lda #$1d
    ldx #$07
    ldy #$00
    jsr draw_tile
    PokeStringColor(1024+16,main_menu_text_title,YELLOW)
    PokeStringColor(1024+16+40,main_menu_text_level_editor,WHITE)
    rts

/////////////////////////////////////////////////////////////////////////////////

draw_tiles_for_selection:
    lda #$00
    sta var_t1 // temp holder for tile iteration
    lda #$11
    sta var_t2
    lda #$02
    sta var_t3  
!dtfs:
    lda var_t3
    tay
    lda var_t2
    tax
    lda var_t1
    jsr draw_tile
    inc var_t1
    inc var_t2
    lda var_t2
    cmp #$14
    bne !dtfs+
    inc var_t3
    lda #$11
    sta var_t2
!dtfs:
    lda var_t3
    cmp #$0c
    bne !dtfs--
    rts

/////////////////////////////////////////////////////////////////////////////////