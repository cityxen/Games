//////////////////////////////////////////////////////////////////////////////////////
//
// TRIVIA FIGHTERS 64 for C64
//
//                            by Deadline / CityXen 2026
// 
// Dependencies:
// The include folder from: https://github.com/cityxen/retro-dev-tools/include/commodore64
// must be in kickassembler path in the KickAss.cfg file:
//   -libdir "PATHTO:\dev\cityxen\retro-dev-tools\include\commodore64"
//
// CityXen Videos: https://youtube.com/@cityxen
// CityXen Games: https://cityxen.itch.io
//
//////////////////////////////////////////////////////////////////////////////////////

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
	