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
	///// temporary jump over selection (remove after testing)
	//lda #GAME_STEP_ANIM_INTRO_
	//sta game_step
	//jmp !++
	/////
	jmp game_step_select_init
!:
	cmp #GAME_STEP_SELECT
	bne !+
	jmp game_step_select
!:
	cmp #GAME_STEP_ANIM_INTRO_
	bne !+
	lda #0
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
	lda #0
	sta game_anim
	jmp game_step_anim_init
!:
	cmp #GAME_STEP_ANIM_1
	bne !+
	jmp game_step_anim
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
	lda #0
	sta game_anim
	jmp game_step_anim_init
!:
	cmp #GAME_STEP_ANIM_2
	bne !+
	jmp game_step_anim
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
	lda #0
	sta game_anim
	jmp game_step_anim_init
!:
	cmp #GAME_STEP_ANIM_3
	bne !+
	jmp game_step_anim
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
	lda #0
	sta game_anim
	jmp game_step_anim_init
!:
	cmp #GAME_STEP_ANIM_4
	bne !+
	jmp game_step_anim
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
	lda #0
	sta game_anim
	jmp game_step_anim_init
!:
	cmp #GAME_STEP_ANIM_FINISH
	bne !+
	jmp game_step_anim
!:

	// determine game over condition here
	jmp game_over

game_step_select_init:
	jsr init_sprites_game_init
	lda #$00
	sta cxn_avatar_selected

	jsr print_player_1_name
	jsr update_player_1_select_sprites
	jsr print_player_2_name
	jsr update_player_2_select_sprites
	inc game_step

game_step_select:

	lda cxn_avatar_selected
	cmp #cxn_avatar_selected_both
	bne !+
	inc game_step
	jmp game_loop
!:

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
	jsr update_player_1_select_sprites
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
	jsr update_player_2_select_sprites
!:
pselectout:
	jmp game_loop

game_step_anim_init:
	PrintClear()
	lda #anim_bg_color
	sta BORDER_COLOR
	sta BACKGROUND_COLOR

	lda #$00
	SetTimerTr(TIMER_1)
	ResetTimer(TIMER_1)

	inc game_step

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

		PrintRight(14)
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


game_step_round_init:
	
	jsr draw_loading_screen
	jsr MLHL_LOAD // load random trivia question
	jsr draw_play_screen
	lda #$00	
	SetTimerTr(TIMER_1)
	ResetTimer(TIMER_1)
	lda #TIMER_ROUND
	SetTimerTo(TIMER_1)

	// reset buzzed in state
	lda #$00
	sta player_1_buzzed_in
	sta player_2_buzzed_in
	sta game_round_first_buzzer

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

	ldy #$00
	sty gsr_lf_check
!:
	lda (zp_tmp),y
	beq gst_lf_out
    jsr KERNAL_CHROUT
	lda (zp_tmp),y

	iny
	inc gsr_lf_check
	cmp #' '
	bne !-
	
	clc
	lda gsr_lf_check
	cmp #25
	bcc !-
	lda #$00
	sta gsr_lf_check
	PrintLF()
	PrintRight(6)
	jmp !-

gst_lf_out:

	PrintChr('?')
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

gsr_lf_check: .byte 0
game_step_round:

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
	lda player_2_buzzed_in
	beq !+
	PrintPlot(21,23)
	Print(player_msg)
	PrintChr('2')
	PrintChr(' ')
	lda player_2_buzzed_in
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

	jsr il_get_j1_m2
	jsr il_get_j2_m2

	lda player_1_buzzed_in
	cmp #$00
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

	lda player_2_buzzed_in
	cmp #$00
	bne buzz_check_done

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
gsr_in:
	// determine winner of round here
	PrintHome()
	GetTimerTr(TIMER_1)
	PrintHex()
	PrintLF()
	
	lda #$00
	sta game_round_winner
	sta SPRITE_ENABLE
	
!:
	

	lda MLHL_DATA_CORRECT
	sec
	sbc #$30
	PrintHex()
	PrintLF()
	PrintLF()
	
	Print(player_msg)
	PrintChr('1')
	PrintChr(' ')

	lda MLHL_DATA_CORRECT // = the correct answer
	sec
	sbc #$30
	tax
	lda button_answer_translator,x
	sta a_reg
	PrintLF()
	lda a_reg
	PrintHex()
	PrintLF()
	lda a_reg
	cmp player_1_buzzed_in
	bne !+
	Print(p_right_msg) 	// Player 1 Got it right
	jmp !++
!:
	Print(p_wrong_msg) // Player 1 Got it wrong
!:
	PrintLF()
	PrintLF()
	Print(player_msg)
	PrintChr('2')
	PrintChr(' ')
	lda MLHL_DATA_CORRECT // = the correct answer
	sec
	sbc #$30
	tax
	lda button_answer_translator,x
	sta a_reg
	PrintLF()
	lda a_reg
	PrintHex()
	PrintLF()
	lda a_reg
	cmp player_2_buzzed_in
	bne !+
	Print(p_right_msg) // Player 2 Got it right
	jmp !++
!:
	Print(p_wrong_msg) // Player 2 Got it wrong
!:

	lda game_round_first_buzzer // check who buzzed in first
	cmp #BUZZER_PLAYER_1
	bne !+
	// Player 1 Buzzed In First
	jmp !++
!:
	// Player 2 Buzzed In First
!:

	GetTimerTr(TIMER_1)
	cmp #32
	beq !+
	jmp gsr_in
!:
	inc game_step
gsr_out:
	jmp game_loop

who_buzzed_in_first:
	pha
	lda game_round_first_buzzer
	bne !+
	pla
	sta game_round_first_buzzer
	rts
!:
	pla
	rts

