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
// use -l "path-to-lib" in KickAss command line 
//////////////////////////////////////////////////////////////

#import "Constants.asm"
#import "Macros.asm"
#import "DrawPetMateScreen.asm"

.file [name="wad-cxn.prg", segments="PRG,Sprites,Screens,Music,SFX"]

.segment SFX [allowOverlap]
*=$c000 "SFX KIT"
.import binary "sound/sfxkit.prg", 2

.segment Music [allowOverlap]
.var music = LoadSid("whackadoodle.sid") // <- Here we load the sid file
*=music.location "Music"
.fill music.size, music.getData(i)       // <- Here we put the music in memory

.segment Sprites [allowOverlap]
*=$3000 "SPRITES"
#import "sprites/sprites.asm"

.segment Screens [allowOverlap]
*=$4900 "SCREENS"
#import "petmate/screen.asm"

*=$0801
CityXenUpstart(start)

.segment PRG [allowOverlap]
* = $1726 "PRG"
start:

    jmp initialize  

#import "config.asm"
#import "initialize.asm"
#import "constants.asm"
#import "meatloaf_highscore_api.asm"
#import "main_loop.asm"
#import "game_loop.asm"
#import "game_over_loop.asm"
#import "debug.asm"
#import "draw_screens.asm"
#import "init_sprites.asm"
#import "util.asm"
#import "version.asm"


// Whackadoodle specific stuff
#import "doodles.asm"
#import "messages.asm"

