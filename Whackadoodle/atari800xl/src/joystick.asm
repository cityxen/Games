#importonce
// ============================================================
// Joystick input (Atari 800XL)
//
// Reads STICK0 (OS shadow $0278) for direction → joy_slot (0-4)
// Reads STRIG0 (OS shadow $0284) with edge-detect → joy_fired
//
// STICK0 bits (0 = pressed):
//   bit 0 = up    bit 1 = down    bit 2 = left    bit 3 = right
//   Neutral: $0F (all bits set)
//
// Slot mapping (mirrors Apple IIe PDL 5-zone split):
//   Left + Down  → slot 0   (full left)
//   Left only    → slot 1
//   Neutral/Up   → slot 2   (center)
//   Right only   → slot 3
//   Right + Down → slot 4   (full right)
//
// For difficulty selection in attract mode:
//   slots 0-1 = EASY,  slot 2 = NORMAL,  slots 3-4 = HARD
//
// STRIG0: 0 = pressed, 1 = not pressed.
// Edge-detect via joy_prev_btn: joy_fired=1 only on the frame
// the button first goes down.
//
// Call read_joystick once per frame (after wait_vbl).
// ============================================================

read_joystick:

    // ── Direction → joy_slot ─────────────────────────────────
    lda STICK0
    and #$04             // test left bit (0 = pressed)
    bne rj_not_left
    // Left is pressed
    lda STICK0
    and #$02             // test down bit (0 = pressed)
    bne rj_slot1         // left only → slot 1
    lda #0               // left + down → slot 0
    sta joy_slot
    jmp rj_check_fire
rj_slot1:
    lda #1
    sta joy_slot
    jmp rj_check_fire

rj_not_left:
    lda STICK0
    and #$08             // test right bit (0 = pressed)
    bne rj_center
    // Right is pressed
    lda STICK0
    and #$02             // test down bit
    bne rj_slot3         // right only → slot 3
    lda #4               // right + down → slot 4
    sta joy_slot
    jmp rj_check_fire
rj_slot3:
    lda #3
    sta joy_slot
    jmp rj_check_fire

rj_center:
    lda #2               // neutral or up → slot 2
    sta joy_slot

    // ── STRIG0 edge-detect → joy_fired ───────────────────────
rj_check_fire:
    lda #0
    sta joy_fired
    lda STRIG0           // 0 = pressed, 1 = not pressed
    bne rj_btn_not_pressed
    // Button IS pressed
    lda joy_prev_btn
    bne rj_btn_held      // was already held → not a new press
    // New press this frame
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
