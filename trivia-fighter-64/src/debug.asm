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
	PrintColor(RED)

	lda JOYSTICK_PORT_1
	PrintHexXY(1,1)

	
	
	lda play_music
	PrintHexXY(16,1)


	lda message
	PrintHexXY(25,1)

	lda random_num
	PrintHexXY(28,1)


	rts