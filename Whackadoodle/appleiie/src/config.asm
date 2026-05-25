#importonce
// ============================================================
// Apple IIe Hardware Addresses
// ============================================================

// ─── Soft switches (read or write to toggle) ─────────────────
.const GFX_ON       = $C050   // graphics mode on
.const TXT_ON       = $C051   // text mode on
.const GFX_FULL     = $C052   // full-screen graphics (no text rows)
.const GFX_MIXED    = $C053   // mixed: HGR top 160px + 4 text rows
.const GFX_PAGE1    = $C054   // use HGR page 1
.const GFX_PAGE2    = $C055   // use HGR page 2
.const GFX_LORES    = $C056   // lo-res mode
.const GFX_HIRES    = $C057   // hi-res mode

// ─── Keyboard ────────────────────────────────────────────────
.const KBD          = $C000   // read: bit7=1 means key waiting, bits6-0 = ASCII
.const KBD_STROBE   = $C010   // write any value: clear key-ready flag

// ─── Speaker (click on each access) ─────────────────────────
.const SPEAKER      = $C030

// ─── VBL status ──────────────────────────────────────────────
.const VBL_STATUS   = $C019   // bit7=1 while in vertical blank

// ─── Joystick / PDL ──────────────────────────────────────────
// Write any value to $C070 to start paddle timer.
// Then read $C064/$C065 — bit7 stays SET while timer runs.
// Count the loops until bit7 clears; that count = PDL value (0-255).
.const PDL_STROBE   = $C070   // trigger: write any value
.const PDL0_CMP     = $C064   // PDL0 comparator output (bit 7)
.const PDL1_CMP     = $C065   // PDL1 comparator output (bit 7)
.const JOY_BTN0     = $C061   // Open Apple / joystick button 0  (bit 7 = pressed)
.const JOY_BTN1     = $C062   // Closed Apple / joystick button 1 (bit 7 = pressed)
.const JOY_BTN2     = $C063   // joystick button 2 (bit 7 = pressed)

// ─── HGR ─────────────────────────────────────────────────────
// HGR page 1: $2000-$3FFF (192 rows x 40 bytes = 7680 bytes)
// Row address formula:
//   hi = $20 + (row & 7)*4 + (row >> 6)
//   lo = ((row >> 3) & 7) * $28
// Use hgr_row_lo / hgr_row_hi tables in hgr.asm.
//
// Each byte = 7 pixels.  Bit 7 = palette select (0 or 1).
// Bit 0 = leftmost pixel, bit 6 = rightmost pixel of that byte.
// For white-on-black: use $7F (all 7 pixels lit, palette 0).
.const HGR_BASE_HI  = $20
.const HGR_BASE_LO  = $00

// ─── ROM entry points ─────────────────────────────────────────
// These live in the Apple IIe Autostart ROM.
.const ROM_COUT     = $FDED   // output char in A (set bit 7 for Apple II ASCII)
.const ROM_HOME     = $FC58   // clear text screen, move cursor to top-left
.const ROM_VTABZ    = $FC24   // set text cursor row from CV ($25)
.const ROM_CLREOL   = $FC9C   // clear from cursor to end of line

// ─── Zero page (Apple IIe user-available ZP) ─────────────────
// $06-$09 are safe to use; $FA-$FF are commonly available too.
// Check your DOS/ProDOS version — ProDOS uses some of $FA-$FF.
.const ZP_PTR_LO    = $06     // general-purpose 16-bit pointer lo
.const ZP_PTR_HI    = $07     //                              hi
.const ZP_TMP       = $08     // scratch byte
.const ZP_TMP2      = $09     // scratch byte 2

// Text screen cursor registers (ROM uses these)
.const CH           = $24     // current cursor column
.const CV           = $25     // current cursor row

// ============================================================
// Game Constants
// ============================================================

.const MODE_EASY    = $00   // 10 lives, only bad doodles, no speed-up
.const MODE_NORMAL  = $01   // 6 lives, speed ramps up
.const MODE_HARD    = $02   // 3 lives, full speed from start

// Initial doodle timer values in frames (~60 Hz)
.const DOODLE_SPEED_INITIAL = 175
.const DOODLE_SPEED_EASY    = 175
.const DOODLE_SPEED_HARD    = 48

// Software timer indices (see timers.asm)
.const TIMER_FLASH    = 0   // attract: random button flash period
.const TIMER_SCREEN   = 1   // attract: page-rotate period
.const TIMER_GAMEOVER = 2   // game-over: auto-return timeout
.const TIMER_MESSAGE  = 3   // in-game: message display duration

// did_hit values (mirrors C64 original)
.const HIT_TIMEOUT    = 0
.const HIT_POW        = 1
.const HIT_WRONG_DOOD = 2
.const HIT_WRONG_BTN  = 3

// ─── Doodle sprite screen positions ──────────────────────────
// Column = HGR byte column (0-39, each byte = 7 pixels)
// Row    = HGR row (0-159 for mixed-mode HGR portion)
// Doodle sprite is drawn 16 rows ABOVE the button centre row.
// Adjust these to match wherever the user draws the buttons.
// Sprites are 4 HGR bytes wide (28 px) × 21 rows tall.
// Five slots spaced 7 bytes apart: sprites at 1-4, 8-11, 15-18, 22-25, 29-32
// leaving ~3 byte gaps and centering across the 40-byte screen.
.const BUTT0_COL    = 1    // Red    button area
.const BUTT0_ROW    = 70   //
.const BUTT1_COL    = 8    // Green  button area
.const BUTT1_ROW    = 28   //
.const BUTT2_COL    = 15   // Yellow button area
.const BUTT2_ROW    = 70   //
.const BUTT3_COL    = 22   // Blue   button area
.const BUTT3_ROW    = 28   //
.const BUTT4_COL    = 29   // White  button area
.const BUTT4_ROW    = 70   //

// ============================================================
// Game Variables
// ============================================================

whack_mode:          .byte 0    // MODE_EASY / NORMAL / HARD
button_to_hit:       .byte 0    // doodle's slot (0-4)
button_actually_hit: .byte $FF  // player's slot ($FF = none yet)
doodle:              .byte 0    // current doodle index (0-7)
did_hit:             .byte 0    // outcome flag
message:             .byte 0    // 0=none 1=getready 2=miss 3=pow 4=wrong
last_slot:           .byte $FF  // previous button slot (avoid repeats)

whack_life:          .byte 0
score:               .byte 0

initial_life:        .byte 6
initial_life_hard:   .byte 3
initial_life_easy:   .byte 10

screen_draw:         .byte 0    // attract: which page to show

// Doodle countdown timer (frames remaining; 16-bit for up to 65535)
doodle_timer_lo:     .byte 0
doodle_timer_hi:     .byte 0
doodle_timer_set_lo: .byte 0    // reload value lo
doodle_timer_set_hi: .byte 0    // reload value hi

// Joystick state (filled each frame by joystick.asm)
joy_slot:            .byte 0    // PDL0 -> slot 0-4
joy_fired:           .byte 0    // 1 = fire button newly pressed this frame
joy_prev_btn:        .byte 0    // previous fire button state (for edge detect)

// Active doodle sprite position (set by game_setup_doodle)
doodle_col:          .byte 0    // HGR column byte
doodle_row:          .byte 0    // HGR row
