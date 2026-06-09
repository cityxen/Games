//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS  —  Sweet Deliveries of Justice
// By Deadline / CityXen 2026
// https://cityxen.itch.io   https://youtube.com/@CityXen
//
// A one-screen arcade catcher for the Commodore 64.  Fly a winged unicorn, catch the
// goodies raining from the sky, deliver them to the Treats For Good People Center,
// rescue kittens, dodge the bad stuff, and unleash the occasional RAINBOW BARF.
//
// Built on the CityXen Commodore 64 library (retro-dev-tools/include/commodore64):
//   Constants.asm / Macros.asm  — registers, ClearScreen, PrintXY, CityXenUpstart
//   sys.il.asm                  — wait_vbl
//   random.il.asm               — SID-noise RNG
//   print/print.asm             — PrintXY / Print
//
// Dependency: that include dir must be on KickAssembler's -libdir (KickAss_AutoGen.cfg).
//////////////////////////////////////////////////////////////////////////////////////

#import "Constants.asm"
#import "Macros.asm"

//////////////////////////////////////////////////////////////////////////////////////
// Sprite art — unicorn (4 dirs x 2 frames), items, the center, sparkle.  At $3000.
.segment Sprites [allowOverlap]
*=$3000 "SPRITES"
#import "sprites.asm"

//////////////////////////////////////////////////////////////////////////////////////
// Output file
.file [name="unikit.prg", segments="Program,Sprites"]

//////////////////////////////////////////////////////////////////////////////////////
// Program — library inline code + game code, all from $0801
.segment Program [allowOverlap]
*=$0801
CityXenUpstart(start)

start:
unicorn_kittens_entry:
    jmp initialize

//////////////////////////////////////////////////////////////////////////////////////
// Library inline subroutines
#import "sys.il.asm"            // wait_vbl, SaveRegs/LoadRegs
#import "random.il.asm"         // random_init_sid / lda_random_sid
#import "print/print.asm"       // PrintXY / Print

//////////////////////////////////////////////////////////////////////////////////////
// Game modules
#import "config.asm"            // constants, tables, strings (read-only)
#import "vars.asm"              // mutable runtime state
#import "initialize.asm"        // hardware setup -> title
#import "main_loop.asm"         // title screen
#import "game_loop.asm"         // new game + per-frame loop + level flow
#import "unicorn.asm"           // player movement, flap animation, sprite update
#import "items.asm"             // falling items: spawn / fall / catch / draw
#import "barf.asm"              // the RAINBOW BARF gimmick
#import "hud.asm"               // right-hand HUD + number printing
#import "interlevel.asm"        // between-level kitten tally
#import "draw_screens.asm"      // title / game-over screens
#import "util.asm"              // rng + put_str helpers
