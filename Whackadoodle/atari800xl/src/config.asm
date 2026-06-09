#importonce
// ============================================================
// Atari 800XL Hardware Addresses and Game Configuration
// ============================================================

// ─── GTIA ────────────────────────────────────────────────────
.const HPOSP0   = $D000
.const HPOSP1   = $D001
.const HPOSP2   = $D002
.const HPOSP3   = $D003
.const COLPF1   = $D017   // GR.8 foreground luminance
.const COLPF2   = $D018   // GR.8 bitmap background color
.const COLBK    = $D01A   // border color
.const CONSOL   = $D01F   // console keys / speaker (write)
.const TRIG0    = $D010   // joystick 1 fire (read; bit0=0 when pressed)

// ─── POKEY ───────────────────────────────────────────────────
.const AUDF1    = $D200
.const AUDC1    = $D201
.const AUDF2    = $D202
.const AUDC2    = $D203
.const AUDF3    = $D204
.const AUDC3    = $D205
.const AUDF4    = $D206
.const AUDC4    = $D207
.const AUDCTL   = $D208
.const RANDOM   = $D20A   // hardware RNG (read)

// ─── ANTIC ───────────────────────────────────────────────────
.const WSYNC    = $D40A   // write: halt CPU until next HSYNC

// ─── OS Shadows ──────────────────────────────────────────────
.const SDMCTL   = $022F   // shadow of DMACTL
.const SDLSTL   = $0230   // display list pointer lo
.const SDLSTH   = $0231   // display list pointer hi
.const COLOR1   = $02C5   // shadow of COLPF1 (GR.8 foreground luminance)
.const COLOR2   = $02C6   // shadow of COLPF2 (GR.8 bitmap background)
.const COLOR4   = $02C8   // shadow of COLBK  (border)
.const RTCLOK2  = $0014   // real-time clock LSB (increments each VBL)

// ─── OS Joystick Shadows ─────────────────────────────────────
// STICK0 bits: 3=right, 2=left, 1=down, 0=up  (0 = pressed)
.const STICK0   = $0278
.const STRIG0   = $0284   // fire button (0=pressed, 1=not pressed)

// ─── Zero Page ───────────────────────────────────────────────
// OS uses $00-$7F; user-safe area is $80-$FF.
.const ZP_PTR_LO  = $80
.const ZP_PTR_HI  = $81
.const ZP_TMP     = $82
.const ZP_TMP2    = $83
.const ZP_TMP3    = $84
.const ZP_SPR_LO  = $85
.const ZP_SPR_HI  = $86

// ─── GFX / Text Memory ───────────────────────────────────────
// GR.8 bitmap: 160 rows × 40 bytes = 6400 bytes  ($4000-$58FF)
// Text screen:   4 rows × 40 bytes = 160 bytes   ($5900-$599F)
.const GFX_BASE          = $4000
.const GFX_BYTES_PER_ROW = 40
.const GFX_ROWS          = 160

.const TXT_SCREEN = $5900
.const TXT_LINE0  = TXT_SCREEN        // SCORE / LIVES / MODE
.const TXT_LINE1  = TXT_SCREEN + 40   // in-game message
.const TXT_LINE2  = TXT_SCREEN + 80   // (spare)
.const TXT_LINE3  = TXT_SCREEN + 120  // attract: FIRE TO START

// ─── Game Constants ──────────────────────────────────────────
.const MODE_EASY    = $00
.const MODE_NORMAL  = $01
.const MODE_HARD    = $02

// Doodle on-screen time, in frames (~60/sec). Higher = slower.
.const DOODLE_SPEED_INITIAL = 300   // NORMAL start (~5s)
.const DOODLE_SPEED_EASY    = 320   // EASY (~5.3s)
.const DOODLE_SPEED_HARD    = 120   // HARD (~2s)

// Software timer indices
.const TIMER_FLASH    = 0   // attract: button flash period
.const TIMER_SCREEN   = 1   // attract: page-rotate period
.const TIMER_GAMEOVER = 2   // game-over: auto-return timeout
.const TIMER_MESSAGE  = 3   // in-game: message display duration

// did_hit outcome values (mirrors C64/Apple IIe original)
.const HIT_TIMEOUT    = 0
.const HIT_POW        = 1
.const HIT_WRONG_DOOD = 2
.const HIT_WRONG_BTN  = 3

// ─── Doodle sprite screen positions ──────────────────────────
// col = byte offset within a 40-byte GFX row (0-37 for 3-byte sprite)
// row = GFX scan line (0-159)
// Five slots, alternating top/bottom to mirror C64 button layout.
.const BUTT0_COL    = 1    // slot 0 (leftmost)
.const BUTT0_ROW    = 70
.const BUTT1_COL    = 9    // slot 1
.const BUTT1_ROW    = 28
.const BUTT2_COL    = 17   // slot 2 (center)
.const BUTT2_ROW    = 70
.const BUTT3_COL    = 25   // slot 3
.const BUTT3_ROW    = 28
.const BUTT4_COL    = 33   // slot 4 (rightmost)
.const BUTT4_ROW    = 70

// ─── Game Variables ──────────────────────────────────────────
whack_mode:          .byte 0
button_to_hit:       .byte 0
button_actually_hit: .byte $FF
doodle:              .byte 0
did_hit:             .byte 0
message:             .byte 0
last_slot:           .byte $FF

whack_life:          .byte 0
score:               .byte 0

initial_life:        .byte 6
initial_life_hard:   .byte 3
initial_life_easy:   .byte 10

screen_draw:         .byte 0   // attract: which page to show

doodle_timer_lo:     .byte 0
doodle_timer_hi:     .byte 0
doodle_timer_set_lo: .byte 0
doodle_timer_set_hi: .byte 0

// Joystick state (filled each frame by joystick.asm)
joy_slot:            .byte 0   // selected slot 0-4
joy_fired:           .byte 0   // 1 = fire button newly pressed this frame
joy_prev_btn:        .byte 0   // previous trigger state for edge-detect

// Active doodle position (set by game_setup_doodle)
doodle_col:          .byte 0   // GFX column byte offset (0-39)
doodle_row:          .byte 0   // GFX row (0-159)
