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
	GetTimerTr(1)
	cmp #$02
	bne !ml+
	lda #$00
	SetTimerTr(1)
	ResetTimer(1)
	jsr randomly_flash_buttons
!ml:	
	GetTimerTr(2)
	cmp #$01
	bne ml_keys
	lda #$00
	SetTimerTr(2)
	ResetTimer(2)
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
	jsr MLHL_LOAD // load random trivia question
	PrintClear()
	Print(MLHL_HOTLOAD_MSG)
	PrintHome()
	PrintLowerCase()
	Print(MLHL_DATA_QUESTION)
	PrintLF()
	lda MLHL_DATA_CORRECT
	sbc #47
	PrintHex() 
	PrintLF()
	Print(MLHL_DATA_ANS1)
	PrintLF()
	Print(MLHL_DATA_ANS2)
	PrintLF()
	Print(MLHL_DATA_ANS3)
	PrintLF()
	Print(MLHL_DATA_ANS4)
	PrintLF()

	ResetTimer(3)
	lda #$00
	SetTimerTr(3)
!:
	GetTimer(3)
	PrintHexXY(0,15)
	GetTimerTr(3)
	PrintHexXY(0,16)
	GetTimerTr(3) // input timers
	cmp #$03
	bne !-
	ResetTimer(3)
	lda #$00
	SetTimerTr(3)
	jmp load_trivia_stress_test