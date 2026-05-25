
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


randomly_flash_buttons:
    rts