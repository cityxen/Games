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

/////////////////////////////////////////////////////
// Draw mode

draw_mode:
	// zp_str(msg_mode_mode)
	ldy #$00
!:
	lda (zp_tmp),y
	beq !+
	sta SCREEN_RAM+1000-40-20,y
	lda #$01
	sta COLOR_RAM+1000-40-20,y
	iny
	jmp !-
!:

	lda GAME_MODE
	cmp #MODE_EASY
	bne !+
	// zp_str(msg_mode_easy)
	jmp draw_mode_2
!:
	cmp #MODE_NORMAL
	bne !+
	// zp_str(msg_mode_normal)
	jmp draw_mode_2
!:
	cmp #MODE_HARD
	bne !+
	// zp_str(msg_mode_hard)
	jmp draw_mode_2
!:

draw_mode_2:

	ldy #$00
!:
	lda (zp_tmp),y
	beq !+
	sta SCREEN_RAM+1000-40-20+5,y
	lda #YELLOW
	sta COLOR_RAM+1000-40-20+5,y
	iny
	jmp !-
!:
	rts


/////////////////////////////////////////////////////
// Get Button Press

get_button:
	lda TRIG_JOYSTICK
	beq !gb+
	lda JOYSTICK_PORT_1
	rts
!gb:
	lda #$ff
	rts

/////////////////////////////////////////////////////
// Get Key Press

get_key:
	lda TRIG_INPUT
	beq !gb+
	jsr KERNAL_GETIN


	jsr reset_input_timer


	rts
!gb:
	lda #$00
	rts

////////////////////////////////////////////////////
// Increment Score

increment_score:
	
	
	rts

////////////////////////////////////////////////////
// Decrement Score

decrement_score:
	

	rts

////////////////////////////////////////////////////
// Draw Score

.macro DrawScore(x,y) {
	clc    // Set cursor position
	ldy #x // X coordinate (column)
	ldx #y // Y coordinate (line)
	jsr draw_score_func_b
}
draw_score_func:

draw_score_func_b:

	rts

draw_score_game_on:

	rts

draw_score_game_over:

	rts

////////////////////////////////////////////////////
// Reset Score

reset_score:

	rts