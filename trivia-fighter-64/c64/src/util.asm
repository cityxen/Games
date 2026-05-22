//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

.macro CenterAns(ans) {
	StrLen(ans)
	stx x_reg   // Save X
	lda #16
	sec         // Set carry for subtraction
	sbc x_reg   // A = A - temp
	lsr
	clc
	cmp #18
	bcc!+
	lda #2
!:
	tax
!:
	stx x_reg
	PrintChr(' ')
	ldx x_reg
	dex
	bne !-
}


inc_player_1_avatar:
	inc player_1_avatar
	lda player_1_avatar
	cmp #CXN_AVATAR_END
	bne !+
	lda #$00
	sta player_1_avatar
!:
	jsr print_player_1_name
	jsr update_player_1_select_sprites
	rts

dec_player_1_avatar:
	dec player_1_avatar
	lda player_1_avatar
	cmp #$ff
	bne !+
	lda #CXN_AVATAR_END-1
	sta player_1_avatar
!:
	jsr print_player_1_name
	jsr update_player_1_select_sprites
	rts

inc_player_2_avatar:
	inc player_2_avatar
	lda player_2_avatar
	cmp #CXN_AVATAR_END
	bne !+
	lda #$00
	sta player_2_avatar
!:
	jsr print_player_2_name
	jsr update_player_2_select_sprites
	rts

dec_player_2_avatar:
	dec player_2_avatar
	lda player_2_avatar
	cmp #$ff
	bne !+
	lda #CXN_AVATAR_END-1
	sta player_2_avatar
!:
	jsr print_player_2_name
	jsr update_player_2_select_sprites
	rts

print_player_1_name:
	lda game_step
	cmp #GAME_STEP_SELECT
	bne !+
	PrintPlot(PLAYER_1_SELECT_SCREEN_X,PLAYER_1_SELECT_SCREEN_Y)
	jmp pp1n_out
!:
	cmp #GAME_STEP_SELECT_
	bne !+
	PrintPlot(PLAYER_1_SELECT_SCREEN_X,PLAYER_1_SELECT_SCREEN_Y)
	jmp pp1n_out
!:
	PrintPlot(PLAYER_1_GAME_SCREEN_X,PLAYER_1_GAME_SCREEN_Y)

pp1n_out:
	lda player_1_avatar
	jsr print_player_name
	rts

print_player_2_name:
	lda game_step
	cmp #GAME_STEP_SELECT
	bne !+
	PrintPlot(PLAYER_2_SELECT_SCREEN_X,PLAYER_2_SELECT_SCREEN_Y)
	jmp pp2n_out
!:
	cmp #GAME_STEP_SELECT_
	bne !+
	PrintPlot(PLAYER_2_SELECT_SCREEN_X,PLAYER_2_SELECT_SCREEN_Y)
	jmp pp2n_out
!:
	PrintPlot(PLAYER_2_GAME_SCREEN_X,PLAYER_2_GAME_SCREEN_Y)
pp2n_out:
	lda player_2_avatar
	jsr print_player_name
	rts	

print_player_name:
	sta a_reg
	stx x_reg
	sty y_reg
	tax              // avatar index → X before zp_tmp clobbers A
	lda zp_tmp_lo
	sta tmp_1
	lda zp_tmp_hi
	sta tmp_2

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

	lda #select_sprite_4_x
	sta SPRITE_4_X
	lda #select_sprite_4_y
	sta SPRITE_4_Y
	
	ldx player_2_avatar	
	lda cxn_avatar_sprite_color_i,x
	sta SPRITE_4_COLOR

	ldx player_2_avatar	
	lda cxn_avatar_sprite_pointer_i,x
	ReverseSpriteMultiColorA(sp_ptr_a)

	lda #sp_ptr_a
	sta SPRITE_4_POINTER

	lda cxn_avatar_selected
	and #cxn_avatar_selected_p2	
	beq up2ss_out
	lda #$00
	sta SPRITE_3_X
	sta SPRITE_3_Y
	sta SPRITE_5_X
	sta SPRITE_5_Y
	rts

up2ss_out:

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

randomize_avatars: 
	GetTimer(12)
	and #%00001111
	cmp #10
	bcc !+
	lda #1
!:
	sta player_1_avatar

	GetTimer(13)
	and #%00001111
	cmp #10
	bcc !+
	lda #1
!:	
	sta player_2_avatar
	rts



////////////////////////////////////////////////////////////
// Who buzzed in first subroutine
who_buzzed_in_first:
	pha
	lda game_round_first_buzzer
	bne !+
	pla
	sta game_round_first_buzzer
	rts
!:
	pla
	rts
// END WHO BUZZED IN FIRST
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// draw healthbar changes subroutine
update_health_bars:
	lda #$40
	ldx #$00 
!:
	sta PLAYER_1_HEALTH_BAR_LOC,x
	inx
	cpx player_1_healthbar
	bne !-
	ldx #$00
!:
	sta PLAYER_2_HEALTH_BAR_LOC,x
	inx
	cpx player_2_healthbar
	bne !-
	rts
// END health bar update
////////////////////////////////////////////////////////////




init_timers_user_hook:
	lda #TIMER_FADER_SPEED
	SetTimerTo(TIMER_FADER)
	FullReset(TIMER_FADER)

// start times to begin fading
	lda #TIMER_QUESTION_FADE
	SetTimer(TIMER_FADE_Q)
	FullReset(TIMER_FADE_Q)

	lda #TIMER_ANS_1_FADE
	SetTimer(TIMER_FADE_A1)
	FullReset(TIMER_FADE_A1)

	lda #TIMER_ANS_2_FADE
	SetTimer(TIMER_FADE_A2)
	FullReset(TIMER_FADE_A2)

	lda #TIMER_ANS_3_FADE
	SetTimer(TIMER_FADE_A3)
	FullReset(TIMER_FADE_A3)

	lda #TIMER_ANS_4_FADE
	SetTimer(TIMER_FADE_A4)
	FullReset(TIMER_FADE_A4)
/*
	lda #TIMER_SPRITE_ANIM_SPEED
	SetTimerTo(TIMER_SPRITE_ANIM)
	FullReset(TIMER_SPRITE_ANIM)	
	*/

	rts

irq_timer_user_hook:

	TickSpriteObj(yin_obj, yin_state)
	TickSpriteObj(player_1_obj, player_1_state)
	TickSpriteObj(player_2_obj, player_2_state)

/*
	GetTimerTr(TIMER_SPRITE_ANIM)
	beq !++
	FullReset(TIMER_SPRITE_ANIM)
	ldx #$00
	inc sprite_anim_table_counters,x
	lda sprite_anim_table_counters,x
	tax
	lda sprite_anim_table_yin_yang,x
	beq !+
	sta SPRITE_7_POINTER
	jmp !++
!:
	ldx #$00
	lda #$00
	sta sprite_anim_table_counters,x
	lda sprite_anim_table_yin_yang,x
	sta SPRITE_7_POINTER
!:
	*/
	rts

begin_fade_in_question:
	rts

begin_fade_in_ans_1:
	rts

begin_fade_in_ans_2:
	rts

begin_fade_in_ans_3:
	rts

begin_fade_in_ans_4:
	rts