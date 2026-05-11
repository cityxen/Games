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
	PrintColor(WHITE)
	PrintReverseOn()

/*
	lda JOYSTICK_PORT_1
	PrintHexXY(1,1)

	lda button_to_hit
	PrintHexXY(4,1)

	lda doodle
	PrintHexXY(7,1)

	

	lda play_music
	PrintHexXY(16,1)
*/

	GetTimer(0)
	PrintHex()
	PrintChr(32)

	GetTimerTr(0)
	PrintHex()
	PrintChr(32)
		
	GetTimer(1)
	PrintHex()
	PrintChr(32)

	GetTimerTr(1)
	PrintHex()
	PrintChr(32)

	GetTimer(2)
	PrintHex()
	PrintChr(32)

	GetTimerTr(2)
	PrintHex()
	PrintChr(32)

	GetTimer(3)
	PrintHex()
	PrintChr(32)

	GetTimerTr(3)
	PrintHex()
	PrintChr(32)

	PrintLF()
	PrintReverseOn()

	GetTimer(4)
	PrintHex()
	PrintChr(32)

	GetTimerTr(4)
	PrintHex()
	PrintChr(32)

	

	GetTimer(5)
	PrintHex()
	PrintChr(32)

	GetTimerTr(5)
	PrintHex()
	PrintChr(32)

	GetTimer(6)
	PrintHex()
	PrintChr(32)
	GetTimerTr(6)
	PrintHex()
	PrintChr(32)

	


/*
	lda message
	PrintHexXY(25,1)

	lda random_num
	PrintHexXY(28,1)

	lda whack_mode
	PrintHexXY(31,1)
	*/

	PrintReverseOff()
	rts