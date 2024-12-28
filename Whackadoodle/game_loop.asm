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

//////////////////////////////////////////////////////////////
// Game start

game_start:

	lda initial_life
	sta whack_life

	lda whack_mode
	cmp #MODE_EASY // 10 lives
	bne !+
	lda initial_life_easy
	sta whack_life
!:
	cmp #MODE_HARD // 3 lives
	bne !+
	lda initial_life_hard
	sta whack_life
!:

	// jsr reset_score
	jsr score_reset

	lda #$00
	sta play_music
	jsr draw_play_screen
	
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA

	jsr play_sound_get_ready

	jsr draw_instruct

	jsr draw_mode

	jsr pause3

	jsr play_sound_get_ready

	lda #$01
	jsr set_message
	jsr reset_input_timer
	jsr init_sprites_play

	lda #doodle_speed_initial // initial doodle time 
	sta irq_timer_jitter_to

	jsr reset_jitter_timer

	
game_loop:

	// jsr draw_mode

	lda whack_life
	bne !gl+
	jmp game_over
!gl:

	lda #$00
	sta did_hit

	// show message (if exist)
	lda message
	beq gl22
	lda #$00
	sta SPRITE_ENABLE
	ClearScreen(BLACK)

!gl:
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
!gl:
	jsr show_message
	jsr reset_jitter_timer
	lda message
	bne !gl-
	lda #$05
	sta did_hit
	lda #$09
	sta button_actually_hit
	jsr game_setup_doodle	
gl22:
!gl:
	
	jsr draw_countdown
	
	jsr wad_get_key

	cmp #KEY_Q
	bne !gl+
	jmp game_over
!gl:
	cmp #KEY_D
	bne !gl+
	inc debug_mode
	jsr draw_play_screen
	
!gl:

	jsr wait_vbl
	inc SPRITE_0_COLOR
	jsr check_jitter_doodle
	jsr debug_stuff

	// check joystick port 1 values
	jsr wad_get_button
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

	// jsr decrement_score
	lda #$01
	sta score_math_o
	jsr score_sub

	lda #$02
	sta did_hit
	jmp !gl+

!cph:
	// bad doodle = POW (score +1)
	jsr play_sound_pow

	// jsr increment_score
	lda #$01
	jsr score_add

	lda #$03
	jsr set_message
	lda #$01
	sta did_hit
!gl:
	lda #$09
	sta button_actually_hit
	
	jmp game_loop
