//////////////////////////////////////////////////////////////
// WHACKADOODLE for C64 by Seth Parson
// aka Deadline / CityXen 2024
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

//////////////////////////////////////////////////////////////
// Main loop

main_loop_start:
restart:

	lda MLHS_ENABLE
	beq !++

	jsr MLHS_INIT

	lda dev_mode
	beq !+
	jsr MLHS_API_SET_SCORE // Always set CityXen 99 to get started
	jmp !+
!:
	jsr MLHS_API_GET_SCORE
!:

	lda #00
	sta sound_playing
	jsr sfx_clear

	lda dev_mode
	beq !+
	lda #$01
	sta debug_mode
	lda #$00
	jmp !++
!:
	lda #$01
!:
	sta play_music

	ldx #0
	ldy #0
	lda #music.startSong-1 // <- Here we get the startsong and init address from the sid file
	jsr music.init

	lda #$ff // reset user port values to output and zero
	sta USER_PORT_DATA_DIR
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA

	jsr draw_main_screen

	jsr pause5

	jsr reset_timer2
	jsr reset_timer1

	lda #$02
	sta screen_draw

main_loop:
	
	jsr debug_stuff
	
	lda eeu
	cmp #$05
	bne !+
	lda #$01
	sta eeu_act
!:
	
	lda eeu_act
	beq !+
	PrintColor(RED)
	PrintPlot(8,0)
	jsr eeu_print
!:
	lda irq_timer1_tr
	beq !ml+
	jsr reset_timer1
	jsr randomly_flash_buttons
!ml:
	jsr wad_get_key

	cmp #KEY_N
	bne !gl+
	lda #$00
	sta eeu_act
	sta eeu
!gl:

	cmp #KEY_M
	bne !gl+
	inc play_music
	lda play_music
	and #%00000001
	sta play_music
!gl:

	cmp #KEY_L
	bne !gl+
	lda #$01
	sta eeu
	jmp main_loop
!gl:
	cmp #KEY_O
	bne !gl+
	lda eeu
	cmp #$01
	bne !ee+
	inc eeu
	jmp main_loop
!ee:
	lda #$00
	sta eeu
	jmp main_loop
!gl:

	cmp #KEY_8
	bne !gl+
	lda eeu
	cmp #$02
	bne !ee+
	inc eeu
	jmp main_loop
!ee:
	lda #$00
	sta eeu
	jmp main_loop
!gl:

	cmp #KEY_B
	bne !gl+
	lda eeu
	cmp #$03
	bne !ee+
	inc eeu
	jmp main_loop
!ee:
	lda #$00
	sta eeu
	jmp main_loop
!gl:

	cmp #KEY_C
	bne !gl+
	lda eeu
	cmp #$04
	bne !ee+
	inc eeu
	jmp main_loop
!ee:
	lda #$00
	sta eeu
	jmp main_loop
!gl:

!ml:
	jsr wad_get_button

	cmp #BUTTON_BLUE
	bne !nbc+
	jmp !ml+
!nbc:
	cmp #BUTTON_RED
	bne !nbc+
	lda #MODE_EASY
	sta whack_mode
	jmp !ml+
!nbc:
	cmp #BUTTON_YELLOW
	bne !nbc+
	lda #MODE_NORMAL
	sta whack_mode	
	jmp !ml+
!nbc:
	cmp #BUTTON_WHITE
	bne !ml++
	lda #MODE_HARD
	sta whack_mode	
	jmp !ml+

!ml:

	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
	
	jsr game_setup_doodle
	jmp game_start
	
!ml:
	lda irq_timer2_tr
	cmp #$02
	bcs !ml+
	jmp main_loop
!ml:
	lda #$00
	sta irq_timer2_tr // reset timer

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
	lda MLHS_ENABLE
	beq !+
	jsr MLHS_DRAW
	jmp main_loop
!:
	jsr draw_instruct
!sdl:
	jmp main_loop

eeu:
.byte 0
eeu_act:
.byte 0

eeu_txt:
.encoding "petscii_upper"
.text "-A-5LROC8DBMC^ #M@OVD8E4 SGN8D-R4MNA-D3V1-!-2--"
.byte 0,0

eeu_print:
	lda #<eeu_txt
	sta zp_tmp_lo
	lda #>eeu_txt
	sta zp_tmp_hi

    clc
    ldy #$00
eeup2:
    lda (zp_tmp),y
    beq eeu_print_out
    jsr KERNAL_CHROUT
    inc zp_tmp_lo
    bne !+
    inc zp_tmp_hi
!:
    inc zp_tmp_lo
    bne !+
    inc zp_tmp_hi
!:
    jmp eeup2
eeu_print_out:
    rts
