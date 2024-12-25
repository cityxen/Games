//////////////////////////////////////////////////////////////////
// Main loop

restart:

	lda meatloaf_hiscore_support
	beq !+
	jsr MLHS_API_GET_SCORE
!:

	lda #00
	sta sound_playing
	jsr sfk_clear

	lda dev_play_music
	sta play_music

	ldx #0
	ldy #0
	lda #music.startSong-1 // <- Here we get the startsong and init address from the sid file
	jsr music.init

	lda #$ff // reset user port values to output and zero
	sta USER_PORT_DATA_DIR
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA

	jsr draw_main_screen

	jsr pause

	jsr reset_timer2
	jsr reset_timer1

	lda #$02
	sta screen_draw

main_loop:

	// check if "logged in"
	// lda user_name
	// cmp #$ff
	// bne !+
	// jsr draw_login_screen
// !:
		
	jsr debug_stuff

	lda trig_1
	beq !ml+
	jsr reset_timer1
	jsr randomly_flash_buttons

	jsr wad_get_key

	cmp #KEY_M
	bne !gl+
	inc play_music
	lda play_music
	and #%00000001
	sta play_music
!gl:	
	cmp #KEY_L
	bne !gl+
	StrCpy(user_name_empty,user_name,16)
!gl:
	
!ml:
	jsr wad_get_button

	cmp #BUTTON_BLUE
	bne !nbc+
	StrCpy(user_name_empty,user_name,16)
	jmp !ml+
!nbc:
	cmp #BUTTON_RED
	bne !nbc+
	lda #MODE_EASY
	sta whack_mode
	jmp !ml+
!nbc:
	cmp #BUTTON_YELLOW
	bne !nbc+
	lda #MODE_NORMAL
	sta whack_mode	
	jmp !ml+
!nbc:
	cmp #BUTTON_WHITE
	bne !ml++
	lda #MODE_HARD
	sta whack_mode	
	jmp !ml+

!ml:

	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
	
	jsr game_setup_doodle
	jmp game_start
	
!ml:
	lda trig_2
	cmp #$02
	bcs !ml+
	jmp main_loop
!ml:
	lda #$00
	sta trig_2 // reset timer

	// toggle screen to draw
	inc screen_draw
	lda screen_draw
	cmp #$03
	bne !ml+
	lda #$00
	sta screen_draw

!ml:

	lda screen_draw
	cmp #$00 
	bne !sdl+
	jsr draw_main_screen
	jmp main_loop
!sdl:
	cmp #$01
	bne !sdl+
	jsr draw_instruct
	jmp main_loop
!sdl:
	cmp #$02
	bne !sdl+
	lda meatloaf_hiscore_support
	beq !+
	jsr draw_meatloaf_hiscores
	jmp main_loop
!:
	jsr draw_instruct
!sdl:
	jmp main_loop


