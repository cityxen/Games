//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

//////////////////////////////////////////////////////////////
// Game loop init
game_start:
game_loop_init:
	lda #$00
	sta game_round_current
	lda #GAME_STEP_SELECT_
	sta game_step
	lda #PLAYER_INITIAL_HEALTH
	sta player_1_healthbar
	sta player_2_healthbar
	// 1-Player mode: pick a random starting avatar for P2 (the human
	// will see the CPU walk from this start to its final pick). In
	// 2-Player mode the human starts at Clicky (0) and so does P2 by
	// convention — leave the default.
	lda number_of_players
	bne !p2_init_done+
	jsr ra_random_byte
	and #%00001111                // 0-15
	cmp #10
	bcc !p2_init_rand+             // 0-9 as-is
	lda #1
!p2_init_rand:
	sta player_2_avatar
!p2_init_done:
	lda #$00
	sta player_1_avatar
	lda #$00
	sta play_music
	jsr sfx_clear
	jsr draw_select_char
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
	// Suppress the M2 input poll for a few frames so the player-mode
	// select button press (which got us here) doesn't immediately fire
	// an avatar lock-in. The M2 history is over 8 frames; ~12 frames of
	// dead time guarantees j1_button / j2_button have fully cleared.
	FullReset(TIMER_INPUT)
	lda #12
	SetTimerTo(TIMER_INPUT)
	// fall through to the game_loop state machine
////////////////////////////////////////////////////////////
// GAME LOOP BEGIN
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
	bne !+
	lda #$00
	sta game_anim
	jmp game_step_anim_init
!:
	cmp #GAME_STEP_ANIM_INTRO
	bne !+
	jmp game_step_anim
!:
	cmp #GAME_STEP_ROUND_1_
	bne !+
	lda #$01
	sta game_round_current
	jmp game_step_round_init
!:
	cmp #GAME_STEP_ROUND_1
	bne !+
	jmp game_step_round
!:
	cmp #GAME_STEP_ANIM_1_
	bne !+
	ldx #$00                // registry index: ANIM_1
	jmp anim_cutscene_init
!:
	cmp #GAME_STEP_ANIM_1
	bne !+
	jmp anim_cutscene_run
!:
	cmp #GAME_STEP_ROUND_2_
	bne !+
	lda #$02
	sta game_round_current
	jmp game_step_round_init
!:
	cmp #GAME_STEP_ROUND_2
	bne !+
	jmp game_step_round
!:
	cmp #GAME_STEP_ANIM_2_
	bne !+
	ldx #$01                // registry index: ANIM_2
	jmp anim_cutscene_init
!:
	cmp #GAME_STEP_ANIM_2
	bne !+
	jmp anim_cutscene_run
!:
	cmp #GAME_STEP_ROUND_3_
	bne !+
	lda #$03
	sta game_round_current
	jmp game_step_round_init
!:
	cmp #GAME_STEP_ROUND_3
	bne !+
	jmp game_step_round
!:
	cmp #GAME_STEP_ANIM_3_
	bne !+
	ldx #$02                // registry index: ANIM_3
	jmp anim_cutscene_init
!:
	cmp #GAME_STEP_ANIM_3
	bne !+
	jmp anim_cutscene_run
!:
	cmp #GAME_STEP_ROUND_4_
	bne !+
	lda #$04
	sta game_round_current
	jmp game_step_round_init
!:
	cmp #GAME_STEP_ROUND_4
	bne !+
	jmp game_step_round
!:
	cmp #GAME_STEP_ANIM_4_
	bne !+
	ldx #$03                // registry index: ANIM_4
	jmp anim_cutscene_init
!:
	cmp #GAME_STEP_ANIM_4
	bne !+
	jmp anim_cutscene_run
!:
	cmp #GAME_STEP_ROUND_5_
	bne !+
	lda #$05
	sta game_round_current
	jmp game_step_round_init
!:
	cmp #GAME_STEP_ROUND_5
	bne !+
	jmp game_step_round
!:
	cmp #GAME_STEP_ANIM_FINISH_
	bne !+
	lda #$00
	sta game_anim
	jmp game_step_anim_init
!:
	cmp #GAME_STEP_ANIM_FINISH
	bne !+
	jmp game_step_anim
!:
	// determine game over condition here
	jmp game_over
// END GAME LOOP
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// GAME STEP SELECT AVATAR INIT
game_step_select_init:
	jsr init_sprites_game_init
	lda #$00
	sta cxn_avatar_selected

	jsr print_player_1_name
	jsr update_player_1_select_sprites
	jsr print_player_2_name
	jsr update_player_2_select_sprites
	// arm the 1-Player CPU P2 state machine
	jsr cpu_p2_avatar_reset
	inc game_step
// END GAME STEP SELECT AVATAR INIT
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// GAME STEP SELECT AVATAR
game_step_select:
	lda cxn_avatar_selected
	cmp #cxn_avatar_selected_both
	bne !+
	inc game_step
	jmp game_loop
!:
	// 1-Player mode: tick the CPU P2 avatar state machine first so it
	// advances regardless of whether the human has picked yet. (In 2-Player
	// mode, J2 polling below does the work.)
	lda number_of_players
	bne !+
	jsr cpu_p2_avatar_tick
!:
	// Bail out early if P2 just locked in on this frame — no need to
	// poll inputs that don't matter anymore.
	lda cxn_avatar_selected
	cmp #cxn_avatar_selected_both
	bne !+
	inc game_step
	jmp game_loop
!:
	jsr get_j1_m2 // update joystick
	jsr get_j2_m2
	GetTimerTr(TIMER_INPUT) // input timers
	bne !+
	jmp game_loop
!:
	FullReset(TIMER_INPUT)
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
	jsr update_player_1_select_sprites
!:
p2select:
	// check for selected already yes or no here
	lda cxn_avatar_selected
	and #cxn_avatar_selected_p2
	bne pselectout
	// 1-Player mode: the CPU drives P2's avatar pick; skip the j2 reads
	lda number_of_players
	bne !twop_cpu+
	jsr cpu_p2_avatar_tick
	jmp pselectout
!twop_cpu:
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
	jsr update_player_2_select_sprites
!:
pselectout:
	jmp game_loop
// END GAME STEP SELECT AVATAR
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// GAME STEP ANIM INIT
game_step_anim_init:
	PrintClear()
	lda #anim_bg_color
	sta BORDER_COLOR
	sta BACKGROUND_COLOR
	FullReset(TIMER_1)
	inc game_step
// END GAME STEP ANIM INIT
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// GAME STEP ANIM
game_step_anim: // all anims for now
	lda #$00
	sta SPRITE_ENABLE
	lda game_step
	cmp #GAME_STEP_ANIM_INTRO
	beq !+
	jmp gsa_out
!:
	lda #%00010010
	sta SPRITE_ENABLE
	sta SPRITE_EXPAND_X
	sta SPRITE_EXPAND_Y
	lda #intro_sprite_1_x
	sta SPRITE_1_X 
	lda #intro_sprite_1_y
	sta SPRITE_1_Y
	lda #intro_sprite_4_x
	sta SPRITE_4_X
	lda #intro_sprite_4_y
	sta SPRITE_4_Y
	lda #%00000000
	sta SPRITE_MSB_X
	PrintLowerCase()
	PrintHome()
	PrintDown(15)
	PrintRight(4)
	Print(player_msg)
	PrintChr('1')
	PrintRight(12)
	Print(player_msg)
	PrintChr('2')
	PrintLF()
	PrintRight(4)
	lda player_1_avatar
	jsr print_player_name
	PrintRight(10)
	lda player_2_avatar
	jsr print_player_name
	GetTimerTr(TIMER_1)
	cmp #intro_anim_time
	beq gsa_out
	jmp game_loop
gsa_out:
	inc game_step
	jmp game_loop
// END GAME STEP ANIM
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// BETWEEN-ROUND CUTSCENE GLUE (GAME_STEP_ANIM_1..4)
// The cutscene engine lives in sprite-animation.il.asm; these wrappers thread
// it through the game-step state machine. Tables are in config.asm.

// anim_cutscene_init — COMMON initializer, called once per anim step.
// In: X = animation registry index (anim_menu_tbl_* / anim_menu_m*_*)
anim_cutscene_init:
	lda anim_menu_tbl_lo,x
	sta anim_tbl_lo
	lda anim_menu_tbl_hi,x
	sta anim_tbl_hi
	lda anim_menu_m1_lo,x   // missile (special attack) tables for this cutscene
	sta anim_m1_tbl_lo
	lda anim_menu_m1_hi,x
	sta anim_m1_tbl_hi
	lda anim_menu_m2_lo,x
	sta anim_m2_tbl_lo
	lda anim_menu_m2_hi,x
	sta anim_m2_tbl_hi
	// heads show the selected avatars: refresh their table colors so
	// anim_setup picks them up
	ldx player_1_avatar
	lda cxn_avatar_sprite_color_i,x
	sta cxn_avatar_sprite_color_i+CXN_SPR_COLOR_P1_HEAD
	ldx player_2_avatar
	lda cxn_avatar_sprite_color_i,x
	sta cxn_avatar_sprite_color_i+CXN_SPR_COLOR_P2_HEAD
	// the p1 head slot's bitmap is only written by init_sprites_ms (title
	// screen, attract avatars) — recopy it from the selected avatar here
	ldx player_1_avatar
	lda cxn_avatar_sprite_pointer_i,x
	CopySpriteA(sp_ptr_p1_head)
	jsr draw_anim_screen
	jsr anim_setup
	inc game_step
	jmp game_loop

// anim_cutscene_run — advance one cutscene row per TIMER_INPUT tick.
anim_cutscene_run:
	GetTimerTr(TIMER_INPUT)
	bne !+
	jmp game_loop           // not time to advance yet
!:
	FullReset(TIMER_INPUT)
	jsr anim_step_one
	bcc !+
	jsr anim_finish         // terminator reached: clean up and advance step
	inc game_step
!:
	jmp game_loop
// END CUTSCENE GLUE
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Game Step Round Init
game_step_round_init:
	//////////////////////////////
	// load random trivia question
	jsr draw_loading_screen
	jsr trivia_load
	//////////////////////////////
	// Draw play screen
	jsr draw_play_screen

	jsr update_health_bars

	//////////////////////////////
	// Reset Timer 1, set to ROUND time
	FullReset(TIMER_1)
	lda #TIMER_ROUND
	SetTimerTo(TIMER_1)
	//////////////////////////////
	// reset buzzed in state
	lda #$00
	sta player_1_buzzed_in
	sta player_2_buzzed_in
	sta game_round_first_buzzer
	sta game_round_winner
	// arm the 1-Player CPU P2 (random delay, clears the latched "buzzed" flag)
	jsr cpu_p2_buzz_reset

	jsr print_question

	PrintHome()
	PrintDown(13)
	PrintRight(3)
	CenterAns(MLHL_DATA_ANS1)
	Print(MLHL_DATA_ANS1)
	PrintLF()
	PrintUp(1)
	PrintRight(21)
	CenterAns(MLHL_DATA_ANS2)
	Print(MLHL_DATA_ANS2)
	PrintLF()
	PrintDown(7)
	PrintRight(3)
	CenterAns(MLHL_DATA_ANS3)
	Print(MLHL_DATA_ANS3)
	PrintLF()
	PrintUp(1)
	PrintRight(21)
	CenterAns(MLHL_DATA_ANS4)
	Print(MLHL_DATA_ANS4)
	PrintPlot(9,1)
	lda player_1_avatar
	jsr print_player_name
	PrintRight(2)
	lda player_2_avatar
	jsr print_player_name
!:
	lda 1094
	cmp #32
	bne !++
	ldx #11
!:
	lda 1083,x
	sta 1084,x
	dex
	bne !-
	jmp !--
!:
	lda #'('
	sta 1095
	inc game_step
	sfx_v2_play(SFX_GET_READY)
	jmp game_loop
// END game round init
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Game Step Round
game_step_round:

	jsr input_get_key
	cmp #KEY_Q
	bne !+
	lda #$00
	sta screen_draw
	jmp restart
!:

	PrintPlot(16,24)
	PrintLowerCase()
	Print(trivia_round_text)
	lda game_round_current
	PrintHex()
	lda player_1_buzzed_in
	beq !+
	PrintPlot(3,23)
	Print(player_msg)
	PrintChr('1')
	PrintChr(' ')
	//////////////////////////////
	// Check player 1 buzz in
	lda player_1_buzzed_in
	cmp #BUTTON_GREEN
	bne !pb1+
	Print(button_green_msg)
!pb1:
	cmp #BUTTON_RED
	bne !pb1+
	Print(button_red_msg)
!pb1:
	cmp #BUTTON_BLUE
	bne !pb1+
	Print(button_blue_msg)
!pb1:
	cmp #BUTTON_YELLOW
	bne !pb1+
	Print(button_yellow_msg)
!pb1:
!:
	//////////////////////////////
	// Check player 2 buzz in
	lda player_2_buzzed_in
	beq !+
	PrintPlot(21,23)
	Print(player_msg)
	PrintChr('2')
	PrintChr(' ')

	lda player_2_buzzed_in
	cmp #BUTTON_GREEN
	bne !pb2+
	Print(button_green_msg)
!pb2:
	cmp #BUTTON_RED
	bne !pb2+
	Print(button_red_msg)
!pb2:
	cmp #BUTTON_BLUE
	bne !pb2+
	Print(button_blue_msg)
!pb2:
	cmp #BUTTON_YELLOW
	bne !pb2+
	Print(button_yellow_msg)
!pb2:
!:
	//////////////////////////////
	// Print first buzz in status
	PrintPlot(19,23)
	PrintChr(KEY_WHITE)
	lda game_round_first_buzzer
	beq !++
	cmp #BUZZER_PLAYER_1
	bne !+
	PrintChr('<')
	jmp !++
!:
	PrintChr('>')	
!:

	//////////////////////////////
	// Get Joystick Input
	jsr il_get_j1_m2
	jsr il_get_j2_m2
	//////////////////////////////
	// Check player 1 Joystick buzz in
	lda player_1_buzzed_in
	bne p2buzz
	lda J1_B_GREEN
	bne !+
		lda #BUTTON_GREEN
		sta player_1_buzzed_in
		lda #BUZZER_PLAYER_1
		jsr who_buzzed_in_first
		sfx_v1_play(SFX_DING)
		jmp p2buzz
!:
	lda J1_B_YELLOW
	bne !+
		lda #BUTTON_YELLOW
		sta player_1_buzzed_in
		lda #BUZZER_PLAYER_1
		jsr who_buzzed_in_first
		sfx_v1_play(SFX_DING)
		jmp p2buzz
!:
	lda J1_B_RED
	bne !+
		lda #BUTTON_RED
		sta player_1_buzzed_in
		lda #BUZZER_PLAYER_1
		jsr who_buzzed_in_first
		sfx_v1_play(SFX_DING)
		jmp p2buzz
!:
	lda J1_B_BLUE
	bne !+
		lda #BUTTON_BLUE
		sta player_1_buzzed_in
		lda #BUZZER_PLAYER_1
		jsr who_buzzed_in_first
		sfx_v1_play(SFX_DING)
!:
p2buzz:
	//////////////////////////////
	// Check player 2 Joystick buzz in
	lda player_2_buzzed_in
	bne buzz_check_done
	// 1-Player mode: the CPU buzzes in for P2 (random delay, 50% correct)
	lda number_of_players
	bne !twop_p2+
	jsr cpu_p2_round_tick
	jmp buzz_check_done
!twop_p2:
	lda J2_B_GREEN
	bne !+
		lda #BUTTON_GREEN
		sta player_2_buzzed_in
		lda #BUZZER_PLAYER_2
		jsr who_buzzed_in_first
		sfx_v2_play(SFX_DING)
		jmp buzz_check_done
!:
	lda J2_B_YELLOW
	bne !+
		lda #BUTTON_YELLOW
		sta player_2_buzzed_in
		lda #BUZZER_PLAYER_2
		jsr who_buzzed_in_first
		sfx_v2_play(SFX_DING)
		jmp buzz_check_done
!:
	lda J2_B_RED
	bne !+
		lda #BUTTON_RED
		sta player_2_buzzed_in
		lda #BUZZER_PLAYER_2
		jsr who_buzzed_in_first
		sfx_v2_play(SFX_DING)
		jmp buzz_check_done
!:
	lda J2_B_BLUE
	bne !+
		lda #BUTTON_BLUE
		sta player_2_buzzed_in
		lda #BUZZER_PLAYER_2
		jsr who_buzzed_in_first
		sfx_v2_play(SFX_DING)
		jmp buzz_check_done
!:
buzz_check_done:
	//////////////////////////////
	// Destroy timer bar at top
	GetTimerTr(TIMER_1)
	sta tmp_1
	sec
	lda #$20
	sbc tmp_1
	tax
	lda #$20
	sta 1027,x

	GetTimerTr(TIMER_1)
	cmp #32
	beq !+
	jmp gsr_out
!:
	ClearScreen(BLACK)
	FullReset(TIMER_1)

gsr_in: // determine winner of round here
	
	lda #$10
	sta player_1_round_counter
	sta player_2_round_counter

	PrintHome()
	//GetTimerTr(TIMER_1)	PrintHex()
	PrintLF()
	
	lda #$00
	sta SPRITE_ENABLE	  // disable sprites
	
	
!:	

	// TODO: Print Question, then correct answer
	jsr print_question
	PrintLF()
	PrintLF()
	PrintRight(12)

	lda MLHL_DATA_CORRECT
	sec
	sbc #$30
	cmp #$01
	bne !+
	Print(MLHL_DATA_ANS1)
	jmp pca_o
!:
	cmp #$02
	bne !+
	Print(MLHL_DATA_ANS2)
	jmp pca_o
!:
	cmp #$03
	bne !+
	Print(MLHL_DATA_ANS3)
	jmp pca_o
!:
	cmp #$04
	bne !+
	Print(MLHL_DATA_ANS4)
	jmp pca_o
!:
pca_o:
	
	PrintLF()
	PrintLF()
	PrintRight(6)
	Print(player_msg)
	PrintChr('1')
	PrintChr(' ')
	lda MLHL_DATA_CORRECT // = the correct answer
	sec
	sbc #$30
	tax
	lda button_answer_translator,x
	sta a_reg
	cmp player_1_buzzed_in
	bne !+
	Print(p_right_msg) 	// Player 1 Got it right
	inc player_1_round_counter
	jmp !++
!:
	Print(p_wrong_msg) // Player 1 Got it wrong
	dec player_1_round_counter
!:
	PrintLF()
	PrintLF()
	PrintRight(6)
	Print(player_msg)
	PrintChr('2')
	PrintChr(' ')
	lda MLHL_DATA_CORRECT // = the correct answer
	sec
	sbc #$30
	tax
	lda button_answer_translator,x
	sta a_reg

	cmp player_2_buzzed_in
	bne !+
	Print(p_right_msg) // Player 2 Got it right
	inc player_2_round_counter
	jmp !++
!:
	Print(p_wrong_msg) // Player 2 Got it wrong
	dec player_2_round_counter
!:

	lda game_round_first_buzzer // check who buzzed in first
	cmp #BUZZER_PLAYER_1
	bne !+
	// Player 1 Buzzed In First
	inc player_1_round_counter
	jmp !++
!:
	// Player 2 Buzzed In First
	inc player_2_round_counter
!:

	lda game_round_winner
	bne p_win_done
	lda player_1_round_counter
	cmp player_2_round_counter
	bcs p1_wins             // C=1 means player_1 >= player_2 // fall through: player_2 wins
p2_wins:
	lda #02
	dec player_1_healthbar
	jmp p_win_out
p1_wins:
	lda #01
	dec player_2_healthbar
p_win_out:
	sta game_round_winner
p_win_done:

	PrintLF()
	PrintLF()
	PrintRight(6)
	Print(p_winner_msg)
	lda game_round_winner
	PrintHex()

	GetTimerTr(TIMER_1)
	cmp #TIMER_SHOW_ANSWER
	beq !+
	jmp gsr_in
!:
	inc game_step
	//////////////////////////////
	// Exit Game Step Round
gsr_out:
	jmp game_loop
// END GAME ROUND
////////////////////////////////////////////////////////////



print_question:
	//////////////////////////////
	// Print stuff
	PrintHome()
	PrintLF()
	PrintLF()
	PrintLF()
	PrintLF()
	PrintRight(6)
	PrintChr(5)
    lda #< MLHL_DATA_QUESTION
    sta zp_tmp_lo
    lda #> MLHL_DATA_QUESTION
    sta zp_tmp_hi
	// Add linefeed if line gets too long on screen
	ldy #$00
	sty tmp_1
!:
	lda (zp_tmp),y
	beq gst_lf_out
    jsr KERNAL_CHROUT
	lda (zp_tmp),y
	iny
	inc tmp_1
	cmp #' '
	bne !-
	clc
	lda tmp_1
	cmp #25
	bcc !-
	lda #$00
	sta tmp_1
	PrintLF()
	PrintRight(6)
	jmp !-
gst_lf_out:
	PrintChr('?')
	rts