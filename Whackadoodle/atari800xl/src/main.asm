// ============================================================
// WHACKADOODLE for Atari 800XL
// Ported from C64 version by Deadline / CityXen 2026
//
// Target: Atari 800XL (6502, NTSC), KickAssembler 5.x
// Load via XEX at $2000.  Run address = $2000.
//
// Display:
//   ANTIC mixed-mode display list:
//     - 160 scan lines of GR.8 (320x160 monochrome bitmap) at $4000
//     - 4 rows of GR.0 text (40 columns) at $5900 for HUD
//
// Input:    STICK0 (OS shadow $0278) for direction / slot select
//           STRIG0 (OS shadow $0284) for fire button
//
// Sound:    POKEY channels 1–4 (AUDF/AUDC registers)
//
// Random:   POKEY hardware RANDOM register ($D20A)
//
// Timing:   VBL sync via RTCLOK+2 ($0014) polling
//
// Note: KickAss outputs a 2-byte load-address prefix in main.prg.
//       kick2xex.py strips it and wraps the binary as XEX.
// ============================================================

.file [name="wadatari.prg", segments="Program"]

.segment Program [allowOverlap]
* = $2000 "Program"

start:
    jmp initialize

#import "system.asm"
#import "config.asm"
#import "timers.il.asm"
#import "random.asm"
#import "gfx.asm"
#import "sprites.asm"
#import "joystick.asm"
#import "score.asm"
#import "initialize.asm"
#import "messages.asm"
#import "doodles.asm"
#import "util.asm"
#import "draw_screens.asm"
#import "main_loop.asm"
#import "game_loop.asm"
#import "game_over_loop.asm"
