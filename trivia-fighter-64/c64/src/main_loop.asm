//////////////////////////////////////////////////////////////////////////////////////
//
// TRIVIA FIGHTERS 64 for C64
//
//                            by Deadline / CityXen 2026
// 
// Dependencies:
// The include folder from: https://github.com/cityxen/retro-dev-tools/include/commodore64
// must be in kickassembler path in the KickAss.cfg file:
//   -libdir "PATHTO:\dev\cityxen\retro-dev-tools\include\commodore64"
//
// CityXen Videos: https://youtube.com/@cityxen
// CityXen Games: https://cityxen.itch.io
//
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////
// Main loop initialize
main_loop_start:
restart:
	lda #$01
	sta play_sound
	jsr sfx_clear
	ldx #0
	ldy #0
	lda #music.startSong-1 // <- Here we get the startsong and init address from the sid file
	jsr music.init
	lda #$01
	sta play_music
	lda #$ff // reset user port values to output and zero
	sta USER_PORT_DATA_DIR
	lda #BUTTON_LIGHT_NONE
	sta USER_PORT_DATA
	jsr randomize_avatars
	FullReset(TIMER_SCREEN_CHANGE)
	FullReset(TIMER_1)
	FullReset(TIMER_2)
	FullReset(TIMER_3)
	lda #$00
	sta screen_draw
	PrintChr($93)
	jsr ml_screens

    ApplySpriteObj(yin_obj, yin_state)
    ApplySpriteObj(player_1_obj, player_1_state)
    ApplySpriteObj(player_2_obj, player_2_state)
	
	EnableSpriteObj(yin_obj)
	EnableSpriteObj(player_1_obj)
	EnableSpriteObj(player_2_obj)

	// ApplySpriteObj wrote the template colors over the avatar head colors;
	// re-apply them so the heads start with the right colors
	jsr init_sprites_ms

	// fall through to main_loop
//////////////////////////////////////////////////////////////
// Main loop
main_loop:

	jsr anim_sprites_main_loop

	jsr debug_stuff
	GetTimerTr(TIMER_2)
	cmp #$04
	bne !+
	FullReset(TIMER_2)
	jsr randomize_avatars
	jsr init_sprites_ms
	jsr randomly_flash_buttons
	ResetSpriteObjMove()
!:	
	GetTimerTr(TIMER_SCREEN_CHANGE)
	cmp #$02
	bne !+
	FullReset(TIMER_SCREEN_CHANGE)
	inc screen_draw // toggle screen to draw
	jsr ml_screens
!:
	jsr input_get_key
	cmp #KEY_A
	bne !+
	jsr anim_menu
	jmp ml_after_anim
!:
	cmp #KEY_M
	bne !+
	lda play_music
	eor #$01
	sta play_music
	lda screen_draw
	bne!+
	PrintHome()
	PrintDown(15)
	PrintRight(24)
	PrintChr(5)
	lda play_music
	jsr print_yesno
!:
	
	cmp #KEY_F1 // toggle meatloaf loading
	bne !+
	lda ml_enabled
	eor #$01
	sta ml_enabled
	jsr trivia_load_count // refresh count from the new source
	jsr trivia_refresh_screen
!:
	cmp #KEY_F3 // cycle trivia load drive 8-11
	bne !+
	ldx ldsk_drive_number
	inx
	cpx #12
	bne !nowrap+
	ldx #$08
!nowrap:
	stx ldsk_drive_number
	jsr trivia_load_count // refresh count from the new drive
	jsr trivia_refresh_screen
!:
	cmp #KEY_T
	bne !+
	lda #$00
	sta play_music
	lda #$30
	SetTimerTo(0)
	jmp load_trivia_stress_test
!:
	//////////////////////////////
	// Player-mode select:
	//   P1 WHITE = 1-Player (CPU plays P2)     → number_of_players = 0
	//   P2 WHITE = 2-Player (real human on P2) → number_of_players = 1
	// The M2 joy history bytes are debounced over 8 frames, which is too
	// slow for a menu read. Read the raw fire bits directly — bit 4 of
	// $DC01 (P1) and $DC00 (P2) are active low when the fire button is
	// pressed. We still need to feed the M2 history each frame so the
	// state is correct by the time we hand off to the character-select.
	jsr il_get_j1_m2        // keep M2 history current (j1_button etc.)
	jsr il_get_j2_m2
	// P1 fire (raw): $00 if pressed, non-zero if released
	lda JOYSTICK_PORT_1
	and #%00010000
	bne !+
	lda #$00 // 1 Player Mode
	sta number_of_players
	jmp ml_game_start
!:
	lda JOYSTICK_PORT_2
	and #%00010000
	bne !+
	lda #$01 // 2 Player Mode
	sta number_of_players
	jmp ml_game_start
!:
	jmp main_loop
// END MAIN LOOP
//////////////////////////////////////////////////

ml_game_start:
	// Hold off the next M2 input read until the char-select screen has
	// settled. ml_game_start fires on the same frame as the press, and the
	// M2 history byte was just set to $ff — without this reset the fire
	// press would still be "active" and immediately lock in P1's avatar.
	FullReset(TIMER_INPUT)
	lda #BUTTON_LIGHT_NONE // Turn off button lights
	sta USER_PORT_DATA
	jmp game_start

// redraw the main screen (if showing) after F1/F3 change
// meatloaf status, drive or trivia count
trivia_refresh_screen:
	lda screen_draw
	bne !+
	jsr draw_main_screen
!:	rts

ml_screens:
	lda screen_draw
	cmp #$02
	bne !+
	lda #$00
	sta screen_draw
!:
	cmp #$00 
	beq !+
	jmp !++
!:
	jsr draw_main_screen
	rts
!:
	jsr draw_instruct
	rts

load_trivia_stress_test:
	jsr draw_loading_screen
	jsr trivia_load // load random trivia question
	jsr draw_play_screen
	sfx_v2_play(SFX_POW)
	PrintHome()
	PrintLF()
	PrintLF()
	PrintLF()
	PrintLF()
	PrintRight(6)
	PrintChr(5)
    lda #< MLHL_DATA_QUESTION
    sta zp_tmp_lo
    lda #> MLHL_DATA_QUESTION
    sta zp_tmp_hi 
	ldy #$00
	sty tmp_1
!:
	lda (zp_tmp),y
	beq st_lf_out
    jsr KERNAL_CHROUT
	lda (zp_tmp),y
	iny
	inc tmp_1
	cmp #' '
	bne !-
	clc
	lda tmp_1
	cmp #25
	bcc !-
	lda #$00
	sta tmp_1
	PrintLF()
	PrintRight(6)
	jmp !-
st_lf_out:
	PrintChr('?')
	PrintLF()
	PrintChr(KEY_YELLOW)
	lda MLHL_DATA_CORRECT
	sbc #47
	PrintHexXY(2,2)
	lda ml_enabled // show loaded question number (local disk only)
	bne !+
	PrintPlot(5,2)
	PrintChr(KEY_YELLOW)
	ldx #$00
!lp:
	lda LDSK_FILENAME,x
	cmp #$2e // stop at '.' of N.TRIVIA
	beq !+
	jsr KERNAL_CHROUT
	inx
	bne !lp-
!:
	PrintHome()
	PrintChr(KEY_WHITE)
	PrintDown(13)
	PrintRight(3)
	CenterAns(MLHL_DATA_ANS1)
	Print(MLHL_DATA_ANS1)
	PrintLF()
	PrintUp(1)
	PrintRight(21)
	CenterAns(MLHL_DATA_ANS2)
	Print(MLHL_DATA_ANS2)
	PrintLF()
	PrintDown(7)
	PrintRight(3)
	CenterAns(MLHL_DATA_ANS3)
	Print(MLHL_DATA_ANS3)
	PrintLF()
	PrintUp(1)
	PrintRight(21)
	CenterAns(MLHL_DATA_ANS4)
	Print(MLHL_DATA_ANS4)
	PrintLF()
	lda #TIMER_STRESS
	SetTimerTo(TIMER_1)
	FullReset(TIMER_1)
!:
	PrintPlot(16,24)
	PrintLowerCase()
	PrintChr(KEY_WHITE)
	Print(trivia_round_text)
	PrintChr(KEY_S+32)
	PrintChr(KEY_T+32)
	jsr input_get_key
	cmp #KEY_Q
	bne !+
	lda #$00
	sta screen_draw
	FullReset(TIMER_1)
	jmp restart
!:
	GetTimerTr(TIMER_1)
	sta tmp_1
	sec
	lda #$20
	sbc tmp_1
	tax
	lda #$20   // remove timer bar as it counts down
	sta 1027,x // just write ' ' over it
	GetTimerTr(TIMER_1)
	cmp #32
	bne !--
	jmp load_trivia_stress_test
// END STRESS TEST

anim_sprites_main_loop:
	TickSpriteObjMove(yin_obj, yin_move_table)
	TickSpriteObjSfx(yin_state, yin_sfx_table)
	jsr wait_vbl
	FlushSpriteObj(yin_obj, yin_state)
	jsr wait_vbl
	FlushSpriteObj(player_1_obj, player_1_state)
	jsr wait_vbl
	FlushSpriteObj(player_2_obj, player_2_state)
	rts

//////////////////////////////////////////////////////////////
// Animation player menu (entered from the main screen with the A key).
// Lists ANIM_MENU_PAGE_SIZE animations per page; SPACE flips to the next page
// (wrapping back to the first). Plays the chosen one (anim_play in
// game_loop.asm) and loops back to the list. Q returns to the main screen.
anim_menu:
	lda #$00                // always open on the first page
	sta anim_menu_base
	DisableSpriteObj(player_1_obj)
	DisableSpriteObj(player_2_obj)
am_draw:
	DisableSpriteObj(yin_obj)   // keep the spinning yin-yang off the menu
	jsr draw_anim_screen
	PrintChr(KEY_WHITE)
	PrintDown(1)
	PrintRight(7)
	Print(anim_menu_title)
	PrintLF()
	ldx #$00
am_list:
	stx tmp_1               // tmp_1 = index within the page
	lda anim_menu_base      // tmp_2 = registry index
	clc
	adc tmp_1
	cmp #ANIM_MENU_COUNT
	bcs am_list_done        // short last page — stop early
	sta tmp_2
	PrintRight(8)
	// label: page entries 0-8 -> '1'..'9', 9-14 -> 'a'..'f'
	lda tmp_1
	cmp #9
	bcc !digit+
	clc
	adc #($41-9)            // 9 -> 'a' ($41) ... 14 -> 'f' ($46)
	jmp !put+
!digit:
	clc
	adc #$31                // 0 -> '1'
!put:
	jsr KERNAL_CHROUT
	PrintChr('.')
	PrintChr(' ')
	ldx tmp_2
	lda anim_menu_name_lo,x
	sta zp_tmp_lo
	lda anim_menu_name_hi,x
	sta zp_tmp_hi
	jsr print
	PrintLF()
	ldx tmp_1
	inx
	cpx #ANIM_MENU_PAGE_SIZE
	bne am_list
am_list_done:
	PrintLF()
	PrintRight(2)
	Print(anim_menu_prompt)
am_wait:
	jsr input_get_key
	cmp #KEY_Q
	beq am_exit
	cmp #KEY_SPACE          // next page (wraps to the first)
	bne !+
	lda anim_menu_base
	clc
	adc #ANIM_MENU_PAGE_SIZE
	cmp #ANIM_MENU_COUNT
	bcc !nowrap+
	lda #$00
!nowrap:
	sta anim_menu_base
	jmp am_draw
!:
	cmp #$3a                // past '9'? then try the a-f keys
	bcs am_letter
	sec
	sbc #$31                // '1'..'9' -> 0..8
	bcc am_wait             // below '1'
	jmp am_select
am_letter:
	cmp #$41                // 'a'/'A' key ($41)
	bcc am_wait
	sec
	sbc #($41-9)            // 'a'($41)->9 ... 'f'($46)->14
	cmp #ANIM_MENU_PAGE_SIZE
	bcs am_wait             // beyond this page's labels
am_select:
	pha
	jsr draw_anim_screen
	pla
	clc                     // page slot -> registry index
	adc anim_menu_base
	cmp #ANIM_MENU_COUNT
	bcs am_wait             // empty slot on the last page
	tax                     // X = index
	lda anim_menu_m1_lo,x   // missile (special attack) tables for this cutscene
	sta anim_m1_tbl_lo
	lda anim_menu_m1_hi,x
	sta anim_m1_tbl_hi
	lda anim_menu_m2_lo,x
	sta anim_m2_tbl_lo
	lda anim_menu_m2_hi,x
	sta anim_m2_tbl_hi
	ldy anim_menu_tbl_lo,x  // Y = <table
	lda anim_menu_tbl_hi,x
	tax                     // X = >table
	tya                     // A = <table

	jsr anim_play

	jmp am_draw             // redraw the list, pick again
am_exit:
	rts

//////////////////////////////////////////////////////////////
// Restore the main screen + attract-mode sprites after the animation menu.
ml_after_anim:
	lda #$00
	sta screen_draw
	jsr ml_screens          // redraw main screen (re-inits its sprites)
	ApplySpriteObj(yin_obj, yin_state)
	ApplySpriteObj(player_1_obj, player_1_state)
	ApplySpriteObj(player_2_obj, player_2_state)
	EnableSpriteObj(yin_obj)
	EnableSpriteObj(player_1_obj)
	EnableSpriteObj(player_2_obj)
	jsr init_sprites_ms     // restore avatar head colors over the template ones
	// the trigger counts kept climbing in the menu, past the main loop's
	// exact-match cmp checks — reset so head cycling / screen flip resume
	FullReset(TIMER_2)
	FullReset(TIMER_SCREEN_CHANGE)
	jmp main_loop