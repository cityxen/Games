#importonce
// ============================================================
// Software frame timers (Atari 800XL)
//
// 4 repeating timers (indices 0-3), see TIMER_* constants.
// Each decrements every VBL frame.  When it hits 0 it sets
// the fired flag and reloads from its reload value.
//
// VBL sync: poll RTCLOK2 ($0014) — incremented once per frame
// by the OS VBL handler (~60Hz NTSC / ~50Hz PAL).
//
// API (same as Apple IIe / C64 ports):
//   wait_vbl             -- spin until next VBL frame
//   update_timers        -- decrement timers; call after wait_vbl
//   SetTimerReload(n,v)  -- set reload value for timer n
//   ResetTimer(n)        -- reload timer n countdown
//   ResetTimerFired(n)   -- clear fired flag
//   GetTimerFired(n)     -- A = fired flag (0 = not fired)
//   GetTimer(n)          -- A = countdown value
//   tick_doodle_timer    -- decrement 16-bit doodle countdown
//   load_doodle_timer    -- reload 16-bit doodle timer
// ============================================================

.const TIMER_COUNT = 4

timer_reload: .byte 60, 120, 720, 80
timer_val:    .byte 60, 120, 720, 80
timer_fired:  .byte  0,   0,   0,  0

// ─── Macros ──────────────────────────────────────────────────

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

// ─── wait_vbl ────────────────────────────────────────────────
// Spins until RTCLOK2 ($0014) changes — once per VBL (~60Hz).
// Preserves X, Y.  Trashes A.
wait_vbl:
    lda RTCLOK2
wv_loop:
    cmp RTCLOK2
    beq wv_loop
    rts

// ─── update_timers ───────────────────────────────────────────
// Decrement all timer countdowns; set fired flags on expiry.
// Call once per frame, after wait_vbl.
update_timers:
    ldx #TIMER_COUNT - 1
ut_loop:
    lda timer_val,x
    beq ut_next
    dec timer_val,x
    bne ut_next
    inc timer_fired,x
    lda timer_reload,x
    sta timer_val,x
ut_next:
    dex
    bpl ut_loop
    rts

// ─── Doodle countdown (16-bit, in frames) ────────────────────
tick_doodle_timer:
    lda doodle_timer_lo
    bne tt_lo_nonzero
    lda doodle_timer_hi
    beq tt_expired
    dec doodle_timer_hi
tt_lo_nonzero:
    dec doodle_timer_lo
    lda doodle_timer_lo
    ora doodle_timer_hi
    rts
tt_expired:
    lda #0
    rts

load_doodle_timer:
    lda doodle_timer_set_lo
    sta doodle_timer_lo
    lda doodle_timer_set_hi
    sta doodle_timer_hi
    rts
