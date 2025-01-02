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
// Make buttons blink randomly

randomly_flash_buttons:
	jsr lda_random_kern
	ora #BUTTON_ACTIONS
	sta random_num
	sta USER_PORT_DATA
	rts

/////////////////////////////////////////////////////
// Get Button Press

wad_get_button:
	lda irq_timer_joystick_tr
	beq !gb+
	lda JOYSTICK_PORT_1
	rts
!gb:
	lda #$ff
	rts

/////////////////////////////////////////////////////
// Get Key Press

wad_get_key:
	// lda irq_timer_input_tr
	// beq !gb+
	jsr KERNAL_GETIN
	sta whack_key
	// jsr reset_input_timer
	// lda whack_key
	rts
!gb:
	lda #$00
	rts


