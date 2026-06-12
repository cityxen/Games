//////////////////////////////////////////////////////////////////////////////////////
//
// TRIVIA FIGHTERS 64 for C64
//
//                            by Deadline / CityXen 2026
// 
// Dependencies:
// The include folder from: https://github.com/cityxen/retro-dev-tools/include/commodore64
// must be in kickassembler path in the KickAss.cfg file:
//   -libdir "PATHTO:\dev\cityxen\retro-dev-tools\include\commodore64"
//
// CityXen Videos: https://youtube.com/@cityxen
// CityXen Games: https://cityxen.itch.io
//
//////////////////////////////////////////////////////////////////////////////////////

init_sprites:
//////////////////////////////////////////////////////////////
// Initialize Sprites (MAIN SCREEN TURN ON)
init_sprites_ms:

	lda #%11101100
	sta SPRITE_ENABLE

	lda #sprite_multi_color_1
	sta SPRITE_MULTICOLOR_0
	lda #sprite_multi_color_2
	sta SPRITE_MULTICOLOR_1
	
	ldx player_1_avatar
	lda cxn_avatar_sprite_color_i,x
	sta cxn_avatar_sprite_color_i+CXN_SPR_COLOR_P1_HEAD // head color follows avatar
	ldx #$06
	jsr sobj_set_color

	ldx player_1_avatar
	lda cxn_avatar_sprite_pointer_i,x
	CopySpriteA(sp_ptr_p1_head)

	ldx player_2_avatar
	lda cxn_avatar_sprite_color_i,x
	sta cxn_avatar_sprite_color_i+CXN_SPR_COLOR_P2_HEAD // head color follows avatar
	ldx #$03
	jsr sobj_set_color

	ldx player_2_avatar
	lda cxn_avatar_sprite_pointer_i,x
	ReverseSpriteMultiColorA(sp_ptr_p2_head)

	rts


//////////////////////////////////////////////////////////////
// Initialize Sprites (IT INSTRUCT YOU)
init_sprites_iiy:
	
	rts

//////////////////////////////////////////////////////////////
// Initialize Sprites (Select Char)
init_sprites_game_init:
init_sprites_select_char:

	lda #%00111111
	//ora SPRITE_ENABLE
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
	lda #$00
	
	lda #%00010010
	ora SPRITE_ENABLE
	sta SPRITE_ENABLE
	sta SPRITE_PRIORITY
	sta SPRITE_MULTICOLOR
	lda #$00
	sta SPRITE_EXPAND_X
	sta SPRITE_EXPAND_Y	

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
	lda cxn_avatar_sprite_pointer_i,x
	ReverseSpriteMultiColorA(sp_ptr_p2_head)
	lda #sp_ptr_p2_head
	sta SPRITE_4_POINTER
	rts

//////////////////////////////////////////////////////////////
// Initialize Sprites (Load Screen)
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

//////////////////////////////////////////////////////////////
// Initialize Sprites (Game Over Screen)
init_sprites_game_over:
	
	
	lda #%00010010
	ora SPRITE_ENABLE
	sta SPRITE_ENABLE
	sta SPRITE_PRIORITY

	lda #%00010010
	sta SPRITE_EXPAND_X
	sta SPRITE_EXPAND_Y	
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
	lda cxn_avatar_sprite_pointer_i,x
	ReverseSpriteMultiColorA(sp_ptr_p2_head)
	lda #sp_ptr_p2_head
	sta SPRITE_4_POINTER
	
	rts


construct_sprite_body_p1:
construct_sprite_body_p2:
	rts
