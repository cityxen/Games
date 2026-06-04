// ============================================================
// WHACKADOODLE for Apple IIe
// Ported from C64 version by Deadline / CityXen 2024
// 
// Special thanks:
// 
//  - AHCS Club members for their apple tech support and feedback during development, especially:
//    - Kyle R. for donating an Apple IIe and providing invaluable feedback during development!
//    - Josh (Mr. TechGadget) for his help with Apple IIe i/o hardware cards
//    - Grizzle (David) for creating the relay board interface for the Apple IIe game port
// 
// In order to compile this, you will need KickAssembler, and the
// retro-dev-tools repository:
// https://github.com/cityxen/retro-dev-tools
// You will need to put the tools in cityxen-tools folder in your PATH
// You will need to put the retro-dev-tools\include\appleiie folder
//        in your KickAssembler include path
//
// Target: Apple IIe (65C02), KickAssembler 5.x
// Load at $6000 via:  BRUN WAD_A2  (DOS 3.3)
//                     BLOAD WAD_A2,A$6000 : CALL 24576  (ProDOS)
//
// Loads at $6000 (above HGR pages 1 $2000-$3FFF and 2 $4000-$5FFF,
// below DOS at $9600) so the program never collides with HGR memory.
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
* = $6000 "PROGRAM"

start:
    jmp initialize

#import "config.asm"
#import "debug.asm"
#import "timers.asm"
#import "random.asm"
#import "hgr.asm"
#import "joystick.asm"
#import "score.asm"
#import "initialize.asm"
#import "messages.asm"
#import "doodles.asm"
#import "sprites.asm"
#import "draw_screens.asm"
#import "util.asm"
#import "main_loop.asm"
#import "game_loop.asm"
#import "game_over_loop.asm"
