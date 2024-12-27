
set_message:
	sta MESSAGE
	lda #$00
	sta TRIG_4
	sta IRQ_TIMER4
	rts

show_message:

	jsr init_sprites_msg

	lda MESSAGE
	cmp #$01
	bne !sm+
	// PrintString(msg_getready)
	jmp smo
!sm:
	cmp #$02
	bne !sm+
	// PrintString(msg_miss)

	jmp smo
!sm:
	cmp #$03
	bne !sm+
	// PrintString(msg_pow)

	jmp smo
!sm:
	cmp #$04
	bne smo
	// PrintString(msg_wrong)
	
smo:
	lda TRIG_4
	beq !smo+
	jsr init_sprites_play
	lda #$00
	sta MESSAGE
	jsr draw_play_screen
	jsr draw_score_game_on

!smo:
	rts

draw_countdown:


	rts