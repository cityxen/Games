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
	ReverseSpriteMultiColorA(sp_ptr_p2_head)

	lda #sp_ptr_p2_head
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
	// software LFSR, stepped once per pick — the music owns SID voice 3 on
	// this screen (so $d41b can freeze), and the IRQ timers alias against
	// the sampling rate (so timer-based picks barely changed)
	jsr ra_next_avatar
	sta player_1_avatar
	jsr ra_next_avatar
	cmp player_1_avatar     // same head as p1? take the next one instead
	bne !+
	clc
	adc #1
	cmp #10                 // wrap avatar 10 -> 0
	bcc !+
	lda #0
!:
	sta player_2_avatar
	rts

// Advance the LFSR (period 255, never 0) and map to an avatar index:
// 0-9 as-is, 10-15 clamp to 1.
ra_next_avatar:
	lda ra_seed
	asl
	bcc !+
	eor #$1d
!:
	sta ra_seed
	and #%00001111
	cmp #10
	bcc !+
	lda #1
!:
	rts
ra_seed: .byte $5a

// Advance the LFSR and return the full byte (0-255, never 0).
// Used by the 1-Player CPU for unbiased range draws (caller masks/clampes).
ra_random_byte:
	lda ra_seed
	asl
	bcc !+
	eor #$1d
!:
	sta ra_seed
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

////////////////////////////////////////////////////////////
// 1-Player CPU player 2
// ================================
// When number_of_players == 0 the human plays P1 and the CPU plays P2.
// The CPU drives the same state the joystick would have driven:
//   * Avatar select — picks a random number of "right" moves (0-9) and fires
//   * Round answer  — waits a random delay, then buzzes in 50% correct
//
// State machine for avatar selection (cpu_p2_avatar_state):
//   0 = idle / not started (cpu_p2_avatar_reset moves this to 1)
//   1 = armed: pick random number of moves, wait for debounce
//   2 = press right (inc_player_2_avatar), loop back to 1
//   3 = press fire (set cxn_avatar_selected_p2, advance to 4)
//   4 = done — fire pressed, game_step_select will advance the step
//
// Each state is one TIMER_INPUT tick; delays between states are
// real-frame waits (cpu_p2_wait_frames) so the avatar visibly moves
// through its picks.

cpu_p2_avatar_reset:
	lda #0
	sta cpu_p2_avatar_state
	sta cpu_p2_avatar_moves
	sta cpu_p2_avatar_ticks
	rts

// Start a CPU P2 delay that lasts `frames` vblanks. Stores the target
// frame so cpu_p2_avatar_tick can poll it non-blockingly. The frame
// counter is 8-bit (irq_timer_user_hook incs it every frame), so the
// stored "target" is computed as (current + frames) mod 256. The poll
// then compares cpu_p2_frame_count against the target and waits for
// it to match.
cpu_p2_arm_delay:
	sta tmp_2                       // frames to wait (1-255)
	clc
	lda cpu_p2_frame_count
	adc tmp_2                       // (now + frames) mod 256
	sta cpu_p2_avatar_target
	rts

// Returns 1 if the armed delay has elapsed (carry clear + A=$01),
// 0 if still waiting. Uses 8-bit arithmetic; the wrap is harmless
// because the caller armed the target as `now + delay` and we just
// wait for the counter to land on the target value.
cpu_p2_delay_done:
	lda cpu_p2_frame_count
	cmp cpu_p2_avatar_target
	bne !not_yet+
	// On target — return 1
	lda #$01
	rts
!not_yet:
	clc
	lda #$00
	rts

// Non-blocking avatar-pick state machine. Called once per main loop
// iteration; the main loop runs many times per frame, so this
// cooperates with the IRQ-driven frame counter (cpu_p2_frame_count)
// to give real wall-clock delays without busy-waiting on the raster.
// Because it never blocks, the human's J1 polling in the same loop
// gets to run between CPU P2 ticks.
cpu_p2_avatar_tick:
	lda cpu_p2_avatar_state
	bne !cpus1+
	// State 0: arm the CPU — pick a random move count and switch to state 1
	jsr ra_next_avatar            // 0-9
	sta cpu_p2_avatar_moves
	// Lead-in: full LFSR byte (1-255 frames). Some picks will pause
	// 4+ seconds before moving at all — the "human sat down, picked up
	// the joystick, is about to press" beat. Min 1 frame so the call
	// doesn't skip the wait entirely on a zero draw.
	jsr ra_random_byte
	bne !+                          // 0 → 1 (avoid no-wait)
	lda #1
!:
	jsr cpu_p2_arm_delay
	lda #1
	sta cpu_p2_avatar_state
	rts
!cpus1:
	cmp #1
	bne !cpus2+
	// State 1: arm either a move or a fire (if elapsed)
	jsr cpu_p2_delay_done
	beq !cpus1go+                  // delay not done (A=0) — return
	                               //   without changing state
	// delay done:
	lda cpu_p2_avatar_moves
	bne !cpus1move+
	// No moves left — pre-fire pause: full LFSR byte (1-255 frames,
	// 17ms-4.25s). Long pauses here are great: the CPU lands on an
	// avatar, hesitates, then commits.
	jsr ra_random_byte
	bne !+
	lda #1
!:
	jsr cpu_p2_arm_delay
	lda #3
	sta cpu_p2_avatar_state
	rts
!cpus1move:
	// Do a right-move
	lda #2
	sta cpu_p2_avatar_state
	rts
!cpus1go:
	rts
!cpus2:
	cmp #2
	bne !cpus3+
	// State 2: press right, then arm a delay. Inter-move gap uses the
	// full LFSR byte (1-255 frames, 17ms-4.25s) so consecutive moves
	// can happen quickly OR with a noticeable beat between them.
	jsr cpu_p2_delay_done
	beq cpu_p2_avatar_done          // delay not done — return
	jsr inc_player_2_avatar
	dec cpu_p2_avatar_moves
	jsr ra_random_byte
	bne !+
	lda #1
!:
	jsr cpu_p2_arm_delay
	lda #1
	sta cpu_p2_avatar_state
	rts
!cpus3:
	cmp #3
	bne cpu_p2_avatar_done
	// State 3: press fire (lock in the avatar)
	sfx_v2_play(SFX_GET_READY)
	lda cxn_avatar_selected
	ora #cxn_avatar_selected_p2
	sta cxn_avatar_selected
	jsr update_player_2_select_sprites
	lda #4
	sta cpu_p2_avatar_state
cpu_p2_avatar_done:
	rts

// Per-round CPU P2 state — call cpu_p2_buzz_reset at the start of each round
// (game_step_round_init) to set a new random buzz delay and clear latches.

cpu_p2_buzz_reset:
	// Pick a buzz delay in the range 60-220 frames (1-3.7s at 60Hz).
	// The round lasts ~5.3s (32 timer fires × 10-frame period). The
	// human typically answers well before 60 frames, so the CPU almost
	// always lags; on some picks the CPU beats the human and is then
	// shown correct/wrong when the round ends. The range gives obvious
	// "the CPU is thinking" beats while keeping the buzz within the
	// round.
	jsr ra_random_byte
	// Clamp into 60..220. The LFSR returns 1-255; we just push values
	// below 60 up to 60 and values above 220 down to 220.
	cmp #60
	bcs !clamp_hi+                  // ≥60 → check upper bound
	lda #60                          //  <60 → 60
	bcs !clamp_hi+                  // (always taken; use it to skip the
	                               //   upper-bound check since A=60 < 220)
!clamp_hi:
	cmp #220
	bcc !store+                     // <220 → keep
	lda #220
!store:
	sta cpu_p2_buzz_delay
	// arm the delay against the IRQ-driven frame counter
	clc
	lda cpu_p2_frame_count
	adc cpu_p2_buzz_delay
	sta cpu_p2_buzz_target
	lda #0
	sta cpu_p2_buzz_active
	rts

// Called from game_step_round on every frame. When the delay elapses
// the CPU buzzes in: 50% chance correct, 50% chance wrong.
cpu_p2_round_tick:
	// Latch — don't buzz twice
	lda cpu_p2_buzz_active
	bne cpu_p2_round_done
	// Has the armed delay elapsed?
	lda cpu_p2_frame_count
	cmp cpu_p2_buzz_target
	bne cpu_p2_round_done
	// Decide correct (bit 0 of LFSR = 50/50)
	jsr ra_random_byte
	and #%00000001
	bne !wrong+
	// Correct answer — MLHL_DATA_CORRECT holds an ASCII digit ('1'..'4');
	// player_2_buzzed_in needs a BUTTON_* constant for the round display
	// to print the right color/label.
	lda MLHL_DATA_CORRECT
	sec
	sbc #$30                        // '1'..'4' → 1..4
	tax
	lda button_answer_translator,x
	sta player_2_buzzed_in
	jmp !common+
!wrong:
	// Wrong answer — pick 1..4, skipping MLHL_DATA_CORRECT. The LFSR is
	// fast enough that re-rolling on collision is cheaper than a table.
!pick_wrong:
	jsr ra_random_byte
	and #%00000011
	clc
	adc #1
	cmp MLHL_DATA_CORRECT
	beq !pick_wrong-
	tax
	lda button_answer_translator,x
	sta player_2_buzzed_in
!common:
	lda #BUZZER_PLAYER_2
	jsr who_buzzed_in_first
	sfx_v2_play(SFX_DING)
	lda #1
	sta cpu_p2_buzz_active
cpu_p2_round_done:
	rts
// END 1-Player CPU player 2
////////////////////////////////////////////////////////////

init_timers_user_hook:
	rts

irq_timer_user_hook:

	inc cpu_p2_frame_count         // 8-bit free-running frame counter

	lda ml_hotload_active          // KERNAL LOAD in progress: skip sprite
	bne !+                         // ticking (sprites are hidden anyway)
	TickSpriteObj(yin_obj, yin_state)
	TickSpriteObj(player_1_obj, player_1_state)
	TickSpriteObj(player_2_obj, player_2_state)
!:
	rts

//////////////////////////////////////////////////////////////
// Question/answer fade-in. fade_qa_start blacks out the question and
// answer color RAM right after they're printed (the chars stay in screen
// RAM, invisible on the black background); fade_qa_tick — called every
// game_step_round pass — then steps one region at a time through
// dark grey / grey / light grey / white: question, then answers 1-4.

.macro FadeFill(addr, len) {
	ldx #len-1
!:	sta addr,x
	dex
	bpl !-
}

fade_qa_start:
	lda #TIMER_FADER_SPEED
	SetTimerTo(TIMER_FADER)
	FullReset(TIMER_FADER)
	lda #$00
	sta fade_step
	sta fade_region
	lda #BLACK
	FadeFill(FADE_Q_ROW_A, FADE_Q_LEN)
	FadeFill(FADE_Q_ROW_B, FADE_Q_LEN)
	FadeFill(FADE_ANS_1, FADE_ANS_LEN)
	FadeFill(FADE_ANS_2, FADE_ANS_LEN)
	FadeFill(FADE_ANS_3, FADE_ANS_LEN)
	FadeFill(FADE_ANS_4, FADE_ANS_LEN)
	rts

fade_qa_tick:
	lda fade_region
	cmp #$05
	bcc !+
	rts                     // sequence finished (or never started)
!:
	GetTimerTr(TIMER_FADER)
	bne !+
	rts                     // not time for the next shade yet
!:
	FullReset(TIMER_FADER)
	ldx fade_step
	lda fade_colors,x
	ldy fade_region
	bne !+
	FadeFill(FADE_Q_ROW_A, FADE_Q_LEN)  // region 0: both question rows
	FadeFill(FADE_Q_ROW_B, FADE_Q_LEN)
	jmp fqt_advance
!:	cpy #$01
	bne !+
	FadeFill(FADE_ANS_1, FADE_ANS_LEN)
	jmp fqt_advance
!:	cpy #$02
	bne !+
	FadeFill(FADE_ANS_2, FADE_ANS_LEN)
	jmp fqt_advance
!:	cpy #$03
	bne !+
	FadeFill(FADE_ANS_3, FADE_ANS_LEN)
	jmp fqt_advance
!:
	FadeFill(FADE_ANS_4, FADE_ANS_LEN)
fqt_advance:
	inc fade_step
	lda fade_step
	cmp #FADE_STEPS
	bcc !+
	lda #$00                // region fully white: move to the next one
	sta fade_step
	inc fade_region
!:
	rts