//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

//////////////////////////////////////////////////////////////
// Game start

game_start:

	lda #0
	sta game_round_current

	lda #GAME_STEP_SELECT_
	sta game_step

	lda #PLAYER_INITIAL_HEALTH
	sta player_1_healthbar
	sta player_2_healthbar

	lda #$00
	sta player_1_avatar
	
	lda #$01
	sta player_2_avatar

	// jsr print_player_1_name
	// jsr print_player_2_name	

	lda #$00
	sta play_music

	jsr sfx_clear
	
	jsr draw_select_char
	
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
	
	// lda #$01
	// jsr set_message
	
game_loop:

	// determine game_step
	lda game_step
	cmp #GAME_STEP_SELECT_
	bne !+
	jmp game_step_select_init
!:
	cmp #GAME_STEP_SELECT
	bne !+
	jmp game_step_select
!:
	cmp #GAME_STEP_ANIM_INTRO_
	lda #0
	sta game_anim
	jmp game_step_anim_init

	// determine game over condition here

	lda player_1_healthbar
	bne !gl+
	jmp game_over
!gl:
	lda player_2_healthbar
	bne !gl+
	jmp game_over
!gl:

	lda #$00
	sta button_did_hit

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
	// jsr reset_jitter_timer
	lda message
	bne !gl-
	lda #$05
	sta button_did_hit
	lda #$09
	sta button_actually_hit
	


gl22:
!gl:
	jsr draw_countdown	
	jsr input_get_key

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
	
	jsr debug_stuff

	// check joystick port 1 values
	jsr input_get_button
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
	lda button_did_hit
	
	sfx_v1_play(SFX_POW)

	jmp game_loop

game_step_select_init:
	jsr init_sprites_game_init
	lda #$00
	sta cxn_avatar_selected
	inc game_step

game_step_select:

	// PrintHome()
	// lda cxn_avatar_selected
	// PrintHexXY(0,5)

	lda cxn_avatar_selected
	cmp #cxn_avatar_selected_both
	bne !+
	inc game_step
	jmp game_loop
!:

	jsr print_player_1_name
	jsr update_player_1_select_sprites
	jsr print_player_2_name
	jsr update_player_2_select_sprites

	jsr get_j1_m2 // update joystick
	jsr get_j2_m2

	GetTimerTr(5) // input timers
	bne !+
	jmp game_loop
!:
	ResetTimer(5)
	lda #$00
	SetTimerTr(5)

p1select:
	// check for selected already yes or no here
	lda cxn_avatar_selected
	and #cxn_avatar_selected_p1
	bne p2select

	lda j1_left
	bne !+
	jsr dec_player_1_avatar
!:
	lda j1_right
	bne !+
	jsr inc_player_1_avatar	
!:
	lda j1_button
	bne !+
	
	sfx_v1_play(SFX_GET_READY)
	
	lda cxn_avatar_selected
	ora #cxn_avatar_selected_p1
	sta cxn_avatar_selected
!:

p2select:
	// check for selected already yes or no here
	lda cxn_avatar_selected
	and #cxn_avatar_selected_p2
	bne pselectout

	lda j2_left
	bne !+
	jsr dec_player_2_avatar
!:
	lda j2_right
	bne !+
	jsr inc_player_2_avatar
!:
	lda j2_button
	bne !+
	
	sfx_v2_play(SFX_GET_READY)
	lda cxn_avatar_selected
	ora #cxn_avatar_selected_p2
	sta cxn_avatar_selected
!:
pselectout:
	jmp game_loop

game_step_anim_init:
	jsr draw_main_screen
	sfx_v2_play(SFX_GET_READY)
	inc game_step

game_step_anim:



	jmp game_loop

