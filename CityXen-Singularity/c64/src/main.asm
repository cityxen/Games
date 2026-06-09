//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY  —  The AI Faction War
// By Deadline / CityXen 2026
// https://cityxen.itch.io   https://youtube.com/@CityXen
//
// A top-down exploration adventure for the Commodore 64.
//   - Play as CLICKY (the SID Sonic), explorer of the LO8BC
//   - SEARCH is the core verb: face a thing, hit the search button — items,
//     clues, lore, Retronic Energy and secrets are hidden everywhere
//   - Retronic Energy is your lifeforce + currency; Retronic Wells restore it
//   - Recover the world from Miss DOS and her Clone Army before SINGULARITY
//
// Inspirations mangled together: Zelda (screen-by-screen overworld),
//   Maniac Mansion + Impossible Mission (the search mechanic), Secret of Mana
//   (light real-time threat), Monkey Island + Earthbound (humour in the text).
//
// Dependencies:
//   E:\dev\cityxen\retro-dev-tools\include\commodore64 must be on libdir
//   (set in KickAss_AutoGen.cfg).
//////////////////////////////////////////////////////////////////////////////////////

#import "Constants.asm"
#import "Macros.asm"

//////////////////////////////////////////////////////////////////////////////////////
// Sprites — Clicky, a Clone, a Retronic Well, an ally APM.  At $3000 (pointer $C0).
.segment Sprites [allowOverlap]
*=$3000 "SPRITES"
#import "sprites.asm"

//////////////////////////////////////////////////////////////////////////////////////
// Output file
.file [name="singularity.prg", segments="Program,Sprites"]

//////////////////////////////////////////////////////////////////////////////////////
// Program — library inline code + game code, all from $0801
.segment Program [allowOverlap]
*=$0801
CityXenUpstart(start)

start:
singularity_entry_point:
    jmp initialize

//////////////////////////////////////////////////////////////////////////////////////
// Include library inline subroutines
#import "sys.il.asm"
#import "timers.il.asm"
#import "input.il.asm"
#import "random.il.asm"
#import "sprite.il.asm"
#import "print/print.asm"   // PrintXY / PrintStrAtColor (avoids print.il.asm dep)

//////////////////////////////////////////////////////////////////////////////////////
// Game modules (imported in dependency order)
#import "config.asm"        // constants, lookup tables, strings (read-only)
#import "vars.asm"          // mutable runtime vars
#import "levelgen.asm"      // RNG + procedural sector generator
#import "initialize.asm"    // hardware init
#import "main_loop.asm"     // title screen
#import "game_loop.asm"     // new-game bootstrap + per-frame loop
#import "hud.asm"           // HUD + status-bar messages + numeric print
#import "room.asm"          // room rendering, collision map, transitions
#import "player.asm"        // Clicky movement, facing, edge transitions
#import "entities.asm"      // Clone Army patrols (light real-time threat)
#import "search.asm"        // THE SEARCH MECHANIC — the core verb
#import "summon.asm"        // keyboard input + Baka Retro Crew summons
#import "worldflip.asm"     // Reality Inverter — CityXen <-> Nexytic
#import "draw_screens.asm"  // title / victory / dormancy screens
#import "sprite_init.asm"   // title screen sprite setup
#import "util.asm"          // timer hooks
