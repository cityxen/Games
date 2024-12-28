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

last_button:
.byte 0
check_jitter_doodle:
	lda irq_timer_jitter_tr
	bne !cj+
	rts	
!cj:
	jsr reset_jitter_timer
	jsr game_setup_doodle
!cj:
	rts

game_setup_doodle:

	lda button_to_hit
	sta last_button

	lda whack_mode
	cmp #MODE_EASY
	beq easy_speed

	cmp #MODE_HARD
	beq hard_speed

	// lda whack_score_lo // check score adjust speed
	lda score
	cmp #99
	bcs faster_3
	cmp #80
	bcs faster_2		
	cmp #40
	bcs faster
	jmp over_mode_speeds

easy_speed:
	lda #doodle_speed_easy
	sta irq_timer_jitter_to
	jmp over_mode_speeds
hard_speed:
	lda #doodle_speed_hard
	sta irq_timer_jitter_to
	jmp faster_3

over_mode_speeds:
	lda irq_timer_jitter_to
	clc
	sbc #$05
	sta irq_timer_jitter_to
	lda irq_timer_jitter_to
	cmp #50
	bcs !+
	lda #50
	sta irq_timer_jitter_to
!:
	jmp outfaster
faster:
	lda irq_timer_jitter_to
	clc
	sbc #$01
	sta irq_timer_jitter_to	

	lda irq_timer_jitter_to
	cmp #40
	bcs !+
	lda #40
	sta irq_timer_jitter_to
!:
	jmp outfaster
faster_2:
	lda irq_timer_jitter_to
	clc
	sbc #$01
	sta irq_timer_jitter_to	
	lda irq_timer_jitter_to
	cmp #30
	bcs !+
	lda #30
	sta irq_timer_jitter_to
!:
	jmp outfaster
faster_3:
	lda irq_timer_jitter_to
	clc
	sbc #$01
	sta irq_timer_jitter_to	

	lda irq_timer_jitter_to
	cmp #20
	bcs !+
	lda #20
	sta irq_timer_jitter_to
!:


outfaster:

	// did_hit = 0 // timed out (figure out faction 
	               //    if missed bad target = -1 life)
	// did_hit = 1 // hit target +1 score
	// did_hit = 2 // hit wrong target -1 score / -1 life
	// did_hit = 3 // hit wrong button -1 life

	lda did_hit
	bne !gsd+

	lda doodle
	clc
	cmp #$04
	bcc !gsd+

	jsr play_sound_miss
	lda #$02
	jsr set_message
	dec whack_life // life -1

	rts 

!gsd:

	jsr play_sound_ding
	lda #$09
	sta button_actually_hit

!gsd:
	jsr lda_random_kern
	and #%00000111
	cmp #$05
	bcs !gsd-
	sta button_to_hit
	cmp last_button
	beq !gsd-

!gsd:
	jsr lda_random_kern
	and #%00001111
	cmp #$08
	bcs !gsd-
	sta doodle


	// TODO: Check mode parameters here
	lda whack_mode
	cmp #MODE_EASY
	bne !+
	jsr lda_random_kern
	and #%00000011
	adc #$03
	sta doodle
	
!:
	lda doodle
	cmp #$00
	bne !gsd+
	lda #sp_happyface
	sta SPRITE_0_POINTER
	jmp gsdso
!gsd:
	cmp #$01
	bne !gsd+
	lda #sp_yinyang
	sta SPRITE_0_POINTER
	jmp gsdso
!gsd:
	cmp #$02
	bne !gsd+
	lda #sp_heart
	sta SPRITE_0_POINTER
	jmp gsdso
!gsd:
	cmp #$03
	bne !gsd+
	lda #sp_star
	sta SPRITE_0_POINTER
	jmp gsdso
!gsd:
	cmp #$04
	bne !gsd+
	lda #sp_rad
	sta SPRITE_0_POINTER
	jmp gsdso
!gsd:
	cmp #$05
	bne !gsd+
	lda #sp_skull
	sta SPRITE_0_POINTER
	jmp gsdso
!gsd:
	cmp #$06
	bne !gsd+
	lda #sp_poo
	sta SPRITE_0_POINTER
	jmp gsdso
!gsd:
	cmp #$07
	bne !gsd+
	lda #sp_frown
	sta SPRITE_0_POINTER

gsdso:
	
	lda button_to_hit
	cmp #$00
	bne !gsd+

	lda #butt1_sprite_x
	sta SPRITE_0_X
	lda #butt1_sprite_y
	sta SPRITE_0_Y
	lda #butt1_sprite_m
	sta SPRITE_MSB_X

	lda #BUTTON_LIGHT_RED
	sta USER_PORT_DATA
	
	rts

!gsd:

	cmp #$01
	bne !gsd+

	lda #butt2_sprite_x
	sta SPRITE_0_X
	lda #butt2_sprite_y
	sta SPRITE_0_Y
	lda #butt2_sprite_m
	sta SPRITE_MSB_X

	lda #BUTTON_LIGHT_GREEN
	sta USER_PORT_DATA
	rts

!gsd:

	cmp #$02
	bne !gsd+

	lda #butt3_sprite_x
	sta SPRITE_0_X
	lda #butt3_sprite_y
	sta SPRITE_0_Y
	lda #butt3_sprite_m
	sta SPRITE_MSB_X

	lda #BUTTON_LIGHT_YELLOW
	sta USER_PORT_DATA
	rts

!gsd:

	cmp #$03
	bne !gsd+

	lda #butt4_sprite_x
	sta SPRITE_0_X
	lda #butt4_sprite_y
	sta SPRITE_0_Y
	lda #butt4_sprite_m
	sta SPRITE_MSB_X

	lda #BUTTON_LIGHT_BLUE
	sta USER_PORT_DATA
	rts

!gsd:

	cmp #$04
	bne !gsd+

	lda #butt5_sprite_x
	sta SPRITE_0_X
	lda #butt5_sprite_y
	sta SPRITE_0_Y
	lda #butt5_sprite_m
	sta SPRITE_MSB_X

	lda #BUTTON_LIGHT_WHITE
	sta USER_PORT_DATA
	rts

!gsd:

	rts