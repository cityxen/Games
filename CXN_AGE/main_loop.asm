//////////////////////////////////////////////////////////////////
// Main loop

restart:

	lda #00
	sta SOUND_PLAYING
	jsr sfk_clear

	lda DEV_PLAY_MUSIC
	sta PLAY_MUSIC

	ldx #0
	ldy #0
	lda #music.startSong-1 // <- Here we get the startsong and init address from the sid file
	jsr music.init

	jsr draw_main_screen

	jsr reset_timer2
	jsr reset_timer1

	lda #$02
	sta SCREEN_DRAW

main_loop:
	
	////////////////////////////////
	// SHOW DEBUG INFO
	jsr debug_stuff
	
	////////////////////////////////
	// DO TIMER STUFF
	lda TRIG_1
	beq !ml+
	// Do something here
	jsr reset_timer1
!ml:

	////////////////////////////////
	// CHECK KEYS
	jsr get_key

	cmp #KEY_M
	bne !ml+
	inc PLAY_MUSIC
	lda PLAY_MUSIC
	and #%00000001
	sta PLAY_MUSIC
!ml:
	////////////////////////////////
	// CHECK JOYS
	jsr get_button

!ml:
	cmp #JOY1_FIRE
	bne !ml+
	jmp game_start /////////// >>>>>>>>>> OUT!
	
!ml:
	////////////////////////////////
	// CHECK TIMER 2 to Do something
	lda TRIG_2
	cmp #$02
	bcc main_loop // Timer not reached, go back to main_loop

	lda #$00
	sta TRIG_2 // reset timer

	// toggle screen to draw
	inc SCREEN_DRAW
	lda SCREEN_DRAW
	cmp #$03
	bne !ml+
	lda #$00
	sta SCREEN_DRAW

!ml:

	lda SCREEN_DRAW
	cmp #$00 
	bne !sdl+
	jsr draw_main_screen
	jmp main_loop
!sdl:
	cmp #$01
	bne !sdl+
	jsr draw_instruct
!sdl:
	jmp main_loop