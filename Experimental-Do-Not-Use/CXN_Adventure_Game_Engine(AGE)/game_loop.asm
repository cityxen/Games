
//////////////////////////////////////////////////////////////////
// Game start

game_start:

	lda PLAYER_INITIAL_LIFE
	sta PLAYER_LIFE

	lda GAME_MODE
	cmp #MODE_EASY // 10 lives
	bne !+
	lda PLAYER_INITIAL_LIFE
	sta PLAYER_LIFE
!:
	cmp #MODE_HARD // 3 lives
	bne !+
	lda PLAYER_INITIAL_LIFE
	sta PLAYER_LIFE
!:

	jsr reset_score

	lda #$00
	sta PLAY_MUSIC
	jsr draw_play_screen
	
	jsr play_sound_get_ready

	jsr draw_instruct

	jsr draw_mode

	jsr pause
	jsr pause

	jsr play_sound_get_ready

	lda #$01
	jsr set_message
	jsr reset_input_timer
	jsr init_sprites_play

	// lda #doodle_speed_initial // initial doodle time 
	// sta irq_timer_jitter_cmp

	jsr reset_jitter_timer

	
game_loop:

	jsr draw_mode

	lda PLAYER_LIFE
	bne !gl+
	jmp game_over
!gl:

	lda #$00
	sta DID_HIT

	jsr show_message
	jsr reset_jitter_timer
	
	
!gl:
	
	jsr draw_countdown
	
	jsr get_key

	cmp #KEY_Q
	bne !gl+
	jmp game_over
!gl:
	cmp #KEY_D
	bne !gl+
	inc DEBUG_MODE
	jsr draw_play_screen
	
!gl:

	// check joystick port 1 values
	jsr get_button
	cmp #$ff
	bne !+
	jmp exit_select_button
!:

exit_select_button:

	jmp game_loop
