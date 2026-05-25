// ============================================================
// WHACKADOODLE for Apple IIe
// Ported from C64 version by Deadline / CityXen 2024
//
// Target: Apple IIe (65C02), KickAssembler 5.x
// Load at $0800 via:  BRUN WAD_A2  (DOS 3.3)
//                     BLOAD WAD_A2,A$800 : CALL 2048  (ProDOS)
//
// Note: KickAss outputs a 2-byte load-address prefix.
//       Strip it (see Build.bat) before loading on real hardware.
//
// What this port does:
//   - HGR mixed-mode display (160 px HGR + 4 text rows for score)
//   - 5 doodle positions matching C64 button layout
//   - 8x7 pixel doodle sprites drawn in HGR
//   - Joystick PDL0 -> slot selection (0-4), Button0 -> fire
//   - Software frame timers synced to VBL (~60 Hz NTSC)
//   - Button I/O (flashing lights) is handled externally by user
// ============================================================

.file [name="wad_a2.prg", segments="Program"]

.segment Program [allowOverlap]
* = $0800 "PROGRAM"

start:
    jmp initialize

#import "config.asm"
#import "debug.asm"
#import "timers.asm"
#import "random.asm"
#import "draw_screens.asm"
#import "hgr.asm"
#import "joystick.asm"
#import "score.asm"
#import "sprites.asm"
#import "initialize.asm"
#import "messages.asm"
#import "doodles.asm"
#import "util.asm"
#import "main_loop.asm"
#import "game_loop.asm"
#import "game_over_loop.asm"
