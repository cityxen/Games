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

//////////////////////////////////////////////////////////////////////////////////////
// Print Stuff

print_hex_inline:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// print_hex
//////////////////////////////////////////////////////////////////////////////////////
// Print 2 character HEX representation of a byte onto the screen at x,y location
//////////////////////////////////////////////////////////////////////////////////////
// usage:
// 
//      ldx #$05 
//      ldy #$06
//      lda #$15
//      jsr print_hex
//
//////////////////////////////////////////////////////////////////////////////////////
print_hex:
    sta zp_tmp
    jsr calculate_screen_pos
    lda zp_tmp
print_hex_no_calc:
    sta zp_tmp
    lsr
    lsr
    lsr
    lsr
    tax
    lda print_hex_screencode_conversion_table,x
    ldx #$00
    sta (zp_ptr_screen,x)
    lda #WHITE
    sta (zp_ptr_color,x)
    lda zp_tmp
    and #$0f
    tax
    lda print_hex_screencode_conversion_table,x
    inc zp_ptr_screen_lo
    ldx #$00
    sta (zp_ptr_screen,x)
    inc zp_ptr_color_lo
    lda #WHITE
    sta (zp_ptr_color,x)
    rts
print_hex_screencode_conversion_table:
.byte $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$01,$02,$03,$04,$05,$06

//////////////////////////////////////////////////////////////////////////////////////
// calculate_screen_pos
//////////////////////////////////////////////////////////////////////////////////////
// Calculate screen position based on x and y registers
//////////////////////////////////////////////////////////////////////////////////////
// Usage:
// 
//      ldx #$05
//      ldy #$10
//      jsr calculate_screen_pos
//
//////////////////////////////////////////////////////////////////////////////////////
// Result: Stores screen location in zp_ptr_screen
//////////////////////////////////////////////////////////////////////////////////////
calculate_screen_pos: // x = xpos y = ypos
    lda #<SCREEN_RAM    // enter screen pos into zp
    sta zp_ptr_screen_lo
    lda #>SCREEN_RAM
    sta zp_ptr_screen_hi
    lda #<COLOR_RAM
    sta zp_ptr_color_lo
    lda #>COLOR_RAM
    sta zp_ptr_color_hi

    cpx #$00 // add x pos to screen pos
!csp_lp:
    beq !csp_lp+
    inc zp_ptr_screen_lo
    inc zp_ptr_color_lo
    bne !csp_lp_i+
    inc zp_ptr_screen_hi
    inc zp_ptr_color_hi
!csp_lp_i:
    dex
    jmp !csp_lp-
!csp_lp:
    cpy #$00 // add y pos to screen pos
!csp_lp:
    beq !csp_lp+
    lda zp_ptr_color_lo
    clc
    adc #$28
    sta zp_ptr_color_lo    
    lda zp_ptr_screen_lo
    clc
    adc #$28
    sta zp_ptr_screen_lo
    bcc !csp_lp_i+
    inc zp_ptr_screen_hi
    inc zp_ptr_color_hi
!csp_lp_i:
    dey
    jmp !csp_lp-
!csp_lp:
    rts

increment_screen_pos:
    inc zp_ptr_screen_lo
    bne !isp_exit+
    inc zp_ptr_screen_hi
!isp_exit:
    rts

addto_screen_pos:
    lda zp_ptr_screen_lo
    clc
    adc #$28
    sta zp_ptr_screen_lo
    bcc !asp_exit+
    inc zp_ptr_screen_hi
!asp_exit:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// calculate_color_pos
//////////////////////////////////////////////////////////////////////////////////////
// Calculate color position based on x and y registers
//////////////////////////////////////////////////////////////////////////////////////
// Usage:
// 
//      ldx #$05
//      ldy #$10
//      jsr calculate_color_pos
//
//////////////////////////////////////////////////////////////////////////////////////
// Result: Stores color location in zp_ptr_color
//////////////////////////////////////////////////////////////////////////////////////
calculate_color_pos: // x = xpos y = ypos
    lda #<COLOR_RAM    // enter color pos into zp
    sta zp_ptr_color_lo
    lda #>COLOR_RAM
    sta zp_ptr_color_hi
    cpx #$00 // add x pos to color pos
!ccp_lp:
    beq !ccp_lp+
    inc zp_ptr_color_lo
    bne !ccp_lp_i+
    inc zp_ptr_color_hi
!ccp_lp_i:
    dex
    jmp !ccp_lp-
!ccp_lp:
    cpy #$00 // add y pos to color pos
!ccp_lp:
    beq !ccp_lp+
    lda zp_ptr_color_lo
    clc
    adc #$28
    sta zp_ptr_color_lo
    bcc !ccp_lp_i+
    inc zp_ptr_color_hi
!ccp_lp_i:
    dey
    jmp !ccp_lp-
!ccp_lp:
    rts

increment_color_pos:
    inc zp_ptr_color_lo
    bne !icp_exit+
    inc zp_ptr_color_hi
!icp_exit:
    rts

addto_color_pos:
    lda zp_ptr_color_lo
    clc
    adc #$28
    sta zp_ptr_color_lo
    bcc !acp_exit+
    inc zp_ptr_color_hi
!acp_exit:
    rts




//////////////////////////////////////////////////////////////////////////////////////
// string buffer data
strbuf:
.fill 256,0
buf_crsr:
.byte 

zprint:
    ldx #$00
!wl:
    lda (zp_tmp,x)
    beq !wl+
    jsr $ffd2
    inc zp_tmp_lo
    jmp !wl-
!wl:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// zero string buffer
zero_strbuf:
    lda #$00
    ldx #$00
!lp:
    sta strbuf,x
    inx
    bne !lp-
    stx buf_crsr
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