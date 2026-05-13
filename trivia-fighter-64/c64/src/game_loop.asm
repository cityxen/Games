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
	lda #GAME_STEP_ANIM_INTRO_
	sta game_step
	jmp !++
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
	PrintClear()
	lda #$00
	SetTimerTr(2)
	ResetTimer(2)
	inc game_step

game_step_anim: // all anims for now
	lda #$00
	sta SPRITE_ENABLE
	inc game_step
	jmp game_loop

	PrintHome()
	PrintLowerCase()
	
	Print(anim_text)
	PrintLF()
	PrintDown(5)
	GetTimer(2)
	PrintHex()
	PrintLF()
	GetTimerTr(2)
	PrintHex()
	PrintLF()

	GetTimerTr(2)
	cmp #$01
	bne !+
	inc game_step
!:
	jmp game_loop


game_step_round_init:
	
	jsr draw_loading_screen
	jsr MLHL_LOAD // load random trivia question
	jsr draw_play_screen
	lda #$00
	SetTimerTr(1)
	ResetTimer(1)

	// reset buzzed in state
	sta player_1_buzzed_in
	sta player_2_buzzed_in
	sta game_round_first_buzzer

	inc game_step
	sfx_v2_play(SFX_GET_READY)
	jmp game_loop

gsr_lf_check: .byte 0
game_step_round:

	PrintHome()
	PrintLowerCase()
	PrintRight(16)
	Print(trivia_round_text)
	lda game_round_current
	PrintHex()
	PrintLF()
	PrintLF()
	PrintLF()
	PrintRight(4)
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
	PrintRight(4)
	jmp !-

gst_lf_out:

	PrintChr('?')

	//PrintLF()
	//PrintUp(1)
	//lda MLHL_DATA_CORRECT
	//sbc #47
	//PrintHexXY(2,1)

	PrintHome()
	PrintDown(13)
	PrintRight(3)

	Print(MLHL_DATA_ANS1)

	PrintLF()
	PrintUp(1)
	PrintRight(21)

	Print(MLHL_DATA_ANS2)

	PrintLF()
	PrintDown(7)
	PrintRight(3)

	Print(MLHL_DATA_ANS3)

	PrintLF()
	PrintUp(1)
	PrintRight(21)

	Print(MLHL_DATA_ANS4)
	
	PrintLF()
	//Print(MLHL_DATA_QUESTION)


	PrintLF()
	//lda MLHL_DATA_CORRECT
	//sbc #47
	//PrintHex()
	PrintHome()
	PrintDown(13)
	PrintRight(3)
	Print(MLHL_DATA_ANS1)
	PrintLF()
	PrintUp(1)
	PrintRight(21)
	Print(MLHL_DATA_ANS2)
	PrintLF()
	PrintDown(7)
	PrintRight(3)
	Print(MLHL_DATA_ANS3)
	PrintLF()
	PrintUp(1)
	PrintRight(21)
	Print(MLHL_DATA_ANS4)

	// begin input checks here

	PrintLF()
	PrintLF()
	PrintLF()
	PrintRight(5 )

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
	bne p2buzz

	lda J1_B_GREEN // green // PrintHex()	PrintChr($20)
	bne !+
		lda #BUTTON_GREEN
		sta player_1_buzzed_in
		lda #BUZZER_PLAYER_1
		jsr who_buzzed_in_first
		sfx_v1_play(SFX_POW)
		jmp p2buzz
!:
	lda J1_B_YELLOW // yellow // PrintHex() 	PrintChr($20)
	bne !+
		lda #BUTTON_YELLOW
		sta player_1_buzzed_in
		lda #BUZZER_PLAYER_1
		jsr who_buzzed_in_first
		sfx_v1_play(SFX_POW)
		jmp p2buzz
!:
	lda J1_B_RED // red // PrintHex()	PrintChr($20)
	bne !+
		lda #BUTTON_RED
		sta player_1_buzzed_in
		lda #BUZZER_PLAYER_1
		jsr who_buzzed_in_first
		sfx_v1_play(SFX_POW)
		jmp p2buzz
!:
	lda J1_B_BLUE // blue // PrintHex()	PrintChr($20)
	bne !+
		lda #BUTTON_BLUE
		sta player_1_buzzed_in
		lda #BUZZER_PLAYER_1
		jsr who_buzzed_in_first
		sfx_v1_play(SFX_POW)
!:

p2buzz:

	lda player_2_buzzed_in
	bne buzz_check_done

	lda J2_B_GREEN	// green PrintHex()	PrintChr($20)
	bne !+
		lda #BUTTON_GREEN
		sta player_2_buzzed_in
		lda #BUZZER_PLAYER_2
		jsr who_buzzed_in_first
		sfx_v2_play(SFX_POW)
		jmp buzz_check_done
!:
	lda J2_B_YELLOW // yellow	PrintHex()	PrintChr($20)
	bne !+
		lda #BUTTON_YELLOW
		sta player_2_buzzed_in
		lda #BUZZER_PLAYER_2
		jsr who_buzzed_in_first
		sfx_v2_play(SFX_POW)
		jmp buzz_check_done
!:
	lda J2_B_RED // red	PrintHex()	PrintChr($20)
	bne !+
		lda #BUTTON_RED
		sta player_2_buzzed_in
		lda #BUZZER_PLAYER_2
		jsr who_buzzed_in_first
		sfx_v2_play(SFX_POW)
		jmp buzz_check_done
!:
	lda J2_B_BLUE // blue	PrintHex()	PrintChr($20)
	bne !+
		lda #BUTTON_BLUE
		sta player_2_buzzed_in
		lda #BUZZER_PLAYER_2
		jsr who_buzzed_in_first
		sfx_v2_play(SFX_POW)
		jmp buzz_check_done
!:

buzz_check_done:

	GetTimerTr(1)
	sta tmp_1
	sec
	lda #$20
	sbc tmp_1
	tax
	lda #$20
	sta 1068,x

	GetTimerTr(1)
	cmp #32
	bne !+
	inc game_step
!:

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

