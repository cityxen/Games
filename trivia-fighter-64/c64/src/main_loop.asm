//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

//////////////////////////////////////////////////////////////
// Main loop initialize
main_loop_start:
restart:
	lda #01
	sta play_sound
	jsr sfx_clear
	ldx #0
	ldy #0
	lda #music.startSong-1 // <- Here we get the startsong and init address from the sid file
	jsr music.init
	lda #$01
	sta play_music
	lda #$ff // reset user port values to output and zero
	sta USER_PORT_DATA_DIR
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
	jsr randomize_avatars
	FullReset(TIMER_SCREEN_CHANGE)
	FullReset(TIMER_1)
	FullReset(TIMER_2)
	FullReset(TIMER_3)
	lda #$00
	sta screen_draw
	PrintChr($93)
	jsr ml_screens
	// fall through to main_loop
//////////////////////////////////////////////////////////////
// Main loop
main_loop:
	jsr debug_stuff
	GetTimerTr(TIMER_2)
	cmp #$04
	bne !+
	FullReset(TIMER_2)
	jsr randomize_avatars
	jsr init_sprites_ms
	jsr randomly_flash_buttons
!:	
	GetTimerTr(TIMER_SCREEN_CHANGE)
	cmp #$02
	bne !+
	FullReset(TIMER_SCREEN_CHANGE)
	inc screen_draw // toggle screen to draw
	jsr ml_screens
!:
	jsr input_get_key
	cmp #KEY_M
	bne !+
	inc play_music
	lda play_music
	and #%00000001
	sta play_music
	lda screen_draw
	bne!+
	PrintHome()
	PrintDown(15)
	PrintRight(24)
	PrintChr(5)
	lda play_music
	jsr print_yesno
!:
	cmp #KEY_T
	bne !+
	lda #$00
	sta play_music
	lda #$30
	SetTimerTo(0)
	jmp load_trivia_stress_test
!:
	jsr input_get_button
	cmp #BUTTON_RED
	bne !+
	lda #$00 // set 1 Player Mode
	sta number_of_players
	jmp ml_game_start
!:
	cmp #BUTTON_WHITE
	bne !+
	lda #$01 // set 2 Player Mode
	sta number_of_players
	jmp ml_game_start
!:
	jmp main_loop
// END MAIN LOOP
//////////////////////////////////////////////////

ml_game_start:
	lda #BUTTON_LIGHT_NONE // Turn off button lights
	sta USER_PORT_DATA	
	jmp game_start

ml_screens:
	lda screen_draw
	cmp #$02
	bne !+
	lda #$00
	sta screen_draw
!:
	cmp #$00 
	beq !+
	jmp !++
!:
	jsr draw_main_screen
	rts
!:
	jsr draw_instruct
	rts

load_trivia_stress_test:
	jsr draw_loading_screen
	jsr MLHL_LOAD // load random trivia question
	jsr draw_play_screen
	sfx_v2_play(SFX_POW)
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
	sty tmp_1
!:
	lda (zp_tmp),y
	beq st_lf_out
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
st_lf_out:
	PrintChr('?')
	PrintLF()
	PrintChr(KEY_YELLOW)
	lda MLHL_DATA_CORRECT
	sbc #47
	PrintHexXY(2,2)
	PrintHome()
	PrintChr(KEY_WHITE)
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
	PrintLF()
	lda #TIMER_ROUND
	SetTimerTo(TIMER_1)
	FullReset(TIMER_1)
!:
	PrintPlot(16,24)
	PrintLowerCase()
	PrintChr(KEY_WHITE)
	Print(trivia_round_text)
	PrintChr(KEY_S+32)
	PrintChr(KEY_T+32)
	jsr input_get_key
	cmp #KEY_Q
	bne !+
	lda #$00
	sta screen_draw
	FullReset(TIMER_1)
	jmp restart
!:
	GetTimerTr(TIMER_1)
	sta tmp_1
	sec
	lda #$20
	sbc tmp_1
	tax
	lda #$20   // remove timer bar as it counts down
	sta 1027,x // just write ' ' over it
	GetTimerTr(TIMER_1)
	cmp #32
	bne !--
	jmp load_trivia_stress_test
// END STRESS TEST

	