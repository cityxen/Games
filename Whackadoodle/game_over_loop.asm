
game_over:

	lda #$01
	sta screen_draw
	jsr draw_gameover
	jsr play_sound_gameover
	jsr pause

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

	jsr get_key
	cmp #KEY_R
	bne !+
	jmp restart
!:

!gol:
	// lda JOYSTICK_PORT_1
	jsr get_button
	cmp #BUTTON_RED
	beq !gol+
	cmp #BUTTON_GREEN 
	beq !gol+
	cmp #BUTTON_YELLOW
	beq !gol+
 	cmp #BUTTON_BLUE
	beq !gol+
	cmp #BUTTON_WHITE
	beq !gol+
	jmp !gol++
!gol:
	jmp restart
!gol:
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
	cmp #$01
	bne !gol+
	lda #$00
	sta screen_draw
!gol:
	lda screen_draw
	cmp #$00 
	bne !gol+
	jsr draw_gameover
	jmp game_over_loop
!gol:
	cmp #$01
	bne !gol+
	//jsr draw_qr
!gol:
	jmp game_over_loop


game_entry:

	lda #$02
	sta $d020
	sta $d021

	lda #$93
	jsr $ffd2
!:
	jmp !-
