

// ─── Attract screen string data ───────────────────────────────

ml_s_title:    applestr("    WHACKADOODLE! (APPLE//e VERSION)")
ml_s_credit:   applestr("         DEADLINE/CITYXEN 2026")
ml_s_cxn_itch: applestr("        HTTPS://CITYXEN.ITCH.IO")

ml_s_line:     applestr("========================================")
ml_s_howto:    applestr("            HOW TO PLAY")
ml_s_aim1:     applestr("     A doodle pops up randomly ")
ml_s_aim2:     applestr("   at one of the 5 button slots.")


ml_s_scoring:  applestr("            SCORING")
ml_s_bad:      applestr("  Hit a BAD doodle  = +1 score")
ml_s_good:     applestr("  Hit a GOOD doodle = -1 score -1 life")
ml_s_wrong:    applestr("  Wrong slot        = -1 life")

ml_s_diff:     applestr("          DIFFICULTY")
ml_s_deasy:    applestr("  Left   = EASY   (10 lives, slow)")
ml_s_dnormal:  applestr("  Center = NORMAL  (6 lives)")
ml_s_dhard:    applestr("  Right  = HARD    (3 lives, fast)")


ml_s_modepfx:  applestr("  MODE: ")
ml_s_fire:     applestr("         >> FIRE TO START <<")
ml_s_measy:    applestr("EASY    ")
ml_s_mnormal:  applestr("NORMAL  ")
ml_s_mhard:    applestr("HARD    ")



// ─── Text screen row address tables (page 1, 40-column) ───────
// Apple IIe text layout is non-linear.  Indexed 0-23.

txt_row_lo:
    .byte <$0400, <$0480, <$0500, <$0580, <$0600, <$0680, <$0700, <$0780
    .byte <$0428, <$04A8, <$0528, <$05A8, <$0628, <$06A8, <$0728, <$07A8
    .byte <$0450, <$04D0, <$0550, <$05D0, <$0650, <$06D0, <$0750, <$07D0

txt_row_hi:
    .byte >$0400, >$0480, >$0500, >$0580, >$0600, >$0680, >$0700, >$0780
    .byte >$0428, >$04A8, >$0528, >$05A8, >$0628, >$06A8, >$0728, >$07A8
    .byte >$0450, >$04D0, >$0550, >$05D0, >$0650, >$06D0, >$0750, >$07D0

// ─── ml_draw_mode_txt ─────────────────────────────────────────
// Write "  MODE: XXXX" to text row 22.  Called every frame.
ml_draw_mode_txt:
    PrintLine(ml_s_modepfx, 22, 0)
    lda whack_mode
    cmp #MODE_EASY
    beq mmt_easy
    cmp #MODE_HARD
    beq mmt_hard
mmt_normal:
    PrintLine(ml_s_mnormal, 22, 8)
    rts
mmt_easy:
    PrintLine(ml_s_measy, 22, 8)
    rts
mmt_hard:
    PrintLine(ml_s_mhard, 22, 8)
    rts

// ─── ml_draw_attract ──────────────────────────────────────────
// Draw static content on rows 0-21 and 23.
draw_screen_main:
    // Switch to full 40x24 text mode and clear screen
    //bit TXT_ON
    //jsr ROM_HOME
        // Switch back to HGR mixed mode (attract screen uses full text mode)
    jsr hgr_init
    jsr hgr_clear
    jsr clear_message_row
    //jsr draw_score_line

    ldx #$06
!:
    stx $ff
    jsr random_slot

    jsr gsd_doodle_loop_rand
    lda doodle
       
    jsr set_sprite_ptr
    lda doodle
    jsr set_draw_place
    jsr draw_doodle_sprite
    ldx $ff
    dex
    bne !-


    


    PrintLine(ml_s_title,    20, 0)
    PrintLine(ml_s_credit,   21, 0)
    PrintLine(ml_s_cxn_itch, 22, 0)

    rts

draw_screen_instruct:
    // Switch to full 40x24 text mode and clear screen
    bit TXT_ON
    jsr ROM_HOME

    PrintLine(ml_s_title,    1, 0)

    PrintLine(ml_s_howto,    3, 0)
    PrintLine(ml_s_line,     4, 0)
    PrintLine(ml_s_aim1,     5, 0)
    PrintLine(ml_s_aim2,     6, 0)

    PrintLine(ml_s_scoring,  8, 0)
    PrintLine(ml_s_line,     9, 0)
    PrintLine(ml_s_bad,      10, 0)
    PrintLine(ml_s_good,     11, 0)
    PrintLine(ml_s_wrong,    12, 0)

    PrintLine(ml_s_diff,    14, 0)
    PrintLine(ml_s_line,    15, 0)
    PrintLine(ml_s_deasy,   16, 0)
    PrintLine(ml_s_dnormal, 17, 0)
    PrintLine(ml_s_dhard,   18, 0)


    PrintLine(ml_s_fire,    20, 0)
    rts