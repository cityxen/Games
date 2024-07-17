
set_message:
	sta message
	lda #$00
	sta trig_4
	sta irq_timer4
	rts

show_message:

	jsr init_sprites_msg

	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA

	PrintString(msg_init)
	lda message
	cmp #$01
	bne !sm+
	PrintString(msg1)
	jmp smo
!sm:
	cmp #$02
	bne !sm+
	PrintString(msg2)
	jmp smo
!sm:
	cmp #$03
	bne !sm+
	// pow sprites here
	PrintString(msg3)
	jmp smo
!sm:
	cmp #$04
	bne smo
	// wrong
	PrintString(msg4)
smo:
	lda trig_4
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