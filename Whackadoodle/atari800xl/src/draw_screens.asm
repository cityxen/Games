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

ml_s_title:    ataristr("     WHACKADOODLE! (ATARI 800XL)")
ml_s_credit:   ataristr("        DEADLINE/CITYXEN 2026")
ml_s_cxn_itch: ataristr("       HTTPS://CITYXEN.ITCH.IO")

ml_s_fire:     ataristr("      -=*>  FIRE TO START  <*=-")
ml_s_deasy:    ataristr("LEFT=EASY  DOWN=NORMAL  RIGHT=HARD")

ml_s_scoring:  ataristr("HIT BAD=+1  HIT GOOD=-1  MISS=-LIFE")
ml_s_ddl_fctn: ataristr("  GOOD DOODLES          BAD DOODLES")
ml_s_modepfx:  ataristr("MODE: ")
ml_s_measy:    ataristr("EASY    ")
ml_s_mnormal:  ataristr("NORMAL  ")
ml_s_mhard:    ataristr("HARD    ")

// ─── In-depth instruction strings (text-only page) ───────────
ml_i_title:    ataristr("       WHACKADOODLE - HOW TO PLAY")
ml_i_goal:     ataristr("WHACK THE BAD DOODLES - SPARE THE GOOD")
ml_i_btnhdr:   ataristr("BUTTONS  (JOYSTICK PORT 1):")
ml_i_btn1:     ataristr("  LEFT = RED       UP   = GREEN")
ml_i_btn2:     ataristr("  RIGHT= BLUE      DOWN = YELLOW")
ml_i_btn3:     ataristr("  FIRE = WHITE")
ml_i_how1:     ataristr("A DOODLE POPS UP ON A COLORED CIRCLE.")
ml_i_how2:     ataristr("HIT THE MATCHING COLOR BUTTON.")
ml_i_badhdr:   ataristr("BAD DOODLES: SKULL POO FROWN RAD")
ml_i_bad1:     ataristr("  HIT IT FAST   = +1 POINT")
ml_i_bad2:     ataristr("  LET IT ESCAPE = LOSE A LIFE")
ml_i_goodhdr:  ataristr("GOOD DOODLES: FACE YIN HEART STAR")
ml_i_good1:    ataristr("  NEVER HIT!    = -1 AND A LIFE")
ml_i_wrong:    ataristr("WRONG BUTTON    = LOSE A LIFE")
ml_i_score:    ataristr("SCORE TO 99. FASTER AS YOU CLIMB.")
ml_i_diff:     ataristr("EASY: BAD ONLY   NORMAL   HARD: FAST")

// ─── ml_draw_mode_txt ────────────────────────────────────────
// Write "MODE: XXXX" to TXT_LINE2.  Called in attract loop.
ml_draw_mode_txt:
    PrintLine(ml_s_modepfx, 3, 0)
    lda whack_mode
    cmp #MODE_EASY
    beq mmt_easy
    cmp #MODE_HARD
    beq mmt_hard
mmt_normal:
    PrintLine(ml_s_mnormal, 3, 6)
    rts
mmt_easy:
    PrintLine(ml_s_measy, 3, 6)
    rts
mmt_hard:
    PrintLine(ml_s_mhard, 3, 6)
    rts

// ─── draw_screen_main ────────────────────────────────────────
// Attract main page: doodles in GFX area, title + credits below.
draw_screen_main:
    jsr set_gfx_dl             // back to the mixed mode-E + text display list
    jsr screen_clear           // clear GFX bitmap + text rows
    jsr draw_circles           // 5 colored P/M button circles, one per slot

    // One random doodle centred on each of the 5 button circles.
    // Loop counter on the stack: draw_doodle_sprite clobbers ZP_TMP*.
    ldx #0
!:
    txa
    pha
    stx button_to_hit          // slot 0-4
    jsr gsd_doodle_loop_rand   // sets doodle (0-7)
    lda doodle
    jsr set_sprite_ptr         // ZP_PTR → sprite data for this doodle
    jsr set_draw_place         // uses button_to_hit → doodle_col/row
    jsr draw_doodle_sprite
    pla
    tax
    inx
    cpx #6
    bne !-

    PrintLine(ml_s_title,    0, 0)
    PrintLine(ml_s_credit,   1, 0)
    PrintLine(ml_s_cxn_itch, 2, 0)
    // PrintLine(ml_s_fire,     3, 0)
    rts

// ─── draw_screen_instruct ────────────────────────────────────
// Full-screen TEXT-ONLY instruction page. Unlike the other attract
// screens it swaps in text_display_list (24 rows of mode 2 text, no
// GFX bitmap) so it can show the rules in depth. clear_circles hides
// the P/M circles; the DL is switched LAST, after the buffer is filled.
draw_screen_instruct:
    jsr clear_circles          // hide P/M circles (not used on text page)
    jsr txt_clear_full         // clear all 24 text rows

    PrintLine(ml_i_title,   0, 0)
    PrintLine(ml_i_goal,    2, 0)
    PrintLine(ml_i_btnhdr,  4, 0)
    PrintLine(ml_i_btn1,    5, 0)
    PrintLine(ml_i_btn2,    6, 0)
    PrintLine(ml_i_btn3,    7, 0)
    PrintLine(ml_i_how1,    9, 0)
    PrintLine(ml_i_how2,   10, 0)
    PrintLine(ml_i_badhdr, 12, 0)
    PrintLine(ml_i_bad1,   13, 0)
    PrintLine(ml_i_bad2,   14, 0)
    PrintLine(ml_i_goodhdr,16, 0)
    PrintLine(ml_i_good1,  17, 0)
    PrintLine(ml_i_wrong,  19, 0)
    PrintLine(ml_i_score,  20, 0)
    PrintLine(ml_i_diff,   22, 0)
    PrintLine(ml_s_fire,   23, 0)

    jsr set_text_dl            // activate the 24-row text display list
    rts

// ─── draw_screen_instruct2 ───────────────────────────────────
// Graphical "good vs bad doodles" page: good doodles (0-3) on the
// left, bad doodles (4-7) on the right.  Mirrors the Apple IIe.
draw_screen_instruct2:
    jsr set_gfx_dl             // back to the mixed mode-E + text display list
    jsr screen_clear           // clear GFX bitmap + text rows
    jsr clear_circles          // hide button circles on the doodle chart

    DrawDoodleAt(0,  4, 35)    // good: happyface
    DrawDoodleAt(1, 12, 35)    // good: yin-yang
    DrawDoodleAt(2,  4, 80)    // good: heart
    DrawDoodleAt(3, 12, 80)    // good: star
    DrawDoodleAt(4, 24, 35)    // bad: rad
    DrawDoodleAt(5, 32, 35)    // bad: skull
    DrawDoodleAt(6, 24, 80)    // bad: poo
    DrawDoodleAt(7, 32, 80)    // bad: frown

    PrintLine(ml_s_ddl_fctn, 0, 0)
    PrintLine(ml_s_fire,     3, 0)
    rts

// ─── inc_screen_draw ─────────────────────────────────────────
inc_screen_draw:
    inc screen_draw
    lda screen_draw
    cmp #$03
    bne !+
    lda #$00
    sta screen_draw
!:
    rts
