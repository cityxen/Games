//////////////////////////////////////////////////////////////
// Adventure Game Engine for C64 by Deadline / CityXen 2024
//
//////////////////////////////////////////////////////////////
// You will need the following repo in order to compile this
// https://github.com/cityxen/Commodore64_Programming
//////////////////////////////////////////////////////////////


#import "../../Commodore64_Programming/include/Constants.asm"
#import "../../Commodore64_Programming/include/Macros.asm"
#import "../../Commodore64_Programming/include/PrintMacros.asm"
#import "../../Commodore64_Programming/include/DrawPetMateScreen.asm"

.file [name="cxn-age.prg", segments="Main,PRG,Sprites,Screens,Music,SFX"]

.segment SFX [allowOverlap]
*=$c000 "SFX KIT"
.import binary "sound/sfx.prg", 2

// FX PLAYER ON    : sys 49152 : jsr $c000 // sound_on sr
// FX PLAYER OFF   : sys 49168 : jsr $c010 // sound_off sr
// CLEAR REGISTERS : sys 49657 : jsr $c1f9 // clear sr
// IRQ CONTROL     :           : jsr $c028 // add into irq

.segment Music [allowOverlap]
.var music = LoadSid("age.sid")		//<- Here we load the sid file
*=music.location "Music"
.fill music.size, music.getData(i) // <- Here we put the music in memory

.segment Sprites [allowOverlap]
*=$3000 "SPRITES"
#import "sprites/sprites.asm"

.segment Screens [allowOverlap]
*=$4800 "SCREENS"
#import "petmate/screens.asm"

*=$0801
CityXenUpstart(start)

.segment PRG [allowOverlap]
* = $34c0 "PRG"
start:
#import "constants.asm"
#import "start.asm"
#import "main_loop.asm"
#import "game_loop.asm"
#import "game_over_loop.asm"
#import "messages.asm"
#import "draw_screens.asm"
#import "init_sprites.asm"
#import "debug.asm"
#import "sound.asm"
#import "timers.asm"
#import "util.asm"
#import "config.asm"