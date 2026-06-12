//////////////////////////////////////////////////////////////////////////////////////
//
// TRIVIA FIGHTERS 64 for C64
//
//                            by Deadline / CityXen 2026
// 
// Dependencies:
// The include folder from: https://github.com/cityxen/Commodore64_Programming/
// must be in kickassembler path in the KickAss.cfg file:
//   -libdir "PATHTO:\dev\cityxen\Commodore64_Programming\include"
//
// CityXen Videos: https://youtube.com/@cityxen
// CityXen Games: https://cityxen.itch.io
//
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////
// Set up segments
.segment Offline [allowOverlap]
*=$c500
#import "offline_trivia.asm"
.segment Sprites [allowOverlap]
*=$2800 "SPRITES"
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
// BASIC PRG Stuff
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
trivia_fighters_64_entry_point:
    jmp initialize
/////////////////////////////////////////////////////////////
// config.asm will load components of the c64 include
// library, and configuration variables into memory
#import "config.asm" 
/////////////////////////////////////////////////////////////
// SFX Kit stuff
.segment SFX [allowOverlap]
*=SFX_LOC "SFX KIT"
.import binary "data/sfxkit.prg", 2
/////////////////////////////////////////////////////////////
// Trivia Fighters 64 Game Source Here:
.segment Program [allowOverlap]
*=$3e00
trivia_fighters_64_game_code:
#import "anim_tables.asm"
#import "initialize.asm"
#import "meatloaf_api.asm"
#import "local_disk.asm"
#import "main_loop.asm"
#import "game_loop.asm"
#import "game_over_loop.asm"
#import "debug.asm"
#import "draw_screens.asm"
#import "init_sprites.asm"
#import "util.asm"
#import "version.asm"
// END Trivia Fighters 64 Game Source
/////////////////////////////////////////////////////////////
