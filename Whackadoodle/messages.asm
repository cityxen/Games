
set_message:
	sta message
	lda #$00
	sta irq_timer4_tr
	sta irq_timer4
	rts

show_message:

	jsr init_sprites_msg

	PrintString(msg_init)
	lda message
	cmp #$01
	bne !sm+
	PrintString(msg_getready)
	jmp smo
!sm:
	cmp #$02
	bne !sm+
	PrintString(msg_miss)
	lda #BUTTON_ACTION_MISS
	sta USER_PORT_DATA
	jmp smo
!sm:
	cmp #$03
	bne !sm+
	PrintString(msg_pow)
	lda #BUTTON_ACTION_POW
	sta USER_PORT_DATA
	jmp smo
!sm:
	cmp #$04
	bne smo
	PrintString(msg_wrong)
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