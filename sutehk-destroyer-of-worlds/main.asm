//////////////////////////////////////////////////////////////////////////////////////
// SUTEKH: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//
// Dependencies:
// The include folder from: https://github.com/cityxen/Commodore64_Programming/
// must be in KickAssembler path (see KickAss_AutoGen.cfg / build.bat)
//////////////////////////////////////////////////////////////////////////////////////

#import "Constants.asm"
#import "Macros.asm"

*=$0801
CityXenUpstart(start)

start:
    lda #BLACK
    sta BACKGROUND_COLOR
    sta BORDER_COLOR

    // Init timers: (t1=10, t2=20, t3=30, t4=60, t5=120, t6=15[TIMER_INPUT], t7=50)
    InitTimers(10, 20, 30, 60, 120, 15, 50)

    jmp mainmenu

// Library files first — defines all macros and .const values used by game code
#import "sys.il.asm"
#import "print.il.asm"

#import "timers.il.asm"
#import "input.il.asm"

// vars.asm second — defines LEVEL_W/H, OBJ_*, TILE_* and other game constants
#import "vars.asm"

// Game code last — all constants are now resolved
#import "room-layout.asm"
#import "mainmenu.asm"
#import "gameon.asm"
