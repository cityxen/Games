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

set_message:
	sta message
	lda #$00
	sta irq_timer4_tr
	sta irq_timer4
	rts

show_message:

	jsr init_sprites_msg

	Print(msg_init)
	lda message
	cmp #$01
	bne !sm+
	Print(msg_getready)
	jmp smo
!sm:
	cmp #$02
	bne !sm+
	Print(msg_miss)
	lda #BUTTON_ACTION_MISS
	sta USER_PORT_DATA
	jmp smo
!sm:
	cmp #$03
	bne !sm+
	Print(msg_pow)
	lda #BUTTON_ACTION_POW
	sta USER_PORT_DATA
	jmp smo
!sm:
	cmp #$04
	bne smo
	Print(msg_wrong)
	lda #BUTTON_ACTION_MISS
	sta USER_PORT_DATA
smo:
	lda irq_timer4_tr
	beq !smo+
	jsr init_sprites_play
	lda #$00
	sta message
	jsr draw_play_screen
	jsr draw_score_game_on

!smo:
	rts

draw_countdown:
	ldx #$00
!dc:
	lda countdown_text,x
	beq !dc+
	jsr KERNAL_CHROUT
	inx
	jmp !dc-
!dc:
	ldx whack_life
!dc:
	lda #$d1
	jsr KERNAL_CHROUT
	dex
	cpx #$00
	bne !dc-

	lda #$20
	jsr KERNAL_CHROUT
	
	rts