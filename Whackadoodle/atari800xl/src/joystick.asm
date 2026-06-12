#importonce
// ============================================================
// Joystick input (Atari 800XL)
//
// Reads STICK0 (OS shadow $0278) directions and STRIG0 ($0284)
// fire as five distinct "colored buttons", one per doodle slot:
//
//   left  → slot 0   RED
//   up    → slot 1   GREEN
//   down  → slot 2   YELLOW
//   right → slot 3   BLUE
//   fire  → slot 4   WHITE
//
// STICK0 bits (0 = pressed):
//   bit 0 = up    bit 1 = down    bit 2 = left    bit 3 = right
//   Neutral: $0F (all bits set).  STRIG0: 0 = pressed.
//
// joy_slot  = the pressed button's slot (held from last press while
//             nothing is down, so attract-mode difficulty persists).
// joy_fired = 1 only on the frame a button first goes down (edge),
//             via joy_prev_btn.  Any of the five buttons counts.
//
// Call read_joystick once per frame (after wait_vbl).
// ============================================================

read_joystick:

    // ── Which button is pressed? (priority: L,U,D,R,fire) ────
    lda STICK0
    and #$04             // left
    bne rj_not_left
    lda #0
    sta joy_slot
    jmp rj_pressed
rj_not_left:
    lda STICK0
    and #$01             // up
    bne rj_not_up
    lda #1
    sta joy_slot
    jmp rj_pressed
rj_not_up:
    lda STICK0
    and #$02             // down
    bne rj_not_down
    lda #2
    sta joy_slot
    jmp rj_pressed
rj_not_down:
    lda STICK0
    and #$08             // right
    bne rj_not_right
    lda #3
    sta joy_slot
    jmp rj_pressed
rj_not_right:
    lda STRIG0           // fire (0 = pressed)
    bne rj_none
    lda #4
    sta joy_slot
    jmp rj_pressed

    // ── No button down: clear edge state, keep last joy_slot ──
rj_none:
    lda #0
    sta joy_fired
    sta joy_prev_btn
    rts

    // ── A button is down: edge-detect into joy_fired ─────────
rj_pressed:
    lda joy_prev_btn
    bne rj_held          // already held → not a new press
    lda #1
    sta joy_fired
    sta joy_prev_btn
    rts
rj_held:
    lda #0
    sta joy_fired
    rts
