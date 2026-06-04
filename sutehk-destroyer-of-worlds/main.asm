//////////////////////////////////////////////////////////////////////////////////////
// SUTEHK: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//
// Dependencies:
// The include folder from: https://github.com/cityxen/Commodore64_Programming/
// must be in KickAssembler path (see KickAss_AutoGen.cfg / build.bat)
//////////////////////////////////////////////////////////////////////////////////////

#import "Constants.asm"
#import "Macros.asm"

.segment Sprites [allowOverlap]
*=$3000 "SPRITES"
#import "sutehk-sprites.asm"

//////////////////////////////////////////////////////////////////////////////////////
// File stuff
.file [name="sutehk.prg", segments="Program,Sprites,Levels"]
.disk [filename="sutehk.d64", name="CITYXEN", id="2026!" ] {
	[name="sutehk", type="prg",  segments="Program,Sprites,Levels"],
    [name="--------------------",type="del"],
}

.segment Program [allowOverlap]

*=$0801
CityXenUpstart(start)

start:
    lda #BLACK
    sta BACKGROUND_COLOR
    sta BORDER_COLOR

    // Init timers: (t1=10, t2=20, t3=30, t4=60, t5=120, t6=4[TIMER_INPUT], t7=50[TIMER_BAT])
    InitTimers(10, 20, 30, 60, 120, 4, 50)

    jmp mainmenu

// Library files first — defines all macros and .const values used by game code
#import "sys.il.asm"
#import "print.il.asm"

#import "timers.il.asm"
#import "input.il.asm"

// vars.asm second — defines LEVEL_W/H, OBJ_*, TILE_* and other game constants
#import "vars.asm"

// Game code last — all constants are now resolved

#import "mainmenu.asm"
#import "gameon.asm"
#import "draw_screens.asm"
#import "init_sprites.asm"
#import "animation.asm"

.segment Levels [allowOverlap]
*=$4200 "LEVELS"
#import "room-layout.asm"