#importonce
// ============================================================
// Doodle selection, timer, and sprite positioning
// Mirrors C64 doodles.asm / game_setup_doodle logic.
//
// button_to_hit: which of 5 slots the doodle appears on (0-4)
// doodle:        which doodle graphic (0-7)
// doodle_col/row: HGR position set before draw_doodle_sprite
// ============================================================

// HGR column/row per slot (5 button positions)
// Edit these to match the user's button layout on the HGR screen.
slot_col: .byte BUTT0_COL, BUTT1_COL, BUTT2_COL, BUTT3_COL, BUTT4_COL
slot_row: .byte BUTT0_ROW, BUTT1_ROW, BUTT2_ROW, BUTT3_ROW, BUTT4_ROW

// ─── set_doodle_speed ────────────────────────────────────────
// Set doodle_timer_set based on mode/score, then reload timer.
// Mirrors the speed-ramp logic from C64 doodles.asm.
set_doodle_speed:
    // Easy and hard handlers are inline at the top so beq can reach them
    lda whack_mode
    cmp #MODE_EASY
    bne sds_try_hard
sds_easy:
    lda #<DOODLE_SPEED_EASY
    sta doodle_timer_set_lo
    lda #>DOODLE_SPEED_EASY
    sta doodle_timer_set_hi
    jmp sds_reload
sds_try_hard:
    cmp #MODE_HARD
    bne sds_normal
sds_hard:
    lda #<DOODLE_SPEED_HARD
    sta doodle_timer_set_lo
    lda #>DOODLE_SPEED_HARD
    sta doodle_timer_set_hi
    jmp sds_reload
sds_normal:

    // NORMAL: dispatch high-to-low so each bcc is a short forward skip.
    // Each handler is placed immediately after its check.
    // All "we're done" paths use jmp sds_reload (absolute, no range limit).
    // Only short local branches remain within each block.
    lda score
    cmp #99
    bcc sds_check_80        // short: skip to next check

    // score >= 99: decrement by 1, floor 20
    lda doodle_timer_set_lo
    sec
    sbc #1
    bcc sds_set_f20
    sta doodle_timer_set_lo
    lda doodle_timer_set_hi
    sbc #0
    sta doodle_timer_set_hi
    lda doodle_timer_set_hi
    bne sds_f20_ok
    lda doodle_timer_set_lo
    cmp #20
    bcs sds_f20_ok
sds_set_f20:
    lda #20
    sta doodle_timer_set_lo
    lda #0
    sta doodle_timer_set_hi
sds_f20_ok:
    jmp sds_reload

sds_check_80:
    cmp #80
    bcc sds_check_40        // short: skip to next check

    // score 80-98: decrement by 1, floor 30
    lda doodle_timer_set_lo
    sec
    sbc #1
    bcc sds_set_f30
    sta doodle_timer_set_lo
    lda doodle_timer_set_hi
    sbc #0
    sta doodle_timer_set_hi
    lda doodle_timer_set_hi
    bne sds_f30_ok
    lda doodle_timer_set_lo
    cmp #30
    bcs sds_f30_ok
sds_set_f30:
    lda #30
    sta doodle_timer_set_lo
    lda #0
    sta doodle_timer_set_hi
sds_f30_ok:
    jmp sds_reload

sds_check_40:
    cmp #40
    bcc sds_score_039       // short: skip to 0-39 handler

    // score 40-79: decrement by 1, floor 40
    lda doodle_timer_set_lo
    sec
    sbc #1
    bcc sds_set_f40
    sta doodle_timer_set_lo
    lda doodle_timer_set_hi
    sbc #0
    sta doodle_timer_set_hi
    lda doodle_timer_set_hi
    bne sds_f40_ok
    lda doodle_timer_set_lo
    cmp #40
    bcs sds_f40_ok
sds_set_f40:
    lda #40
    sta doodle_timer_set_lo
    lda #0
    sta doodle_timer_set_hi
sds_f40_ok:
    jmp sds_reload

sds_score_039:
    // score 0-39: decrement by 5, floor 50
    lda doodle_timer_set_lo
    sec
    sbc #5
    bcc sds_set_f50
    sta doodle_timer_set_lo
    lda doodle_timer_set_hi
    sbc #0
    sta doodle_timer_set_hi
    lda doodle_timer_set_hi
    bne sds_reload          // hi nonzero = value is large, no clamp needed
    lda doodle_timer_set_lo
    cmp #50
    bcs sds_reload          // still >= 50, no clamp needed
sds_set_f50:
    lda #50
    sta doodle_timer_set_lo
    lda #0
    sta doodle_timer_set_hi
    // fall through
sds_reload:
    jsr load_doodle_timer
    rts

// ─── game_setup_doodle ────────────────────────────────────────
// Choose new slot + doodle, position sprite, update speed.
// Mirrors C64 game_setup_doodle.
game_setup_doodle:

    // Erase old doodle from HGR
    jsr erase_doodle_sprite

    // Handle did_hit == 0 (timeout): if bad doodle, lose a life
    lda did_hit
    bne gsd_pick_slot       // nonzero = was hit (any kind)
    lda doodle
    cmp #4
    bcc gsd_pick_slot       // doodle < 4 = good, no penalty on timeout
    // Bad doodle timed out -> MISS
    dec whack_life
    lda #2
    jsr set_message
    jsr beep

gsd_pick_slot:
    // Random slot, not same as last
    lda last_slot
gsd_slot_loop:
    jsr get_random
    and #%00000111
    cmp #5
    bcs gsd_slot_loop       // reject >= 5
    cmp last_slot
    beq gsd_slot_loop       // reject repeat
    sta button_to_hit
    sta last_slot

    // Set doodle position from slot table
    tax
    lda slot_col,x
    sta doodle_col
    lda slot_row,x
    sta doodle_row

    // Random doodle index
    lda whack_mode
    cmp #MODE_EASY
    beq gsd_easy_doodle
gsd_doodle_loop:
    jsr get_random
    and #%00001111
    cmp #8
    bcs gsd_doodle_loop
    sta doodle
    jmp gsd_draw
gsd_easy_doodle:
    // Easy mode: only doodles 3-6 (star/RAD/skull/poo)
    jsr get_random
    and #%00000011
    adc #3
    sta doodle

gsd_draw:
    // Point sprite ptr and draw
    lda doodle
    jsr set_sprite_ptr
    jsr draw_doodle_sprite

    // Update speed and reset doodle timer
    jsr set_doodle_speed

    // Reset did_hit
    lda #0
    sta did_hit

    // Reset button_actually_hit
    lda #$FF
    sta button_actually_hit

    rts
