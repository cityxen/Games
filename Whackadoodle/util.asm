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
	ora #BUTTON_ACTIONS
	sta random_num
	sta USER_PORT_DATA
	rts

/////////////////////////////////////////////////////
// Draw mode

draw_mode:
	zp_str(msg_mode_mode)
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

	lda whack_mode
	cmp #MODE_EASY
	bne !+
	zp_str(msg_mode_easy)
	jmp draw_mode_2
!:
	cmp #MODE_NORMAL
	bne !+
	zp_str(msg_mode_normal)
	jmp draw_mode_2
!:
	cmp #MODE_HARD
	bne !+
	zp_str(msg_mode_hard)
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
	lda irq_timer_input_tr
	beq !gb+
	jsr KERNAL_GETIN
	sta whack_key
	jsr reset_input_timer
	lda whack_key
	rts
!gb:
	lda #$00
	rts

////////////////////////////////////////////////////
// Increment Score

increment_score:
	inc whack_score_lo
	bne !is+
	inc whack_score_hi
!is:
	rts

////////////////////////////////////////////////////
// Decrement Score

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
	clc					// Set cursor position
	ldy #$20         	// X coordinate (column)
	ldx #$02        	// Y coordinate (line)
draw_score_func_b:
	jsr $fff0		    // Kernal Plot
	lda whack_score_hi // Score High byte
	ldx whack_score_lo // Score Low byte
	jsr $bdcd
	rts
draw_score_game_on:
	DrawScore(GAME_ON_SCORE_LOC_X,GAME_ON_SCORE_LOC_Y)
	rts
draw_score_game_over:
	DrawScore(GAME_OVER_SCORE_LOC_X,GAME_OVER_SCORE_LOC_Y)
	rts

////////////////////////////////////////////////////
// Reset Score

reset_score:
	lda #$00
	sta whack_score_lo
	sta whack_score_hi
	rts