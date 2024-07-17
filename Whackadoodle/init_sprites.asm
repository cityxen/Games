
//////////////////////////////////////////////////////////////////
// Initialize Sprites (MAIN SCREEN TURN ON)

init_sprites:
init_sprites_ms:
	lda #$00
	sta SPRITE_ENABLE
	rts

//////////////////////////////////////////////////////////////////
// Initialize Sprites (IT INSTRUCT YOU)

init_sprites_iiy:
	lda #$ff
	sta SPRITE_ENABLE
	sta SPRITE_EXPAND_X
	sta SPRITE_EXPAND_Y

	lda #$00
	sta $D01B

	lda #$00
	sta SPRITE_MULTICOLOR

	lda #sp_commodore
	sta SPRITE_0_POINTER
	lda #sp_yinyang
	sta SPRITE_1_POINTER
	lda #sp_heart
	sta SPRITE_2_POINTER
	lda #sp_star
	sta SPRITE_3_POINTER
	lda #sp_rad
	sta SPRITE_4_POINTER
	lda #sp_skull
	sta SPRITE_5_POINTER
	lda #sp_msdos
	sta SPRITE_6_POINTER
	lda #sp_dollar
	sta SPRITE_7_POINTER

	lda #%01000000
	sta SPRITE_MSB_X
	
	lda #$20
	sta SPRITE_0_X
	lda #$60
	sta SPRITE_1_X
	lda #$20
	sta SPRITE_2_X
	lda #$60
	sta SPRITE_3_X
	lda #$d0
	sta SPRITE_4_X
	lda #$ff
	sta SPRITE_5_X
	lda #$10
	sta SPRITE_6_X
	lda #$cf
	sta SPRITE_7_X
	lda #$85
	sta SPRITE_0_Y
	sta SPRITE_4_Y
	lda #$82
	sta SPRITE_1_Y
	sta SPRITE_5_Y
	lda #$b6
	sta SPRITE_2_Y
	sta SPRITE_6_Y
	lda #$b4
	sta SPRITE_3_Y
	sta SPRITE_7_Y

	lda #WHITE
	sta SPRITE_0_COLOR 
	sta SPRITE_1_COLOR 
	sta SPRITE_2_COLOR 
	sta SPRITE_3_COLOR 
	sta SPRITE_4_COLOR 
	sta SPRITE_5_COLOR 
	sta SPRITE_6_COLOR 
	sta SPRITE_7_COLOR 
	rts


//////////////////////////////////////////////////////////////////
// Initialize Sprites (PLAY)

init_sprites_play:
	lda #%00000001
	sta SPRITE_ENABLE
	lda #%00000011
	sta SPRITE_EXPAND_X
	lda #%00000001
	sta SPRITE_EXPAND_Y
	lda #$00
	sta SPRITE_MULTICOLOR
	lda #$00
	sta SPRITE_PRIORITY
	lda #WHITE
	sta SPRITE_0_COLOR 
	rts

//////////////////////////////////////////////////////////////////
// Initialize Sprites (MESSAGE)

init_sprites_msg:

	lda #%00000010
	sta SPRITE_ENABLE
	lda #%00000010
	sta SPRITE_EXPAND_X
	lda #%00000000
	sta SPRITE_EXPAND_Y
	lda #$ff
	sta SPRITE_PRIORITY
	lda #$00
	sta SPRITE_MULTICOLOR
	lda #sp_comic_m
	sta SPRITE_1_POINTER
	lda #comic_sprite_x
	sta SPRITE_1_X
	lda #comic_sprite_y
	sta SPRITE_1_Y
	lda #RED
	sta SPRITE_1_COLOR

	rts
