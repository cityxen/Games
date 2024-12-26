
game_over:

	lda #$01
	sta SCREEN_DRAW
	jsr draw_gameover
	jsr play_sound_gameover
	jsr pause

	ldx #0
	ldy #0
	lda #music.startSong-1						//<- Here we get the startsong and init address from the sid file
	jsr music.init

	lda DEV_PLAY_MUSIC
	sta PLAY_MUSIC

	jsr reset_timer1
	jsr reset_timer2
	jsr reset_timer3

game_over_loop:

	jsr get_key
	cmp #KEY_R
	bne !+
	jmp restart
!:

	jmp game_over_loop
