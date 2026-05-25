#importonce
// ============================================================
// Software frame timers  (replaces CityXen library timers)
//
// 4 repeating timers (indices 0-3), see TIMER_* constants.
// Each decrements every VBL frame.  When it reaches 0 it sets
// the fired flag and reloads from its reload value.
//
// API:
//   update_timers        -- call once per VBL in main loop
//   wait_vbl             -- spin until VBL, then return
//   SetTimerReload(n,v)  -- set reload value for timer n to literal v
//   ResetTimer(n)        -- reload timer n countdown from its reload value
//   ResetTimerFired(n)   -- clear fired flag for timer n
//   GetTimerFired(n)     -- load fired flag into A (0=not fired)
//   load_doodle_timer    -- copy doodle_timer_set into doodle_timer
// ============================================================

// --- Timer storage -------------------------------------------

.const TIMER_COUNT = 4

timer_reload: .byte 60, 120, 720, 80   // default reload values (frames)
timer_val:    .byte 60, 120, 720, 80   // current countdown
timer_fired:  .byte  0,   0,   0,  0   // nonzero = fired this reload

// --- Macros --------------------------------------------------

.macro SetTimerReload(n, v) {
    lda #[v]
    sta timer_reload + [n]
}

.macro ResetTimer(n) {
    lda timer_reload + [n]
    sta timer_val + [n]
}

.macro ResetTimerFired(n) {
    lda #$00
    sta timer_fired + [n]
}

.macro GetTimer(n) {
    lda timer_val + [n]
}

.macro GetTimerFired(n) {
    lda timer_fired + [n]
}

// --- wait_vbl ------------------------------------------------
// Waits for the start of the next vertical blank (~60 Hz NTSC).
// Preserves X, Y.  Trashes A.
wait_vbl:
    bit VBL_STATUS      // bit 7 = 1 while in VBL
    bmi wait_vbl        // wait until we are OUT of VBL
wv_in:
    bit VBL_STATUS
    bpl wv_in           // wait until we are IN VBL
    rts

// --- update_timers -------------------------------------------
// Decrement all timer countdowns; set fired flags on expiry.
// Call once per frame AFTER wait_vbl.
update_timers:
    ldx #TIMER_COUNT - 1
ut_loop:
    lda timer_val,x
    beq ut_next         // already at 0 (shouldn't normally happen)
    dec timer_val,x
    bne ut_next
    // Countdown just hit 0 -- fire and reload
    inc timer_fired,x
    lda timer_reload,x
    sta timer_val,x
ut_next:
    dex
    bpl ut_loop
    rts

// --- Doodle countdown (16-bit, in frames) --------------------
// Separate from the 4 general timers; managed by doodles.asm.

// tick_doodle_timer: decrement 16-bit doodle countdown.
// Returns A = (lo | hi) after decrement; A=0 means expired.
tick_doodle_timer:
    lda doodle_timer_lo
    bne tt_lo_nonzero
    lda doodle_timer_hi
    beq tt_expired          // both 0 already
    dec doodle_timer_hi
tt_lo_nonzero:
    dec doodle_timer_lo
    lda doodle_timer_lo
    ora doodle_timer_hi
    rts
tt_expired:
    lda #0
    rts

// load_doodle_timer: reload doodle_timer from doodle_timer_set_lo/hi
load_doodle_timer:
    lda doodle_timer_set_lo
    sta doodle_timer_lo
    lda doodle_timer_set_hi
    sta doodle_timer_hi
    rts
