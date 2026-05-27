//////////////////////////////////////////////////////////////////////////////////////
// ROGUE ENGINE 64 - C64
// vars.asm - Game constants, variables, lookup tables
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////
// Map layout (2x2 tiles: each map cell = 2x2 screen characters)
.const MAP_W        = 20        // map columns; *2 = 40 screen columns
.const MAP_H        = 10        // map rows;    *2 = 20 screen rows (rows 20-24 = HUD)
.const MAP_SIZE     = MAP_W * MAP_H   // 200 bytes

// Room generation
.const MAX_ROOMS    = 5
.const MIN_ROOM_W   = 3
.const MAX_ROOM_W   = 5
.const MIN_ROOM_H   = 2
.const MAX_ROOM_H   = 3

//////////////////////////////////////////////////////////////////////////////////////
// Tile type IDs stored in rogue_map (one byte per cell)
.const TILE_WALL    = 0
.const TILE_FLOOR   = 1
.const TILE_STAIRS  = 2

// Display screencodes (C64 screen memory codes, not PETSCII)
// Each tile uses the same char for all 4 quadrants of its 2x2 block.
.const TILE_WALL_CHAR    = $A0    // solid block (all 4 quadrants)
.const TILE_FLOOR_CHAR   = $20    // space = dark floor (all 4 quadrants)
.const TILE_STAIRS_CHAR  = $3E    // '>' (all 4 quadrants)

//////////////////////////////////////////////////////////////////////////////////////
// Monster type IDs
.const MTYPE_RAT    = 0
.const MTYPE_BAT    = 1
.const MTYPE_GOBLIN = 2

// Item type IDs
.const ITYPE_POTION = 0
.const ITYPE_WEAPON = 1

.const MAX_MONSTERS = 8
.const MAX_ITEMS    = 6

//////////////////////////////////////////////////////////////////////////////////////
// Colors
.const COLOR_WALL    = LIGHT_GRAY
.const COLOR_FLOOR   = DARK_GRAY
.const COLOR_STAIRS  = CYAN
.const COLOR_PLAYER  = YELLOW
.const COLOR_MONSTER = RED
.const COLOR_POTION  = GREEN
.const COLOR_WEAPON  = ORANGE
.const COLOR_HUD     = WHITE
.const COLOR_MSG     = LIGHT_GREEN

//////////////////////////////////////////////////////////////////////////////////////
// Timer indices (on top of standard library timers)
.const TIMER_ENEMY_MOVE = 0    // enemy AI tick rate
.const TIMER_MSG_CLEAR  = 1    // auto-clear message countdown

//////////////////////////////////////////////////////////////////////////////////////
// Extra zero-page pointers for 2x2 tile drawing
// Safe range: $92-$96, $A5-$B1 (library uses $A3/$A4 for zp_ptr_color)
.const zp_ptr_screen2    = $92
.const zp_ptr_screen2_lo = $92
.const zp_ptr_screen2_hi = $93
.const zp_ptr_color2     = $94
.const zp_ptr_color2_lo  = $94
.const zp_ptr_color2_hi  = $95

.const zp_ptr_map       = $A5
.const zp_ptr_map_lo    = $A5
.const zp_ptr_map_hi    = $A6

//////////////////////////////////////////////////////////////////////////////////////
// Player state
player_x:       .byte 0
player_y:       .byte 0
player_hp:      .byte 20
player_max_hp:  .byte 20
player_atk:     .byte 3
player_def:     .byte 1
player_floor:   .byte 1

// Temp vars for movement/combat
move_new_x:     .byte 0
move_new_y:     .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Monster table (MAX_MONSTERS entries)
monster_x:      .fill MAX_MONSTERS, 0
monster_y:      .fill MAX_MONSTERS, 0
monster_hp:     .fill MAX_MONSTERS, 0
monster_type:   .fill MAX_MONSTERS, 0
monster_alive:  .fill MAX_MONSTERS, 0

//////////////////////////////////////////////////////////////////////////////////////
// Item table (MAX_ITEMS entries)
item_x:         .fill MAX_ITEMS, 0
item_y:         .fill MAX_ITEMS, 0
item_type:      .fill MAX_ITEMS, 0
item_active:    .fill MAX_ITEMS, 0

//////////////////////////////////////////////////////////////////////////////////////
// Stairs position
stairs_x:       .byte 0
stairs_y:       .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Room table (MAX_ROOMS entries: x,y,w,h,center_x,center_y)
room_x:         .fill MAX_ROOMS, 0
room_y:         .fill MAX_ROOMS, 0
room_w:         .fill MAX_ROOMS, 0
room_h:         .fill MAX_ROOMS, 0
room_cx:        .fill MAX_ROOMS, 0
room_cy:        .fill MAX_ROOMS, 0
room_count:     .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Dungeon generator temporaries
room_cur_x:     .byte 0
room_cur_y:     .byte 0
room_cur_w:     .byte 0
room_cur_h:     .byte 0
corr_x1:        .byte 0
corr_y1:        .byte 0
corr_x2:        .byte 0
corr_y2:        .byte 0
dcr_dx:         .byte 0
dcr_dy:         .byte 0
gen_room_idx:   .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// General game logic temporaries
g_tmp:          .byte 0
g_tmp2:         .byte 0
g_idx:          .byte 0
g_dmg:          .byte 0    // combat damage scratch
g_tr:           .byte 0    // draw temp: TR char
g_bl:           .byte 0    // draw temp: BL char
g_br:           .byte 0    // draw temp: BR char
gd_y:           .byte 0    // draw loop row counter

//////////////////////////////////////////////////////////////////////////////////////
// Message system
msg_active:     .byte 0     // nonzero = message displayed

//////////////////////////////////////////////////////////////////////////////////////
// Game state
game_state:     .byte 0     // 0=playing 1=dead 2=win

//////////////////////////////////////////////////////////////////////////////////////
// Tile char/color lookup tables (indexed by TILE_* type)
// Each tile uses one char for all 4 quadrants of its 2x2 block.
tile_char_tbl:
.byte TILE_WALL_CHAR       // 0: TILE_WALL
.byte TILE_FLOOR_CHAR      // 1: TILE_FLOOR
.byte TILE_STAIRS_CHAR     // 2: TILE_STAIRS

tile_color_tbl:
.byte COLOR_WALL           // 0: TILE_WALL
.byte COLOR_FLOOR          // 1: TILE_FLOOR
.byte COLOR_STAIRS         // 2: TILE_STAIRS

//////////////////////////////////////////////////////////////////////////////////////
// Monster character data: 4 bytes per type (TL,TR,BL,BR); lookup = MTYPE_* * 4
// Screencodes: $12=R, $02=B, $07=G
monster_chars_rat:    .byte $12,$12,$12,$12
monster_chars_bat:    .byte $02,$02,$02,$02
monster_chars_goblin: .byte $07,$07,$07,$07

monster_max_hp_tbl:
.byte 3                    // RAT
.byte 2                    // BAT
.byte 6                    // GOBLIN

monster_atk_tbl:
.byte 1                    // RAT
.byte 1                    // BAT
.byte 2                    // GOBLIN

//////////////////////////////////////////////////////////////////////////////////////
// Item character data: 4 bytes per type (TL,TR,BL,BR); lookup = ITYPE_* * 4
// Screencodes: $21=!, $2F=/
item_chars_potion: .byte $21,$21,$21,$21
item_chars_weapon: .byte $2F,$2F,$2F,$2F

item_color_tbl:
.byte COLOR_POTION         // 0: POTION
.byte COLOR_WEAPON         // 1: WEAPON

//////////////////////////////////////////////////////////////////////////////////////
// Player character data: TL, TR, BL, BR (screencode $00 = @)
player_chars: .byte $00,$00,$00,$00

//////////////////////////////////////////////////////////////////////////////////////
// Precomputed screen RAM row base addresses for 2x2 tiles
// Map row i occupies screen rows i*2 (top) and i*2+1 (bottom).
screen_row_lo:
.for (var i = 0; i < MAP_H; i++) {
    .byte <(SCREEN_RAM + i*2*40)
}
screen_row_hi:
.for (var i = 0; i < MAP_H; i++) {
    .byte >(SCREEN_RAM + i*2*40)
}
screen_row2_lo:
.for (var i = 0; i < MAP_H; i++) {
    .byte <(SCREEN_RAM + (i*2+1)*40)
}
screen_row2_hi:
.for (var i = 0; i < MAP_H; i++) {
    .byte >(SCREEN_RAM + (i*2+1)*40)
}

// Precomputed color RAM row base addresses for 2x2 tiles
color_row_lo:
.for (var i = 0; i < MAP_H; i++) {
    .byte <(COLOR_RAM + i*2*40)
}
color_row_hi:
.for (var i = 0; i < MAP_H; i++) {
    .byte >(COLOR_RAM + i*2*40)
}
color_row2_lo:
.for (var i = 0; i < MAP_H; i++) {
    .byte <(COLOR_RAM + (i*2+1)*40)
}
color_row2_hi:
.for (var i = 0; i < MAP_H; i++) {
    .byte >(COLOR_RAM + (i*2+1)*40)
}

// Precomputed map array row base addresses (within rogue_map)
map_row_lo:
.for (var i = 0; i < MAP_H; i++) {
    .byte <(rogue_map + i * MAP_W)
}
map_row_hi:
.for (var i = 0; i < MAP_H; i++) {
    .byte >(rogue_map + i * MAP_W)
}

//////////////////////////////////////////////////////////////////////////////////////
// THE DUNGEON MAP: MAP_W * MAP_H = 200 bytes
rogue_map: .fill MAP_SIZE, TILE_WALL

//////////////////////////////////////////////////////////////////////////////////////
// Strings (PETSCII uppercase for KERNAL output)
.encoding "petscii_upper"
str_title:       .text "** ROGUE ENGINE 64 **"
                 .byte 0
str_by:          .text "BY DEADLINE / CITYXEN 2026"
                 .byte 0
str_press_fire:  .text "PRESS FIRE OR KEY TO BEGIN"
                 .byte 0
str_legend_move: .text "MOVE: WASD OR JOYSTICK"
                 .byte 0
str_legend_keys: .text "BUMP ENEMIES TO ATTACK"
                 .byte 0
str_legend_tiles:.text "   . FLOOR  > STAIRS "
                 .byte $0d
                 .text "       ! POTION  / WEAPON"
                 .byte 0
str_hp_lbl:      .text "HP:"
                 .byte 0
str_atk_lbl:     .text " ATK:"
                 .byte 0
str_def_lbl:     .text " DEF:"
                 .byte 0
str_fl_lbl:      .text " FL:"
                 .byte 0
str_dead:        .text "YOU HAVE DIED. GAME OVER."
                 .byte 0
str_win:         .text "YOU ESCAPED! YOU WIN!"
                 .byte 0
str_hit_rat:     .text "YOU HIT THE RAT!"
                 .byte 0
str_hit_bat:     .text "YOU HIT THE BAT!"
                 .byte 0
str_hit_gob:     .text "YOU HIT THE GOBLIN!"
                 .byte 0
str_enemy_slain: .text "ENEMY SLAIN!"
                 .byte 0
str_got_hit:     .text "IT HITS YOU!"
                 .byte 0
str_potion:      .text "YOU DRINK A POTION. +5 HP!"
                 .byte 0
str_weapon:      .text "BETTER WEAPON FOUND! +1ATK"
                 .byte 0
str_stairs:      .text "YOU DESCEND DEEPER..."
                 .byte 0
str_blocked:     .byte 0

// HUD digit scratch buffer (for number display)
hud_num_str: .text "000"
             .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// IRQ hooks (required by timers.il.asm)
init_timers_user_hook:
    lda #40
    SetTimerTo(TIMER_ENEMY_MOVE)
    lda #180
    SetTimerTo(TIMER_MSG_CLEAR)
    rts

irq_timer_user_hook:
    rts
