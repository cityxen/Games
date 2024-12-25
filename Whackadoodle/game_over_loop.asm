
game_over:

	lda #$00
	sta screen_draw
	jsr draw_gameover
	jsr play_sound_gameover
	jsr pause

	jsr game_entry

	ldx #0
	ldy #0
	lda #music.startSong-1						//<- Here we get the startsong and init address from the sid file
	jsr music.init

	lda dev_play_music
	sta play_music

	jsr reset_timer1
	jsr reset_timer2
	jsr reset_timer3

	lda #BUTTON_ACTION_G_OVER
	sta USER_PORT_DATA

game_over_loop:

	lda trig_3 
	cmp #03 // time out
	bne !+
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
	// jmp restart // and go back to attract mode
!:

!:
	// lda JOYSTICK_PORT_1
	jsr wad_get_button
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
	lda trig_1
	cmp #02
	bcc game_over_loop
	lda #$00
	sta trig_1 // reset timer
	// jsr randomly_flash_buttons
	clc
	lda trig_2
	cmp #$02
	bcc game_over_loop
	lda #$00
	sta trig_2 // reset timer
	// toggle screen to draw
	inc screen_draw
	lda screen_draw
	bne !+
	jsr draw_gameover
	jmp game_over_loop
!:
	lda #$ff
	sta screen_draw
	jsr draw_meatloaf_hiscores
	jmp game_over_loop

game_entry:
	lda #$02
	sta $d020
	sta $d021
	lda #$93
	jsr $ffd2
	StrCpy(user_name_empty,user_name,15)
	zPrint(whack_your_name_txt)
	InputText2(user_name,15,10,10,1)
	ConvertA2P(user_name,15)
	rts
