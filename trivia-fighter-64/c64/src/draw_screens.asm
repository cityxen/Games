//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Draw main screen

draw_main_screen:
	PrintUpperCase();
	jsr wait_vbl
	jsr init_sprites_ms
	DrawPetMateScreen(main_screen)

	rts

//////////////////////////////////////////////////////////////////
// Draw LOGIN screen

draw_select_char:
	PrintLowerCase()
	jsr wait_vbl
	jsr init_sprites_select_char
	DrawPetMateScreen(select_char)
	// jsr draw_title
	rts

//////////////////////////////////////////////////////////////////
// Draw Instruct Screen

draw_instruct:
	jsr wait_vbl
	PrintLowerCase()
	DrawPetMateScreen(instruct_screen)
	
	jsr debug_stuff
	jsr init_sprites_iiy
	// jsr draw_title
 	rts 

//////////////////////////////////////////////////////////////////
// Draw Play Screen

draw_play_screen:
	PrintLowerCase()
	jsr wait_vbl
	jsr init_sprites_play
	lda #$00
	sta $d020
	DrawPetMateScreen(play_screen)
 	rts

//////////////////////////////////////////////////////////////////
// Draw game over

draw_gameover:
	jsr wait_vbl
	DrawPetMateScreen(gameover_screen)
	jsr debug_stuff
	jsr init_sprites_ms
	// jsr draw_score_game_over0
	rts

draw_title:
	PrintColor(WHITE)
	PrintReverseOn()
	PrintPlot(0,0)
	Print(GAME_NAME)
	PrintChr(32)
	PrintChr(32)
	Print(VERSION)
	PrintReverseOff()
	rts

draw_loading_screen:
	jsr init_sprites_load_screen

	lda #ml_loading_screen_bg_color
	sta BORDER_COLOR
	sta BACKGROUND_COLOR
	
	PrintClear()
	PrintLowerCase()
	PrintChr(ml_loading_screen_txt_color)
	PrintDown(12)
	PrintRight(7)
	Print(MLHL_HOTLOAD_LOADING_TEXT)

	FullReset(TIMER_1)
!:
	GetTimerTr(TIMER_1)
	beq !-

	rts

/////////////////////////////////////////////////////
// Draw mode
// draw_mode: rts


///////////////////////////////////////////////////
// Draw Score
// draw_score_game_on: 	// DrawScore(GAME_ON_SCORE_LOC_X,GAME_ON_SCORE_LOC_Y) 	rts
// draw_score_game_over:	// DrawScore(GAME_OVER_SCORE_LOC_X,GAME_OVER_SCORE_LOC_Y) 	rts
