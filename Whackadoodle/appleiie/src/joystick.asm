#importonce
// ============================================================
// Joystick / Paddle input
//
// Reads the two analog axes (PDL0 = horizontal, PDL1 = vertical)
// and the fire button, and maps them to one of the 5 game slots:
//
//   LEFT  -> RED    (slot 0)      RIGHT -> BLUE   (slot 3)
//   UP    -> GREEN  (slot 1)      FIRE  -> WHITE  (slot 4)
//   DOWN  -> PURPLE (slot 2)
//
// PDL reading: write any value to PDL_STROBE ($C070), then count
// loops until the comparator bit 7 goes LOW.  0 = full left/up,
// ~255 = full right/down.  A wide centre dead zone (PDL_LO..PDL_HI)
// means the stick must be pushed clearly to register a direction.
//
// Outputs (call once per frame after wait_vbl):
//   joy_slot  = slot of the active input (sticky if neutral)
//   joy_fired = 1 on the rising edge of ANY input  (the whack trigger)
//   joy_btn   = 1 on the rising edge of the FIRE button only
//
// Horizontal has priority over vertical; a pushed direction has
// priority over the fire button for slot selection.
// ============================================================

.const PDL_LO = 64      // below this on an axis = left / up
.const PDL_HI = 192     // at/above this on an axis = right / down

// ─── read_joystick ────────────────────────────────────────────
// Trashes A, X, Y.
read_joystick:
    ldy #$FF                // Y = chosen slot; $FF = none yet

    // ── PDL0 (horizontal) -> left / right ────────────────────
    sta PDL_STROBE          // any write starts the timers
    ldx #0
rj_p0:
    bit PDL0_CMP
    bpl rj_p0_done          // bit 7 cleared = timer expired
    inx
    bne rj_p0
    ldx #$FF                // counter wrapped -> saturate at max (right)
rj_p0_done:
    cpx #PDL_LO
    bcc rj_left
    cpx #PDL_HI
    bcs rj_right
    jmp rj_vert             // horizontal centred -> check vertical
rj_left:
    ldy #BUTTON_RED
    jmp rj_btn              // horizontal wins -> skip vertical
rj_right:
    ldy #BUTTON_BLUE
    jmp rj_btn

    // ── PDL1 (vertical) -> up / down ─────────────────────────
rj_vert:
    sta PDL_STROBE
    ldx #0
rj_p1:
    bit PDL1_CMP
    bpl rj_p1_done
    inx
    bne rj_p1
    ldx #$FF                // counter wrapped -> saturate at max (down)
rj_p1_done:
    cpx #PDL_LO
    bcc rj_up
    cpx #PDL_HI
    bcs rj_down
    jmp rj_btn              // vertical centred too
rj_up:
    ldy #BUTTON_GREEN
    jmp rj_btn
rj_down:
    ldy #BUTTON_PURPLE

    // ── Fire button (button 0) ───────────────────────────────
rj_btn:
    lda #0
    sta joy_btn
    bit JOY_BTN0            // N flag = bit 7 of $C061
    bpl rj_btn_up           // bit 7 clear = button not pressed
    // button IS pressed
    cpy #$FF
    bne rj_btn_edge         // a direction already claimed the slot
    ldy #BUTTON_WHITE       // no direction -> fire selects WHITE
rj_btn_edge:
    lda joy_prev_btn
    bne rj_btn_held         // was already held = not a new press
    lda #1
    sta joy_btn             // new fire-button press this frame
rj_btn_held:
    lda #1
    sta joy_prev_btn
    jmp rj_resolve
rj_btn_up:
    lda #0
    sta joy_prev_btn

    // ── Resolve joy_slot + joy_fired (rising edge of any input) ─
rj_resolve:
    cpy #$FF
    beq rj_none             // no input active this frame
    sty joy_slot
    lda #0
    sta joy_fired
    lda joy_prev_input
    bne rj_input_held       // input already active last frame
    lda #1
    sta joy_fired           // new press
rj_input_held:
    lda #1
    sta joy_prev_input
    rts
rj_none:
    lda #0
    sta joy_fired
    sta joy_prev_input
    rts
