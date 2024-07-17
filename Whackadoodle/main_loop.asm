//////////////////////////////////////////////////////////////////
// Main loop

restart:

	lda meatloaf_hiscore_support
	beq !+
	jsr MLHS_API_GET_SCORE
!:

	lda #00
	sta sound_playing
	lda #$01
	sta play_music

	ldx #0
	ldy #0
	lda #music.startSong-1						//<- Here we get the startsong and init address from the sid file
	jsr music.init

	lda #$ff // reset user port values to output and zero
	sta USER_PORT_DATA_DIR
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA

	jsr draw_main_screen
	jsr pause

	jsr reset_timer2
	jsr reset_timer1

	lda #$02
	sta screen_draw

	lda #$00
	sta debug_mode

main_loop:
	jsr debug_stuff

	lda trig_1
	beq !ml+
	jsr reset_timer1
	jsr randomly_flash_buttons
	
!ml:
	jsr get_button

	cmp #BUTTON_RED
	beq !ml+
	cmp #BUTTON_GREEN 
	beq !ml+
	cmp #BUTTON_YELLOW
	beq !ml+
 	cmp #BUTTON_BLUE
	beq !ml+
	cmp #BUTTON_WHITE
	beq !ml+
	jmp !ml++

!ml:

	jsr game_setup_doodle
	jmp game_start
	
!ml:
	lda trig_2
	cmp #$02
	bcc main_loop
	lda #$00
	sta trig_2 // reset timer

	// toggle screen to draw
	inc screen_draw
	lda screen_draw
	cmp #$03
	bne !ml+
	lda #$00
	sta screen_draw

!ml:

	lda screen_draw
	cmp #$00 
	bne !sdl+
	jsr draw_main_screen
	jmp main_loop
!sdl:
	cmp #$01
	bne !sdl+
	jsr draw_instruct
	jmp main_loop
!sdl:
	cmp #$02
	bne !sdl+
	jsr draw_qr
	jmp main_loop
!sdl:
	cmp #$03
	bne !sdl+
	lda meatloaf_hiscore_support
	beq !+
	jsr draw_hiscores

	jmp main_loop
!:
	jsr draw_instruct
!sdl:
	jmp main_loop