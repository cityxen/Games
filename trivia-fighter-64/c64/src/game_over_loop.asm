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
	
	ResetTimer(TIMER_1)
	lda #$00
	SetTimerTr(TIMER_1)
	
	ResetTimer(TIMER_2)
	lda #$00
	SetTimerTr(TIMER_2)

	ResetTimer(TIMER_SCREEN_CHANGE)
	lda #$00
	SetTimerTr(TIMER_SCREEN_CHANGE)
	
	lda #BUTTON_ACTION_G_OVER
	sta USER_PORT_DATA

game_over_loop:

	GetTimerTr(TIMER_SCREEN_CHANGE)
	cmp #03 // time out
	bne !+
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
	jmp restart // and go back to attract mode
!:

!:
	//////////////////////////////
	// Get Joystick Input
	jsr il_get_j1_m2
	jsr il_get_j2_m2
	// jsr input_get_button
	lda J1_B_RED
	beq !+
	lda J1_B_GREEN 
	beq !+
	lda J1_B_YELLOW
	beq !+
 	lda J1_B_BLUE
	beq !+
	lda J1_B_WHITE
	beq !+
	jmp !++
!:
	jmp restart
!:
	clc
	GetTimerTr(TIMER_2)
	cmp #02
	bcc game_over_loop
	lda #$00
	SetTimerTr(TIMER_2)
	ResetTimer(TIMER_2)
	// jsr randomly_flash_buttons
	clc
	GetTimerTr(TIMER_3)
	cmp #$02
	bcc game_over_loop
	lda #$00
	SetTimerTr(TIMER_3)
	ResetTimer(TIMER_3)
	// toggle screen to draw
	inc screen_draw
	lda screen_draw
	bne !+
	jsr draw_gameover

	jmp game_over_loop
!:
	lda #$ff
	sta screen_draw	
	jmp game_over_loop

