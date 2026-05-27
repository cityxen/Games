#importonce
// ============================================================
// Doodle selection, timer, and sprite positioning
// Mirrors C64 doodles.asm / game_setup_doodle logic.
//
// button_to_hit: which of 5 slots the doodle appears on (0-4)
// doodle:        which doodle graphic (0-7)
// doodle_col/row: GFX position set before draw_doodle_sprite
// ============================================================

// GFX column byte offset and row per slot (5 button positions)
slot_col: .byte BUTT0_COL, BUTT1_COL, BUTT2_COL, BUTT3_COL, BUTT4_COL
slot_row: .byte BUTT0_ROW, BUTT1_ROW, BUTT2_ROW, BUTT3_ROW, BUTT4_ROW

// ─── set_doodle_speed ────────────────────────────────────────
// Set doodle_timer_set based on mode/score, then reload timer.
// Mirrors C64 / Apple IIe speed-ramp logic exactly.
set_doodle_speed:
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

    lda score
    cmp #99
    bcc sds_check_80

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
    bcc sds_check_40

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
    bcc sds_score_039

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
    lda doodle_timer_set_lo
    sec
    sbc #5
    bcc sds_set_f50
    sta doodle_timer_set_lo
    lda doodle_timer_set_hi
    sbc #0
    sta doodle_timer_set_hi
    lda doodle_timer_set_hi
    bne sds_reload
    lda doodle_timer_set_lo
    cmp #50
    bcs sds_reload
sds_set_f50:
    lda #50
    sta doodle_timer_set_lo
    lda #0
    sta doodle_timer_set_hi
sds_reload:
    jsr load_doodle_timer
    rts

// ─── game_setup_doodle ───────────────────────────────────────
// Choose new slot + doodle, position sprite, update speed.
// Mirrors C64 / Apple IIe game_setup_doodle.
game_setup_doodle:

    jsr erase_doodle_sprite

    lda did_hit
    bne gsd_pick_slot
    lda doodle
    cmp #4
    bcc gsd_pick_slot
    dec whack_life
    lda #2
    jsr set_message
    jsr beep

    jsr random_slot

    jsr set_draw_place

    lda whack_mode
    cmp #MODE_EASY
    beq gsd_easy_doodle

    jsr gsd_doodle_loop_rand

    jmp gsd_draw
gsd_easy_doodle:
    jsr get_random
    and #%00000011
    clc
    adc #3
    sta doodle

gsd_draw:
    lda doodle
    jsr set_sprite_ptr
    jsr draw_doodle_sprite

    jsr set_doodle_speed

    lda #0
    sta did_hit

    lda #$FF
    sta button_actually_hit

    rts

gsd_doodle_loop_rand:
    jsr get_random
    and #%00001111
    cmp #8
    bcs gsd_doodle_loop_rand
    sta doodle
    rts

random_slot:
gsd_pick_slot:
gsd_slot_loop:
    jsr get_random
    and #%00000111
    cmp #5
    bcs gsd_slot_loop
    cmp last_slot
    beq gsd_slot_loop
    sta button_to_hit
    sta last_slot
    rts

set_draw_place:
    // A = slot index; set doodle_col/doodle_row from tables
    // (called after button_to_hit is set, so we use that)
    lda button_to_hit
    tax
    lda slot_col,x
    sta doodle_col
    lda slot_row,x
    sta doodle_row
    rts
