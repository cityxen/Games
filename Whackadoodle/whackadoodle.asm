//////////////////////////////////////////////////////////////
// WHACKADOODLE for C64 by Deadline / CityXen 2024
//
// Cartridge code & Meatloaf support by Jaime Idolpx
//
// Fairground tune by Saul Cross
//
// Thanks to Logg & the Atlanta Historical Computing Society 
// (AHCS) for support and play testing
//
//////////////////////////////////////////////////////////////
// You will need the following repo in order to compile this
// https://github.com/cityxen/Commodore64_Programming
//////////////////////////////////////////////////////////////

#import "Constants.asm"
#import "Macros.asm"
#import "PrintMacros.asm"
#import "DrawPetMateScreen.asm"

.file [name="wad-cxn-w.prg", segments="Main,PRG,Sprites,Screens,Music,SFX"]

.segment SFX [allowOverlap]
*=$c000 "SFX KIT"
.import binary "sound/sfxkit.prg", 2

.segment Music [allowOverlap]
.var music = LoadSid("whackadoodle.sid") // <- Here we load the sid file
*=music.location "Music"
.fill music.size, music.getData(i)       // <- Here we put the music in memory

.segment Sprites [allowOverlap]
*=$3000 "SPRITES"
#import "sprites/was-sprites-2.0 - Sprites.asm"

.segment Screens [allowOverlap]
*=$4900 "SCREENS"
#import "petmate/screen4.asm"

*=$0801
CityXenUpstart(start)

.segment PRG [allowOverlap]
* = $1800 "PRG"
start:
    jmp initialize

#import "constants.asm"
#import "config.asm"
#import "initialize.asm"
#import "main_loop.asm"
#import "game_loop.asm"
#import "game_over_loop.asm"
#import "debug.asm"
#import "draw_screens.asm"
#import "init_sprites.asm"
#import "util.asm"
#import "meatloaf_highscore_api.asm"
// Whackadoodle specific stuff
#import "doodles.asm"
#import "messages.asm"

