//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

//////////////////////////////////////////////////////////////
// DEBUG STUFF

debug_stuff:
	lda debug_mode
	and #$01
	bne !+
	rts
!:
	lda #$00
	sta print_hex_inline_d
	PrintHome()
	PrintLF()
	PrintColor(RED)

	lda JOYSTICK_PORT_1
	PrintHex()
	PrintChr($20)

	GetTimer(TIMER_SCREEN_CHANGE)
	PrintHex()
	PrintChr($20)

	GetTimerTr(TIMER_SCREEN_CHANGE)
	PrintHex()
	PrintChr($20)

	lda random_num
	PrintHex()
	PrintChr($20)

	rts