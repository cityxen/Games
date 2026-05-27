//////////////////////////////////////////////////////////////////////////
// CityXen: The Game
// Author: Deadline
// CityXen 2024
//////////////////////////////////////////////////////////////////////////
.segment Main [allowOverlap]
//////////////////////////////////////////////////////////////////////////
// File stuff and importing files
.file [name="cxngame.prg", segments="Main"]
.var var_space          = $0900
.var var_space_sprites  = $1000
.var tile_definitions   = $0d00 // sets up 2x2 tile defs 
.var level_data         = $1000 // - ??? 
.var sprite_data        = $2800 // - $37ff
.var custom_font        = $3800 // - $3fff
.var main_game          = $4000 // - $8fff
*=var_space "var_space"
#import "Constants.asm"
#import "Macros.asm"
#import "old/SpriteManagement.asm"
#import "old/PrintSubRoutines.asm"
// ZP aliases: old library used zp_screen/zp_color; new library uses zp_ptr_screen/zp_ptr_color
.const zp_screen    = zp_ptr_screen     // $60
.const zp_screen_lo = zp_ptr_screen_lo  // $60
.const zp_screen_hi = zp_ptr_screen_hi  // $61
.const zp_color     = zp_ptr_color      // $A3
.const zp_color_lo  = zp_ptr_color_lo   // $A3
.const zp_color_hi  = zp_ptr_color_hi   // $A4
.const TEMP_6       = $c003             // temp byte used by SpriteManagement
#import "cxngame_common/vars.asm"
#import "cxngame_common/tiledefs.asm"
#import "cxngame_common/quit.asm"
*=sprite_data "sprite_data"
#import "cxngame/sprites/sprites.asm"
*=var_space_sprites "var_space_sprites"
#import "cxngame/sprites/sprite_anim_tables.asm"
#import "cxngame/sprites/sprite_tables.asm"
*=custom_font "custom_font"
#import "cxngame_common/charset/chars.asm"
#import "cxngame_common/cxngame_basic_upstart.asm"
*=main_game "main_game"
#import "cxngame/initialize.asm"
#import "cxngame/main_menu.asm"
#import "cxngame/main_loop.asm"
#import "cxngame_common/level_init.asm"
#import "cxngame_common/debug.asm"

