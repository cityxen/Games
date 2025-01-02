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
	PrintColor(RED)

	lda JOYSTICK_PORT_1
	PrintHexXY(1,1)

	lda button_to_hit
	PrintHexXY(4,1)

	lda doodle
	PrintHexXY(7,1)

	lda irq_timer_jitter_to
	PrintHexXY(10,1)

	lda irq_timer_jitter
	PrintHexXY(13,1)

	lda play_music
	PrintHexXY(16,1)

	lda irq_timer1
	PrintHexXY(19,1)

	lda irq_timer1_tr
	PrintHexXY(22,1)

	lda message
	PrintHexXY(25,1)

	lda random_num
	PrintHexXY(28,1)

	lda whack_mode
	PrintHexXY(31,1)

	rts