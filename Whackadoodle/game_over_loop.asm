//////////////////////////////////////////////////////////////
// WHACKADOODLE for C64 by Deadline / CityXen 2024
//
// Cartridge code & Meatloaf support by Jaime Idolpx
//
// Fairground tune by Saul Cross
//
// Thanks to Logg & the Atlanta Historical Computing Society 
// (AHCS) for support and play testing
//
//////////////////////////////////////////////////////////////
// You will need the following repo in order to compile this
// https://github.com/cityxen/Commodore64_Programming
// use -l "path-to-lib" in KickAss command line 
//////////////////////////////////////////////////////////////

game_over:

	jsr MLHS_NAME_ENTRY

	lda #$00
	sta screen_draw
	jsr draw_gameover
	PrintXY(user_name,23,9)

	sfx_v1_play(SFX_GAME_OVER)
	
	jsr pause1

	ldx #0
	ldy #0
	lda #music.startSong-1						//<- Here we get the startsong and init address from the sid file
	jsr music.init

	lda dev_mode
	beq !+
	lda #$00
	jmp !++
!:
	lda #$01
!:
	sta play_music

	jsr reset_timer1
	jsr reset_timer2
	jsr reset_timer3

	lda #BUTTON_ACTION_G_OVER
	sta USER_PORT_DATA

game_over_loop:

	lda irq_timer3_tr
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
	lda irq_timer1_tr
	cmp #02
	bcc game_over_loop
	lda #$00
	sta irq_timer1_tr // reset timer
	// jsr randomly_flash_buttons
	clc
	lda irq_timer2_tr
	cmp #$02
	bcc game_over_loop
	lda #$00
	sta irq_timer2_tr // reset timer
	// toggle screen to draw
	inc screen_draw
	lda screen_draw
	bne !+
	jsr draw_gameover

	PrintXY(user_name,23,9)

	jmp game_over_loop
!:
	lda #$ff
	sta screen_draw

	lda MLHS_ENABLE
	beq !+
	jsr MLHS_DRAW
!:
	
	jmp game_over_loop

