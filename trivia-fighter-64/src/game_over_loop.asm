//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

game_over:
	
	lda #$00
	sta screen_draw
	jsr draw_gameover
	
	sfx_v1_play(SFX_GAME_OVER)
	
	ldx #0
	ldy #0
	lda #music.startSong-1						//<- Here we get the startsong and init address from the sid file
	jsr music.init

	lda #$01
	sta play_music

	ResetTimer(1)
	ResetTimer(2)
	ResetTimer(3)	
	
	lda #BUTTON_ACTION_G_OVER
	sta USER_PORT_DATA

game_over_loop:

	GetTimerTr(3)
	cmp #03 // time out
	bne !+
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
	// jmp restart // and go back to attract mode
!:

!:
	// lda JOYSTICK_PORT_1
	jsr input_get_button
	cmp #BUTTON_RED
	beq !+
	cmp #BUTTON_GREEN 
	beq !+
	cmp #BUTTON_YELLOW
	beq !+
 	cmp #BUTTON_BLUE
	beq !+
	cmp #BUTTON_WHITE
	beq !+
	jmp !++
!:
	jmp restart
!:
	clc
	GetTimerTr(1)
	cmp #02
	bcc game_over_loop
	ResetTimer(1)
	// jsr randomly_flash_buttons
	clc
	GetTimerTr(2)
	cmp #$02
	bcc game_over_loop
	ResetTimer(2)
	// toggle screen to draw
	inc screen_draw
	lda screen_draw
	bne !+
	jsr draw_gameover

	jmp game_over_loop
!:
	lda #$ff
	sta screen_draw

	// lda MLHS_ENABLE
	// beq !+
	// jsr MLHS_DRAW
// !:
	
	jmp game_over_loop

