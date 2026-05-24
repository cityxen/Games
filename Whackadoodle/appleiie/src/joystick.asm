#importonce
// ============================================================
// Joystick / Paddle input
//
// Reads PDL0 (X axis) -> joy_slot (0-4)
// Reads Button 0 (Open Apple) with edge-detect -> joy_fired
//
// PDL reading: write any value to PDL_STROBE ($C070), then
// count loops until PDL0_CMP ($C064) bit 7 goes LOW.
// Count range: 0 (full left) to ~255 (full right) on a
// standard Apple joystick (5.6 kΩ to 150 kΩ).
//
// Call read_joystick once per frame (after wait_vbl).
// Results are in joy_slot and joy_fired.
// ============================================================

// ─── read_joystick ────────────────────────────────────────────
// Reads PDL0 and button 0; updates joy_slot and joy_fired.
// Trashes A, X.
read_joystick:

    // ── PDL0 → joy_slot ──────────────────────────────────────
    sta PDL_STROBE          // any write starts timer (A doesn't matter)
    ldx #0
rj_pdl:
    bit PDL0_CMP            // bit 7: 1 = timer still running
    bpl rj_pdl_done         // bit 7 cleared = timer expired
    inx
    bne rj_pdl              // X wraps at 256 (full-right or disconnected)
rj_pdl_done:
    // X is now 0-255 representing joystick position.
    // Map to slot 0-4: divide by 51 (256/5 ≈ 51).
    // Thresholds: 0-50=slot0, 51-101=slot1, 102-152=slot2,
    //             153-203=slot3, 204-255=slot4.
    lda #4
    cpx #204
    bcs rj_slot_done
    lda #3
    cpx #153
    bcs rj_slot_done
    lda #2
    cpx #102
    bcs rj_slot_done
    lda #1
    cpx #51
    bcs rj_slot_done
    lda #0
rj_slot_done:
    sta joy_slot

    // ── Button 0 edge-detect → joy_fired ─────────────────────
    lda #0
    sta joy_fired
    bit JOY_BTN0            // N flag = bit 7 of $C061
    bpl rj_btn_not_pressed  // bit 7 clear = button not pressed
    // button IS pressed
    lda joy_prev_btn
    bne rj_btn_held         // was already held = not a new press
    // new press this frame
    lda #1
    sta joy_fired
    lda #1
    sta joy_prev_btn
    rts
rj_btn_held:
    rts
rj_btn_not_pressed:
    lda #0
    sta joy_prev_btn
    rts
