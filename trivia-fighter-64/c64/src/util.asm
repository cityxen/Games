//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

inc_player_1_avatar:
	inc player_1_avatar
	lda player_1_avatar
	cmp #CXN_AVATAR_END
	bne !+
	lda #$00
	sta player_1_avatar
!:
	rts

dec_player_1_avatar:
	dec player_1_avatar
	lda player_1_avatar
	cmp #$ff
	bne !+
	lda #CXN_AVATAR_END-1
	sta player_1_avatar
!:
	rts

inc_player_2_avatar:
	inc player_2_avatar
	lda player_2_avatar
	cmp #CXN_AVATAR_END
	bne !+
	lda #$00
	sta player_2_avatar
!:
	rts

dec_player_2_avatar:
	dec player_2_avatar
	lda player_2_avatar
	cmp #$ff
	bne !+
	lda #CXN_AVATAR_END-1
	sta player_2_avatar
!:
	rts

print_player_1_name:
	lda game_step
	cmp #GAME_STEP_SELECT
	bne !+
	PrintPlot(PLAYER_1_SELECT_SCREEN_X,PLAYER_1_SELECT_SCREEN_Y)
	jmp !++
!:
	PrintPlot(PLAYER_1_GAME_SCREEN_X,PLAYER_1_GAME_SCREEN_Y)
!:
	lda player_1_avatar
	jsr print_player_name
	rts

print_player_2_name:
	lda game_step
	cmp #GAME_STEP_SELECT
	bne !+
	PrintPlot(PLAYER_2_SELECT_SCREEN_X,PLAYER_2_SELECT_SCREEN_Y)
	jmp !++
!:
	PrintPlot(PLAYER_2_GAME_SCREEN_X,PLAYER_2_GAME_SCREEN_Y)
!:
	lda player_2_avatar
	jsr print_player_name
	rts	

print_player_name:
	sta a_reg
	stx x_reg
	sty y_reg
	lda zp_tmp_lo
	sta tmp_1
	lda zp_tmp_hi
	sta tmp_2

	lda a_reg

	// lda with player avatar 
	tax
	lda cxn_avatar_t_i,x
	tax
	lda cxn_avatar_t,x
	sta print_pointer_lo
	inx
	lda cxn_avatar_t,x
	sta print_pointer_hi

	PrintChr(5) 
	
	lda print_pointer_lo
    sta zp_tmp_lo
    lda print_pointer_hi
    sta zp_tmp_hi

    jsr print
	
	lda tmp_1
	sta zp_tmp_lo
	lda tmp_2
	sta zp_tmp_hi

	ldx x_reg
	ldy y_reg
	lda a_reg
	rts


update_player_1_select_sprites:

	// sprite 1
	lda #select_sprite_1_x
	sta SPRITE_1_X
	lda #select_sprite_1_y
	sta SPRITE_1_Y
	ldx player_1_avatar
	lda cxn_avatar_sprite_pointer_i,x
	sta SPRITE_1_POINTER
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_1_COLOR

	lda cxn_avatar_selected
	PrintHexXY(0,0)

	lda cxn_avatar_selected
	and #cxn_avatar_selected_p1
	beq up1ss_out
	lda #$00
	sta SPRITE_0_X
	sta SPRITE_0_Y
	sta SPRITE_2_X
	sta SPRITE_2_Y
	rts

up1ss_out:	
	// sprite 0
	lda #select_sprite_0_x
	sta SPRITE_0_X
	lda #select_sprite_0_y
	sta SPRITE_0_Y

	ldx player_1_avatar
	dex
	cpx #$ff
	bne !+
	ldx #CXN_AVATAR_END-1
!:
	lda cxn_avatar_sprite_pointer_i,x
	sta SPRITE_0_POINTER
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_0_COLOR	
!:	
	// sprite 2
	lda #select_sprite_2_x
	sta SPRITE_2_X
	lda #select_sprite_2_y
	sta SPRITE_2_Y

	ldx player_1_avatar
	inx
	cpx #CXN_AVATAR_END
	bne !+
	ldx #$00
!:
	lda cxn_avatar_sprite_pointer_i,x
	sta SPRITE_2_POINTER
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_2_COLOR

	rts

update_player_2_select_sprites:

	//sprite 4
	lda #select_sprite_4_x
	sta SPRITE_4_X
	lda #select_sprite_4_y
	sta SPRITE_4_Y
	ldx player_2_avatar	
	lda cxn_avatar_sprite_pointer_i,x
	sta SPRITE_4_POINTER
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_4_COLOR

	lda cxn_avatar_selected
	and #cxn_avatar_selected_p2
	cmp #cxn_avatar_selected_p2
	bne !+
	rts
!:

	// sprite 3
	lda #select_sprite_3_x
	sta SPRITE_3_X
	lda #select_sprite_3_y
	sta SPRITE_3_Y

	ldx player_2_avatar
	dex
	cpx #$ff
	bne !+
	ldx #CXN_AVATAR_END-1
!:
	lda cxn_avatar_sprite_pointer_i,x
	sta SPRITE_3_POINTER
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_3_COLOR
	


	// sprite 5
	lda #select_sprite_5_x
	sta SPRITE_5_X
	lda #select_sprite_5_y
	sta SPRITE_5_Y

	ldx player_2_avatar
	inx
	cpx #CXN_AVATAR_END
	bne !+
	ldx #$00
!:
	lda cxn_avatar_sprite_pointer_i,x
	sta SPRITE_5_POINTER
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_5_COLOR
	rts


//////////////////////////////////////////////////////////////
// Make buttons blink randomly

randomly_flash_buttons:
	jsr lda_random_kern
	and #BUTTON_LIGHT_ALL
	sta random_num
	sta USER_PORT_DATA
	rts

/////////////////////////////////////////////////////
// Get Button Press

input_get_button:
	GetTimerTr(5) // joystick read timer
	beq !gb+
	ResetTimer(5)
	lda #$00
	SetTimerTr(5)
	lda JOYSTICK_PORT_1
	rts
!gb:
	lda #$ff
	rts

/////////////////////////////////////////////////////
// Get Key Press

input_get_key:
	// lda irq_timer_input_tr
	// beq !gb+
	jsr KERNAL_GETIN
	// sta whack_key
	// jsr reset_input_timer
	// lda whack_key
	rts
!gb:
	lda #$00
	rts


