.segment Level1 [allowOverlap]
*=C_LEVEL_ROUTINE "LEVEL 1 ROUTINE"
    lda #$93; jsr KERNAL_CHROUT
	jmp over_level_1_message
level_1_message: .text level_list.get(1); .byte 0
over_level_1_message:
	PrintStrAtColor(0,0,"level:",WHITE)
	PrintAtRainbow(6,0,level_1_message)

	// PrintTiles(0,1)
	jsr sub_level_1_draw_tiles
	// PrintTileAtColor(0,2,33,BLUE)

	// Setup game sprites
    lda #$01; sta SPRITE_ENABLE
	lda #$00; sta SPRITE_MULTICOLOR
    lda #$00; sta SPRITE_MSB_X
	lda BLUE; sta SPRITE_0_COLOR
	lda #$80; sta SPRITE_0_POINTER
//    lda #$c9; sta SPRITE_1_POINTER
//              sta SPRITE_7_POINTER
//    lda #$ca; sta SPRITE_2_POINTER
//    lda #$cb; sta SPRITE_3_POINTER
//    lda #$cc; sta SPRITE_4_POINTER
//    lda #$cd; sta SPRITE_5_POINTER
//    lda #$ce; sta SPRITE_6_POINTER


level_1_game_loop:
	jsr sub_read_joystick_2
	jsr sub_update_hud
	jsr sub_move_player
	jmp level_1_game_loop

tiledata:
.byte 33,25,34,35,36,37,38,39,40,41,42,43,33,25,34
tilecolor:
.byte 5,GREEN,4,5,6,7,8,9,10,11,12,13,14,15,5
xpos:
.byte 0
ypos:
.byte 0

sub_level_1_draw_tiles:
	ldx #$00
	lda #40
	pha
keepgoin:

	pla
	tay
	pha

	lda tiledata,x; asl; asl
    sta SCREEN_RAM,y

	adc #$01
	iny
	sta SCREEN_RAM,y

	pha
	tya
	adc #39
	tay
	pla

	adc #$01
    sta SCREEN_RAM,y
	adc #$01
	iny
	sta SCREEN_RAM,y

	pla
	tay
	pha

	lda tilecolor,x
	sta COLOR_RAM,y
	iny
	sta COLOR_RAM,y

	pha
	tya
	adc #39
	tay
	pla

    sta COLOR_RAM,y
	iny
    sta COLOR_RAM,y

	pla
	adc #2
	pha
	// iny
	// tya
	// pha

	inx
	cpx #C_MAX_X_TILES
	bne keepgoin
	pla
	rts



/*


    lda var_tile*4+1
    sta SCREEN_RAM + #var_tile_cursor_x/2 + 1 + #var_tile_cursor_y/2*40
    lda var_color
    sta COLOR_RAM  + #var_tile_cursor_x/2 + 1 + #var_tile_cursor_y/2*40
    lda var_tile*4+2
    sta SCREEN_RAM + #var_tile_cursor_x/2 + (#var_tile_cursor_y/2+1)*40
    lda var_color
    sta COLOR_RAM  + #var_tile_cursor_x/2 + (#var_tile_cursor_y/2+1)*40
    lda var_tile*4+3
    sta SCREEN_RAM + #var_tile_cursor_x/2 + 1 + (#var_tile_cursor_y/2+1)*40
    lda var_color
    sta COLOR_RAM  + #var_tile_cursor_x/2 + 1 + (#var_tile_cursor_y/2+1)*40
    */
