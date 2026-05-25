#importonce
// ─── DebugHex(xpos, ypos) ─────────────────────────────────────
// Print the accumulator as a 2-digit hex string at text col/row.
// In mixed HGR mode only rows 20-23 are visible at the bottom.
//
// Usage:
//   lda some_value
//   DebugHex(0, 20)     // prints "XX" at col 0, row 20
//
// Trashes A, X.  Does NOT preserve the accumulator.
// ──────────────────────────────────────────────────────────────

.macro PrintHex(xpos, ypos) {
    pha
    lda #ypos
    sta CV
    jsr ROM_VTABZ
    lda #xpos
    sta CH
    pla
    jsr print_hex_a
}

// print_hex_a ─────────────────────────────────────────────────
// Print A as two hex digits at the current cursor position.
// Trashes A, X.
print_hex_a:
    tax                     // save original value
    lsr
    lsr
    lsr
    lsr                     // isolate high nibble
    jsr dh_nibble
    txa                     // restore original
    and #$0F                // isolate low nibble
    // fall through to dh_nibble

dh_nibble:
    // Convert nibble (0-15) in A to Apple II ASCII and print it.
    // After cmp #10: carry set if A >= 10, clear if A < 10.
    cmp #10
    bcc dh_digit
    adc #$B6                // A>=10, carry=1: A + $B7 → $C1='A' .. $C6='F'
    jmp ROM_COUT            // tail-call; COUT's RTS returns to our caller
dh_digit:
    adc #$B0                // A<10, carry=0: A + $B0 → $B0='0' .. $B9='9'
    jmp ROM_COUT
