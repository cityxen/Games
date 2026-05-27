//////////////////////////////////////////////////////////////////////////////////////
// ROGUE ENGINE 64 - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//
// Prototype roguelike dungeon crawler.
// Procedurally generated floors, bump combat, items, multiple enemy types.
//
// Dependencies:
// The include folder from: https://github.com/cityxen/Commodore64_Programming/
// must be in KickAssembler path (see KickAss_AutoGen.cfg / build.bat)
//////////////////////////////////////////////////////////////////////////////////////

#import "Constants.asm"
#import "Macros.asm"

.file [name="rogue-engine-64.prg", segments="Program"]

.segment Program [allowOverlap]

*=$0801
CityXenUpstart(start)

start:
    lda #BLACK
    sta BACKGROUND_COLOR
    sta BORDER_COLOR

    // Init timers: t1=10 t2=20 t3=30 t4=60 t5=120 t6=15(TIMER_INPUT) t7=50
    InitTimers(10, 20, 30, 60, 120, 15, 50)

    jsr random_init_sid

    jmp mainmenu

// Library inline modules — must come before game code that uses their routines
#import "sys.il.asm"
#import "print.il.asm"
#import "timers.il.asm"
#import "input.il.asm"
#import "random.il.asm"

// Game modules — vars first so constants are defined for dungeon/gameon
#import "vars.asm"
#import "mainmenu.asm"
#import "dungeon.asm"
#import "gameon.asm"
