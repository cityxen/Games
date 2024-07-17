
//////////////////////////////////////////////////////////////////
// Game start

game_start:
		
	// ldx #0
	// ldy #0
	// lda #music.startSong-1						//<- Here we get the startsong and init address from the sid file
	// jsr music.init
	
	lda initial_life
	sta whack_life

	jsr reset_score

	lda #$00
	sta play_music
	jsr draw_play_screen
	
	lda BUTTON_LIGHT_ALL
	sta USER_PORT_DATA

	jsr play_sound_get_ready

	jsr draw_instruct
	jsr pause

	jsr pause

	jsr play_sound_get_ready

	lda #$01	
	jsr set_message
	jsr reset_input_timer
	jsr init_sprites_play


	lda #$af // initial doodle time 
	sta irq_timer_jitter_cmp
	jsr reset_jitter_timer

	
game_loop:

	lda whack_life
	bne !gl+
	jmp game_over
!gl:

	lda #$00
	sta did_hit

	// show message (if exist)
	lda message
	beq !gl++
	lda #$00
	sta SPRITE_ENABLE
	ClearScreen(BLACK)
!gl:
	jsr init_sprites_msg
	jsr show_message
	jsr reset_jitter_timer
	lda message
	bne !gl-
	lda #$05
	sta did_hit
	lda #$09
	sta button_actually_hit
	jsr game_setup_doodle	
!gl:
	
	jsr draw_countdown
	
	jsr get_key

	cmp #KEY_Q
	bne !gl+
	jmp game_over
!gl:
	cmp #KEY_D
	bne !gl+
	inc debug_mode
	jsr draw_play_screen
	
!gl:

	inc SPRITE_0_COLOR
	jsr check_jitter_doodle
	jsr debug_stuff

	// check joystick port 1 values
	jsr get_button
	cmp #$ff
	beq exit_select_button

	!chk_buttons:
	cmp #BUTTON_RED
	bne !chk_buttons+
	lda #BUTTON_LIGHT_RED
	sta USER_PORT_DATA
	lda #$00
	sta button_actually_hit
	jmp exit_select_button

	!chk_buttons:
	cmp #BUTTON_GREEN
	bne !chk_buttons+
	lda #BUTTON_LIGHT_GREEN
	sta USER_PORT_DATA
	lda #$01
	sta button_actually_hit
	jmp exit_select_button

	!chk_buttons:
	cmp #BUTTON_YELLOW
	bne !chk_buttons+
	lda #BUTTON_LIGHT_YELLOW
	sta USER_PORT_DATA
	lda #$02
	sta button_actually_hit
	jmp exit_select_button

	!chk_buttons:
	cmp #BUTTON_BLUE
	bne !chk_buttons+
	lda #BUTTON_LIGHT_BLUE
	sta USER_PORT_DATA
	lda #$03
	sta button_actually_hit
	jmp exit_select_button

	!chk_buttons:
	cmp #BUTTON_WHITE
	bne !chk_buttons+
	lda #BUTTON_LIGHT_WHITE
	sta USER_PORT_DATA
	lda #$04
	sta button_actually_hit
	jmp exit_select_button

	!chk_buttons:

exit_select_button:

	lda button_actually_hit
	cmp button_to_hit
	beq !gl+
	cmp #$09
	beq !gl++
	// buttons don't match (miss automatic / life -1)
	jsr play_sound_miss
	lda #$02
	jsr set_message
	// life -1
	dec whack_life
	lda #$03
	sta did_hit
	
	lda #$09
	sta button_actually_hit
	jmp game_loop
!gl:
	lda doodle
	cmp #$04
	bcs !cph+
	// good doodle = WRONG (score -1 / life -1)
	jsr play_sound_wrong
	lda #$04
	jsr set_message
	// life -1
	dec whack_life
	// score -1
	jsr decrement_score
	lda #$02
	sta did_hit
	jmp !gl+

!cph:
	// bad doodle = POW (score +1)
	jsr play_sound_pow
	jsr increment_score
	lda #$03
	jsr set_message
	lda #$01
	sta did_hit
!gl:
	lda #$09
	sta button_actually_hit
	
	jmp game_loop
