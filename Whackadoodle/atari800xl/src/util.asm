#importonce
// ============================================================
// Utility routines and string helpers (Atari 800XL)
// ============================================================

// ─── ataristr macro ──────────────────────────────────────────
// Emit a $FF-terminated Atari screen-code string from a literal.
// Screen code = ATASCII char - $20  (works for $20-$5F range).
// NOTE: $FF is the null terminator, NOT $00, because screen code
//       0 = space and would wrongly terminate a string early.
.macro ataristr(s) {
    .for (var i = 0; i < s.size(); i++) {
        .byte s.charAt(i) - $20
    }
    .byte $FF
}

// ─── PrintLine macro ─────────────────────────────────────────
// Load ZP_PTR with str address, then JSR print_at.
// row = text row 0-3,  col = column 0-39.
.macro PrintLine(str, row, col) {
    lda #<str
    sta ZP_PTR_LO
    lda #>str
    sta ZP_PTR_HI
    ldx #row
    lda #col
    jsr print_at
}

// ─── print_at ────────────────────────────────────────────────
// Write a null-terminated Atari screen-code string to a text row.
// In:  X  = row (0-3)
//      A  = starting column (0-39)
//      ZP_PTR_LO/HI = pointer to string
// ZP_TMP ($82/$83) used as destination pointer (clobbered).
// ZP_TMP3 ($84) saves column (clobbered).
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
    cmp #$FF            // $FF = null terminator (not $00 — space = screen code 0)
    beq pa_done
    sta (ZP_TMP),y
    iny
    bne pa_loop
pa_done:
    rts

// ─── randomly_flash_buttons ──────────────────────────────────
// On real hardware this would control external button LEDs.
// No-op in the emulator / software-only port.
randomly_flash_buttons:
    rts
