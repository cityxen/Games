// ============================================================
// Attract screen string data and draw routines (Atari 800XL)
//
// Text rows are 40 columns in ANTIC mode 2 (mixed-mode display).
// Only 4 text rows are visible; the GFX play area shows doodles.
//
// Attract mode:
//   - GFX area: random doodle sprites (same as gameplay)
//   - TXT rows 0-2: title / credits / URL
//   - TXT row 3: >> FIRE TO START <<
//
// Instruction screen (draw_screen_instruct):
//   Uses same 4 text rows, cycled via TIMER_SCREEN.
//   Limited to 4 lines; game rules are summarised.
// ============================================================

// ─── Attract screen strings (Atari screen codes, null-terminated) ─

ml_s_title:    ataristr("   WHACKADOODLE! (ATARI 800XL)")
ml_s_credit:   ataristr("      DEADLINE/CITYXEN 2026")
ml_s_cxn_itch: ataristr("    HTTPS://CITYXEN.ITCH.IO")

ml_s_fire:     ataristr(" >>  FIRE TO START  <<")
ml_s_deasy:    ataristr("LEFT=EASY  CTR=NORMAL  RGT=HARD")

ml_s_scoring:  ataristr("HIT BAD=+1  HIT GOOD=-1  MISS=-LIFE")
ml_s_modepfx:  ataristr("MODE: ")
ml_s_measy:    ataristr("EASY    ")
ml_s_mnormal:  ataristr("NORMAL  ")
ml_s_mhard:    ataristr("HARD    ")

// ─── ml_draw_mode_txt ────────────────────────────────────────
// Write "MODE: XXXX" to TXT_LINE2.  Called in attract loop.
ml_draw_mode_txt:
    PrintLine(ml_s_modepfx, 2, 0)
    lda whack_mode
    cmp #MODE_EASY
    beq mmt_easy
    cmp #MODE_HARD
    beq mmt_hard
mmt_normal:
    PrintLine(ml_s_mnormal, 2, 6)
    rts
mmt_easy:
    PrintLine(ml_s_measy, 2, 6)
    rts
mmt_hard:
    PrintLine(ml_s_mhard, 2, 6)
    rts

// ─── draw_screen_main ────────────────────────────────────────
// Attract main page: doodles in GFX area, title + credits below.
draw_screen_main:
    jsr gfx_clear
    jsr txt_clear

    // Draw random doodles into the GFX play area
    ldx #$06
!:
    stx ZP_TMP3
    jsr random_slot            // sets button_to_hit (0-4)
    jsr gsd_doodle_loop_rand   // sets doodle (0-7)
    lda doodle
    jsr set_sprite_ptr         // ZP_PTR → sprite data for this doodle
    jsr set_draw_place         // uses button_to_hit → doodle_col/row
    jsr draw_doodle_sprite
    ldx ZP_TMP3
    dex
    bne !-

    PrintLine(ml_s_title,    0, 0)
    PrintLine(ml_s_credit,   1, 0)
    PrintLine(ml_s_cxn_itch, 2, 0)
    PrintLine(ml_s_fire,     3, 0)
    rts

// ─── draw_screen_instruct ────────────────────────────────────
// Instruction page: scoring rules in 4 text rows.
draw_screen_instruct:
    jsr txt_clear

    PrintLine(ml_s_title,   0, 0)
    PrintLine(ml_s_deasy,   1, 0)
    PrintLine(ml_s_scoring, 2, 0)
    PrintLine(ml_s_fire,    3, 0)
    rts

// ─── inc_screen_draw ─────────────────────────────────────────
inc_screen_draw:
    inc screen_draw
    lda screen_draw
    cmp #$02
    bne !+
    lda #$00
    sta screen_draw
!:
    rts
