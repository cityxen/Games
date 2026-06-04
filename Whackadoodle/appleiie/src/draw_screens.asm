


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

    jsr draw_buttons

    // Overlay a doodle on each button (OR-blit keeps the circle showing around it)
    OverlayDoodle(spr_happyface, BUTTON_RED)    // happyface on orange
    OverlayDoodle(spr_yin_yang, BUTTON_GREEN)    // yin-yang  on green
    OverlayDoodle(spr_heart, BUTTON_PURPLE)    // heart     on purple
    OverlayDoodle(spr_star, BUTTON_BLUE)    // star      on blue
    OverlayDoodle(spr_skull, BUTTON_WHITE)    // skull     on white

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

draw_screen_play:
    jsr draw_buttons
    rts

draw_buttons:
    // Showcase row of big circles, one per HGR color (even cols = correct chroma)
    DrawBigCircle(big_circle_orange, BUTTON_RED)
    DrawBigCircle(big_circle_green,  BUTTON_GREEN)
    DrawBigCircle(big_circle_purple, BUTTON_PURPLE)
    DrawBigCircle(big_circle_blue,   BUTTON_BLUE)
    DrawBigCircle(big_circle_white,  BUTTON_WHITE)

    rts



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