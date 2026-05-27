#importonce
// ============================================================
// Random number generator (Atari 800XL)
//
// The Atari's POKEY chip provides a hardware random number
// generator at $D20A (RANDOM register).  Each read returns
// a new pseudo-random byte — no software LFSR needed.
//
// get_random -> A = 8-bit random value (0-255).
// ============================================================

get_random:
    lda RANDOM   // POKEY hardware RNG ($D20A); changes each read
    rts
