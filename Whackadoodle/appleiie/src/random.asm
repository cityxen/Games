#importonce
// ============================================================
// Pseudo-random number generator
// 16-bit Galois LFSR, maximal-length (65535 period).
// Call get_random -> A = next 8-bit pseudo-random value.
//
// The LFSR is advanced a full 8 steps per call so each returned
// byte is independent of the previous one.  A single step only
// shifts in one new bit, which left consecutive results bit-shifted
// copies of each other -- callers taking the low bits of two
// successive results (e.g. slot then doodle) got correlated values.
// ============================================================

rnd_lo: .byte $37
rnd_hi: .byte $A5

get_random:
    ldx #8
gr_step:
    lda rnd_lo
    lsr
    rol rnd_hi
    bcc gr_no_fb
    eor #$B4        // feedback polynomial taps
gr_no_fb:
    sta rnd_lo
    dex
    bne gr_step
    lda rnd_hi
    rts
