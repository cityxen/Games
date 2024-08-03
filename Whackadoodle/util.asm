//////////////////////////////////////////////////////////////////
// Random number stuff

random_init_sid:
    // Set up sid to produce random values
    lda #$FF  // maximum frequency value
    sta $D40E // voice 3 frequency low byte
    sta $D40F // voice 3 frequency high byte
    lda #$80  // noise waveform, gate bit off
    sta $D412 // voice 3 control register
    rts

lda_random_sid:
    lda $d41b // lda with random number
    rts

lda_random_kern:
    jsr $E097
	lda $8f
    rts

//////////////////////////////////////////////////////////////////
// Make buttons blink randomly

randomly_flash_buttons:
	jsr lda_random_kern
	sta random_num
	sta USER_PORT_DATA
	rts

get_button:
	lda trig_joystick
	beq !gb+
	lda JOYSTICK_PORT_1
	rts
!gb:
	lda #$ff
	rts

get_key:
	lda trig_input
	beq !gb+
	jsr KERNAL_GETIN
	sta whack_key
	jsr reset_input_timer
	lda whack_key
	rts
!gb:
	lda #$00
	rts

increment_score:
	inc whack_score_lo
	bne !is+
	inc whack_score_hi
!is:
	jmp update_score

decrement_score:
	lda whack_score_lo
	cmp #$00
	beq !is+
	dec whack_score_lo
	jmp !is++
!is:
	lda whack_score_hi
	cmp #$00
	beq !is+
	dec whack_score_hi
	dec whack_score_lo
!is:

update_score:
	jsr reset_whacks
	ldy whack_score_hi
	ldx whack_score_lo

	cpx #$00
	bne !us++
!us:
	cpy #$00
	bne !us+
	jsr reset_whacks
	jmp !us++

!us:
	dex
	jsr update_score_to_dec
	cpx #$00
	bne !us-
	
	cpy #$00
	beq !us+
	dey
	jmp !us-
!us:
	rts

update_score_to_dec:
   
	inc whack_score_1
	lda whack_score_1
	cmp #$3a
	bne isout
	lda #$30
	sta whack_score_1

	inc whack_score_2
	lda whack_score_2
	cmp #$3a
	bne isout
	lda #$30
    sta whack_score_2

	inc whack_score_3
	lda whack_score_3
	cmp #$3a
	bne isout
	lda #$30
	sta whack_score_3

	inc whack_score_4
	lda whack_score_4
	cmp #$3a
	bne isout
	lda #$30
	sta whack_score_4

	inc whack_score_5
	lda whack_score_5
	cmp #$3a
	bne isout
	lda #$30
	sta whack_score_5

	inc whack_score_6
	lda whack_score_6
	cmp #$3a
	bne isout
	lda #$30
	sta whack_score_6

isout:
	rts



draw_score_game_on:
	lda whack_score_1
	sta GAME_ON_SCORE_LOC+5
	lda whack_score_2
	sta GAME_ON_SCORE_LOC+4
	lda whack_score_3
	sta GAME_ON_SCORE_LOC+3
	lda whack_score_4
	sta GAME_ON_SCORE_LOC+2
	lda whack_score_5
	sta GAME_ON_SCORE_LOC+1
	lda whack_score_6
	sta GAME_ON_SCORE_LOC
	rts

draw_score_game_over:
	lda whack_score_1
	sta GAME_OVER_SCORE_LOC+5
	lda whack_score_2
	sta GAME_OVER_SCORE_LOC+4
	lda whack_score_3
	sta GAME_OVER_SCORE_LOC+3
	lda whack_score_4
	sta GAME_OVER_SCORE_LOC+2
	lda whack_score_5
	sta GAME_OVER_SCORE_LOC+1
	lda whack_score_6
	sta GAME_OVER_SCORE_LOC
	rts	

reset_whacks:
	lda #$30
	sta whack_score_1
	sta whack_score_2
	sta whack_score_3
	sta whack_score_4
	sta whack_score_5
	sta whack_score_6
	rts

reset_score:
	lda #$00
	sta whack_score_lo
	sta whack_score_hi
	jsr reset_whacks
	rts