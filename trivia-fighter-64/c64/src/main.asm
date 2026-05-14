//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////////////////////////////////////////////////////

#import "Constants.asm"
#import "Macros.asm"

.segment Offline [allowOverlap]
*=$6b00
#import "offline_trivia.asm"

.segment Sprites [allowOverlap]
*=$3000 "SPRITES"
#import "data/trivia-fighters-64-sprites.asm"

.segment Screens [allowOverlap]
*=$6ce0 "SCREENS"
#import "petmate/screens.asm"

.segment Music [allowOverlap]
.var music = LoadSid("data/output.sid")
*=music.location "MUSIC"
.fill music.size, music.getData(i)

//////////////////////////////////////////////////////////////////////////////////////
// File stuff
.file [name="tf64.prg", segments="Config,Program,Sprites,SFX,Screens,Music,Offline"]
.disk [filename="tf64.d64", name="CITYXEN TF64", id="2026!" ] {
	[name="tf64", type="prg",  segments="Config,Program,Sprites,SFX,Screens,Music,Offline"],
    [name="--------------------",type="del"],
}
//////////////////////////////////////////////////////////////////////////////////////
.segment Config [allowOverlap]
* = $0801 "BASIC Startup"
.word usend
.word 2023  // line num
.byte $9e   // sys
.text toIntString(start)
.byte $3a,99,67,73,84,89,88,69,78,99
usend:
.byte 0
.word 0  // empty link signals the end of the program
* = $0817 "Configuration"
start:
    jmp initialize

#import "config.asm"

.segment SFX [allowOverlap]
*=SFX_LOC "SFX KIT"
.import binary "data/sfxkit.prg", 2

.segment Program [allowOverlap]
*=$3d00

#import "initialize.asm"
#import "meatloaf_api.asm"
#import "main_loop.asm"
#import "game_loop.asm"
#import "game_over_loop.asm"
#import "debug.asm"
#import "draw_screens.asm"
#import "init_sprites.asm"
#import "util.asm"
#import "version.asm"



