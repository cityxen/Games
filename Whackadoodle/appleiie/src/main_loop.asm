#importonce
// ============================================================
// Main / attract loop
//
// Switches to full 40x24 text mode and shows a complete
// title + instruction screen.  Joystick selects difficulty;
// FIRE starts the game.
// ============================================================

// ─── KickAssembler helper: emit null-terminated Apple-ASCII string ─
// Each character has bit 7 set (normal white-on-black display).
.macro applestr(s) {
    .for (var i = 0; i < s.size(); i++) {
        .byte s.charAt(i) | $80
    }
    .byte 0
}

// ─── KickAssembler helper: load ZP_PTR and call print_at ──────
.macro PrintLine(str, row, col) {
    lda #<str
    sta ZP_PTR_LO
    lda #>str
    sta ZP_PTR_HI
    ldx #row
    lda #col
    jsr print_at
}

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

// ─── print_at ─────────────────────────────────────────────────
// Write a null-terminated Apple-ASCII string to the text screen.
// In:  X  = row (0-23)
//      A  = starting column (0-39)
//      ZP_PTR_LO/HI = pointer to string
// ZP_TMP ($08) / ZP_TMP2 ($09) used as destination ptr (clobbered).
// ZP_TMP3 ($0A) used to save column (clobbered).
// Y = string/column offset; starts at 0 (clobbered).
print_at:
    sta ZP_TMP3
    lda txt_row_lo,x
    clc
    adc ZP_TMP3
    sta ZP_TMP
    lda txt_row_hi,x
    adc #0
    sta ZP_TMP2
    ldy #0
pa_loop:
    lda (ZP_PTR_LO),y
    beq pa_done
    sta (ZP_TMP),y
    iny
    bne pa_loop
pa_done:
    rts

// ─── Attract screen string data ───────────────────────────────

ml_s_title:    applestr("      WHACKADOODLE!")
ml_s_credit:   applestr("       CITYXEN 2024")

ml_s_howto:    applestr("  HOW TO PLAY")
ml_s_aim1:     applestr("  A doodle pops up at one of the")
ml_s_aim2:     applestr("  5 button slots.")
ml_s_aim3:     applestr("  Aim the joystick at that slot")
ml_s_aim4:     applestr("  and press FIRE to hit it.")

ml_s_scoring:  applestr("  SCORING")
ml_s_bad:      applestr("  Hit a BAD doodle  = +1 scr")
ml_s_good:     applestr("  Hit a GOOD doodle = -1 scr -1 life")
ml_s_wrong:    applestr("  Wrong slot        = -1 life")

ml_s_diff:     applestr("  DIFFICULTY (move joystick)")
ml_s_deasy:    applestr("  Left   = EASY   (10 lives, slow)")
ml_s_dnormal:  applestr("  Center = NORMAL  (6 lives)")
ml_s_dhard:    applestr("  Right  = HARD    (3 lives, fast)")

ml_s_choose:   applestr("  Aim stick to choose mode,")
ml_s_choose2:  applestr("  then FIRE to start!")

ml_s_modepfx:  applestr("  MODE: ")
ml_s_fire:     applestr("  >> FIRE TO START <<")
ml_s_measy:    applestr("EASY    ")
ml_s_mnormal:  applestr("NORMAL  ")
ml_s_mhard:    applestr("HARD    ")

// ─── ml_draw_attract ──────────────────────────────────────────
// Draw static content on rows 0-21 and 23.
// Text screen must have been cleared by ROM_HOME before calling.
ml_draw_attract:
    PrintLine(ml_s_title,    0, 0)
    PrintLine(ml_s_credit,   1, 0)

    PrintLine(ml_s_howto,    3, 0)
    PrintLine(ml_s_aim1,     4, 0)
    PrintLine(ml_s_aim2,     5, 0)
    PrintLine(ml_s_aim3,     6, 0)
    PrintLine(ml_s_aim4,     7, 0)

    PrintLine(ml_s_scoring,  9, 0)
    PrintLine(ml_s_bad,     10, 0)
    PrintLine(ml_s_good,    11, 0)
    PrintLine(ml_s_wrong,   12, 0)

    PrintLine(ml_s_diff,    14, 0)
    PrintLine(ml_s_deasy,   15, 0)
    PrintLine(ml_s_dnormal, 16, 0)
    PrintLine(ml_s_dhard,   17, 0)

    PrintLine(ml_s_choose,  19, 0)
    PrintLine(ml_s_choose2, 20, 0)

    PrintLine(ml_s_fire,    23, 0)
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

// ─── main_loop_start ─────────────────────────────────────────

main_loop_start:
restart:

    // Switch to full 40x24 text mode and clear screen
    bit TXT_ON
    jsr ROM_HOME

    // Reset attract flash timer (drives external LED hardware)
    ResetTimerFired(TIMER_FLASH)
    ResetTimer(TIMER_FLASH)

    jsr ml_draw_attract

main_loop:

    jsr wait_vbl
    jsr update_timers
    jsr read_joystick

    // Mode selection: left (0-1)=EASY, center (2)=NORMAL, right (3-4)=HARD
    lda joy_slot
    cmp #2
    bcc ml_select_easy
    beq ml_select_normal
    lda #MODE_HARD
    sta whack_mode
    jmp ml_show_mode
ml_select_easy:
    lda #MODE_EASY
    sta whack_mode
    jmp ml_show_mode
ml_select_normal:
    lda #MODE_NORMAL
    sta whack_mode

ml_show_mode:
    jsr ml_draw_mode_txt

    lda joy_fired
    beq main_loop

    jmp game_start
