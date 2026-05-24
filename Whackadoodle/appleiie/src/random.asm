#importonce
// ============================================================
// Pseudo-random number generator
// 16-bit Galois LFSR, maximal-length (65535 period).
// Call get_random -> A = next 8-bit pseudo-random value.
// ============================================================

rnd_lo: .byte $37
rnd_hi: .byte $A5

get_random:
    lda rnd_lo
    lsr
    rol rnd_hi
    bcc gr_no_fb
    eor #$B4        // feedback polynomial taps
gr_no_fb:
    sta rnd_lo
    lda rnd_hi
    rts
