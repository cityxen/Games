//////////////////////////////////////////////////////////////////////////
// CityXen: The Game (Level Editor)
// Author: Deadline
// CityXen 2024
//////////////////////////////////////////////////////////////////////////
.segment Main [allowOverlap]
//////////////////////////////////////////////////////////////////////////
// File stuff and importing files
.file [name="cxngame-le.prg", segments="Main"]
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
#import "SpriteManagement.asm"
#import "PrintSubRoutines.asm"
#import "cxngame_common/vars.asm"
#import "cxngame_common/tiledefs.asm"
#import "cxngame_common/quit.asm"
*=sprite_data "sprite_data"
#import "cxngame_le/sprites/sprites.asm"
*=var_space_sprites "var_space_sprites"
#import "cxngame_le/sprites/sprite_anim_tables.asm"
#import "cxngame_le/sprites/sprite_tables.asm"
*=custom_font "custom_font"
#import "cxngame_common/charset/chars.asm"
#import "cxngame_common/cxngame_basic_upstart.asm"
*=main_game "main_game"
#import "cxngame_le/initialize.asm"
#import "cxngame_le/main_menu.asm"
#import "cxngame_le/main_loop.asm"
#import "cxngame_common/level_init.asm"
#import "cxngame_common/debug.asm"

