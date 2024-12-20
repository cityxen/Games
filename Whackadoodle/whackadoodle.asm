//////////////////////////////////////////////////////////////
// WHACKADOODLE for C64 by Deadline / CityXen 2024
//
// Meatloaf support by Jaime Idolpx (Meatloaf guy)
//
// Fairground tune by Saul Cross
//
// Thanks to Logg & the AHCS for support and play testing
//
//////////////////////////////////////////////////////////////
// You will need the following repo in order to compile this
// https://github.com/cityxen/Commodore64_Programming
//////////////////////////////////////////////////////////////


#import "../../Commodore64_Programming/include/Constants.asm"
#import "../../Commodore64_Programming/include/Macros.asm"
#import "../../Commodore64_Programming/include/PrintMacros.asm"
#import "../../Commodore64_Programming/include/DrawPetMateScreen.asm"
#import "wad_constants.asm"

.file [name="wad-cxn-w.prg", segments="Main,PRG,Sprites,Screens,Music,SFX"]
// .file [name="wad.prg", segments=""]

.segment SFX [allowOverlap]
*=$c000 "SFX KIT"
.import binary "sound/sfxwdp.prg", 2

// FX PLAYER ON    : sys 49152 : jsr $c000 // sound_on sr
// FX PLAYER OFF   : sys 49168 : jsr $c010 // sound_off sr
// CLEAR REGISTERS : sys 49657 : jsr $c1f9 // clear sr
// IRQ CONTROL     :           : jsr $c028 // add into irq

.segment Music [allowOverlap]
.var music = LoadSid("whackadoodle.sid")		//<- Here we load the sid file
*=music.location "Music"
.fill music.size, music.getData(i) // <- Here we put the music in memory

.segment Sprites [allowOverlap]
*=$3000 "SPRITES"
#import "sprites/was-sprites-2.0 - Sprites.asm"

.segment Screens [allowOverlap]
*=$4800 "SCREENS"
#import "petmate/screen4.asm"

*=$0801
CityXenUpstart(start)

.segment PRG [allowOverlap]
* = $34c0 "PRG"
start:
#import "start.asm"
#import "main_loop.asm"
#import "game_loop.asm"
#import "game_over_loop.asm"
#import "doodles.asm"
#import "messages.asm"
#import "draw_screens.asm"
#import "init_sprites.asm"
#import "debug.asm"
#import "sound.asm"
#import "timers.asm"
#import "util.asm"
#import "meatloaf_highscore_api.asm"
#import "config.asm"