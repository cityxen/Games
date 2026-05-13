//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

//////////////////////////////////////////////////////////////
// Main loop

main_loop_start:
restart:
	lda #01
	sta sound_playing
	jsr sfx_clear
	lda dev_mode
	beq !+
	lda #$01
	sta debug_mode
	lda #$00
	jmp !++
!:
	lda #$00
!:
	sta play_music
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

	ResetTimer(2)
	ResetTimer(1)

	lda #$00
	sta screen_draw
	PrintChr($93)
	jsr ml_screens

main_loop:

	jsr debug_stuff
	GetTimerTr(TIMER_2)
	cmp #$02
	bne !ml+
	lda #$00
	SetTimerTr(TIMER_2)
	ResetTimer(TIMER_2)
	jsr randomly_flash_buttons
!ml:	
	GetTimerTr(TIMER_SCREEN_CHANGE)
	cmp #$01
	bne ml_keys
	lda #$00
	SetTimerTr(TIMER_SCREEN_CHANGE)
	ResetTimer(TIMER_SCREEN_CHANGE)
	inc screen_draw // toggle screen to draw
	lda screen_draw
	cmp #$02
	bne !ml+
	lda #$00
	sta screen_draw
!ml:
	jsr ml_screens

ml_keys:
	jsr input_get_key

	cmp #KEY_M
	bne !ml+

	
	inc play_music
	lda play_music
	and #%00000001
	sta play_music
	lda screen_draw
	bne!ml+
	PrintHome()
	PrintDown(15)
	PrintRight(27)
	PrintChr(5)
	lda play_music
	jsr print_yesno

!ml:
	cmp #KEY_T
	bne !ml+
	lda #$00
	sta play_music
	lda #$30
	SetTimerTo(0)
	jmp load_trivia_stress_test
!ml:
	jsr input_get_button

	cmp #BUTTON_RED
	bne !ml+
	// set 1 Player Mode
	lda #$00
	sta number_of_players
	jmp ml_game_start
!ml:
	cmp #BUTTON_WHITE
	bne !ml+
	// set 2 Player Mode
	lda #$01
	sta number_of_players
	jmp ml_game_start
!ml:
	jmp main_loop

ml_game_start:
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA	
	jmp game_start

ml_screens:

	lda screen_draw
	cmp #$00 
	beq !+
	jmp next_scr
!:
	jsr draw_main_screen
 	jsr draw_title
	PrintDown(14)
	PrintRight(27)
	lda play_music
	jsr print_yesno
	PrintLF()

	PrintRight(9)
	Print(ml_detected_text)
    lda ml_detected
	jsr print_yesno
	PrintLF()
	PrintRight(9)
	Print(ml_enabled_text)
    lda ml_enabled
	jsr print_yesno
	PrintLF()
	PrintRight(15)
	Print(ml_total_trivia_text)
	lda ml_total_trivia
	sta numLo
	lda ml_total_trivia+1
	sta numHi
	jsr print_decimal
	PrintHome()


	PrintLF()
	Print(MLHL_HOTLOAD_MSG)

	rts
next_scr:
!ml:
	cmp #$01
	bne !ml+
	jsr draw_instruct
	rts
	
!ml:
	cmp #$02
	bne !ml+
	jsr draw_select_char
!ml:
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
	sty gsr_lf_check
!:
	lda (zp_tmp),y
	beq st_lf_out
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
	lda #$00
	SetTimerTr(TIMER_1)
	ResetTimer(TIMER_1)

!:
	PrintPlot(16,24)
	PrintLowerCase()
	PrintChr(KEY_WHITE)
	Print(trivia_round_text)
	//lda #$ff
	//PrintHex()
	PrintChr(KEY_S+32)
	PrintChr(KEY_T+32)

	jsr input_get_key
	cmp #KEY_Q
	bne !+
	lda #$00
	sta screen_draw
	SetTimerTr(TIMER_1)
	ResetTimer(TIMER_1)
	
	jsr ml_screens
	jmp main_loop
!:
	//GetTimer(TIMER_1)	PrintHexXY(18,2)
	//GetTimerTr(TIMER_1) PrintHexXY(21,2)

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
	bne !--

	jmp load_trivia_stress_test


	print_answer:

		rts

.macro CenterAns(ans) {
	StrLen(ans)
	stx x_reg   // Save X
	lda #16
	sec         // Set carry for subtraction
	sbc x_reg   // A = A - temp
	lsr

	clc
	cmp #18
	bcc!+
	lda #2
!:

	tax
!:
	stx x_reg
	PrintChr(' ')
	ldx x_reg
	dex
	bne !-
}
	