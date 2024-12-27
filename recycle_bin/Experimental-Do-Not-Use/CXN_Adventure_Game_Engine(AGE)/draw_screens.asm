
//////////////////////////////////////////////////////////////////
// Draw main screen

draw_main_screen:
	jsr wait_vbl
	DrawPetMateScreen(was1)
	jsr debug_stuff
	jsr init_sprites_ms
	rts

//////////////////////////////////////////////////////////////////
// Draw Instruct Screen

draw_instruct:
	jsr wait_vbl
	DrawPetMateScreen(instruct)
	jsr debug_stuff
	jsr init_sprites_iiy
 	rts 

//////////////////////////////////////////////////////////////////
// Draw Play Screen

draw_play_screen:
	jsr wait_vbl
	DrawPetMateScreen(play)
 	rts

//////////////////////////////////////////////////////////////////
// Draw game over

draw_gameover:
	jsr wait_vbl
	DrawPetMateScreen(scr_gameover)
	jsr debug_stuff
	jsr init_sprites_ms
	jsr draw_score_game_over
	rts

//////////////////////////////////////////////////////////////////
// Update Play Screen

update_play_screen:
	jsr wait_vbl
 	rts 

