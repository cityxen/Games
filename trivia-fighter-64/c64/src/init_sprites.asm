//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

//////////////////////////////////////////////////////////////
// Initialize Sprites (MAIN SCREEN TURN ON)

init_sprites:
init_sprites_ms:

	lda #sprite_multi_color_1
	sta SPRITE_MULTICOLOR_0
	lda #sprite_multi_color_2
	sta SPRITE_MULTICOLOR_1
	
	lda #%00010010
	sta SPRITE_ENABLE
	sta SPRITE_PRIORITY
	lda #%00010010
	sta SPRITE_EXPAND_X
	sta SPRITE_EXPAND_Y
	lda #$ff
	sta SPRITE_MULTICOLOR
	lda #$00
	sta SPRITE_PRIORITY

	lda #main_sprite_1_x
	sta SPRITE_1_X
	lda #main_sprite_1_y
	sta SPRITE_1_Y

	lda #main_sprite_4_x
	sta SPRITE_4_X
	lda #main_sprite_4_y
	sta SPRITE_4_Y

	lda #%00010000
	sta SPRITE_MSB_X	
	
	ldx player_1_avatar
	lda cxn_avatar_sprite_pointer_i,x
	sta SPRITE_1_POINTER
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_1_COLOR

	ldx player_2_avatar
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_4_COLOR

	ldx player_2_avatar
	lda cxn_avatar_sprite_pointer_i,x

	ReverseSpriteMultiColorA(sp_ptr_a)
	lda #sp_ptr_a
	sta SPRITE_4_POINTER
	
	rts

//////////////////////////////////////////////////////////////
// Initialize Sprites (IT INSTRUCT YOU)

init_sprites_iiy:
	lda #$00
	sta SPRITE_ENABLE
	rts

init_sprites_game_init:

//////////////////////////////////////////////////////////////
// Initialize Sprites (Select Char)

init_sprites_select_char:
	lda #$ff
	sta SPRITE_ENABLE
	lda #$00
	sta SPRITE_EXPAND_X
	sta SPRITE_EXPAND_Y
	lda #$00
	sta $D01B
	lda #$ff
	sta SPRITE_MULTICOLOR
	lda #sprite_multi_color_1
	sta SPRITE_MULTICOLOR_0
	lda #sprite_multi_color_2
	sta SPRITE_MULTICOLOR_1
	lda #%00110000
	sta SPRITE_MSB_X
	rts

//////////////////////////////////////////////////////////////
// Initialize Sprites (PLAY)

init_sprites_play:

	lda #sprite_multi_color_1
	sta SPRITE_MULTICOLOR_0
	lda #sprite_multi_color_2
	sta SPRITE_MULTICOLOR_1
	
	lda #%00010010
	sta SPRITE_ENABLE
	sta SPRITE_PRIORITY
	lda #$00 //00010010
	sta SPRITE_EXPAND_X
	sta SPRITE_EXPAND_Y
	lda #$ff
	sta SPRITE_MULTICOLOR
	lda #$00
	sta SPRITE_PRIORITY

	lda #trivia_sprite_1_x
	sta SPRITE_1_X
	lda #trivia_sprite_1_y
	sta SPRITE_1_Y

	lda #trivia_sprite_4_x
	sta SPRITE_4_X
	lda #trivia_sprite_4_y
	sta SPRITE_4_Y

	lda #%00010000
	sta SPRITE_MSB_X	
	
	ldx player_1_avatar
	lda cxn_avatar_sprite_pointer_i,x
	sta SPRITE_1_POINTER
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_1_COLOR

	ldx player_2_avatar
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_4_COLOR

	ldx player_2_avatar
	lda cxn_avatar_sprite_pointer_i,x
	ReverseSpriteMultiColorA(sp_ptr_a)
	lda #sp_ptr_a
	sta SPRITE_4_POINTER
	

	rts

//////////////////////////////////////////////////////////////
// Initialize Sprites (MESSAGE)

init_sprites_msg:

	lda #%00000001
	sta SPRITE_ENABLE
	lda #%00000001
	sta SPRITE_EXPAND_X
	lda #%00000001
	sta SPRITE_EXPAND_Y
	lda #$ff
	sta SPRITE_PRIORITY
	lda #$01
	sta SPRITE_MULTICOLOR
	//lda #sp_comic_m
	sta SPRITE_1_POINTER
	//lda #comic_sprite_x
	sta SPRITE_1_X
	//lda #comic_sprite_y
	sta SPRITE_1_Y
	lda #RED
	sta SPRITE_1_COLOR

	rts

init_sprites_load_screen:
	lda #%00000010
	sta SPRITE_ENABLE
	lda #%00000010
	sta SPRITE_EXPAND_X
	lda #%00000010
	sta SPRITE_EXPAND_Y
	lda #$ff
	sta SPRITE_PRIORITY
	lda #$03
	sta SPRITE_MULTICOLOR
	lda #sprite_multi_color_1
	sta SPRITE_MULTICOLOR_0
	lda #sprite_multi_color_2
	sta SPRITE_MULTICOLOR_1
	lda #sp_disk_load
	sta SPRITE_1_POINTER
	lda #sp_disk_load_x
	sta SPRITE_1_X
	lda #sp_disk_load_y
	sta SPRITE_1_Y
	lda #RED
	sta SPRITE_1_COLOR
	rts

init_sprites_game_over:


	lda #sprite_multi_color_1
	sta SPRITE_MULTICOLOR_0
	lda #sprite_multi_color_2
	sta SPRITE_MULTICOLOR_1
	
	lda #%00010010
	sta SPRITE_ENABLE
	sta SPRITE_PRIORITY
	lda #%00010010
	sta SPRITE_EXPAND_X
	sta SPRITE_EXPAND_Y
	lda #$ff
	sta SPRITE_MULTICOLOR
	lda #$00
	sta SPRITE_PRIORITY

	lda #game_over_sprite_1_x
	sta SPRITE_1_X
	lda #game_over_sprite_1_y
	sta SPRITE_1_Y

	lda #game_over_sprite_4_x
	sta SPRITE_4_X
	lda #game_over_sprite_4_y
	sta SPRITE_4_Y

	lda #%00010000
	sta SPRITE_MSB_X	
	
	ldx player_1_avatar
	lda cxn_avatar_sprite_pointer_i,x
	sta SPRITE_1_POINTER
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_1_COLOR

	ldx player_2_avatar
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_4_COLOR

	ldx player_2_avatar
	lda cxn_avatar_sprite_pointer_i,x

	ReverseSpriteMultiColorA(sp_ptr_a)
	lda #sp_ptr_a
	sta SPRITE_4_POINTER

	rts