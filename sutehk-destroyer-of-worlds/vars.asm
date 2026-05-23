//////////////////////////////////////////////////////////////////////////////////////
// SUTEKH: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//////////////////////////////////////////////////////////////////////////////////////
// vars.asm - Game constants, variables, lookup tables

//////////////////////////////////////////////////////////////////////////////////////
// Object type constants
.const OBJ_NONE   = 0   // Empty / floor (alias)
.const OBJ_WALL   = 1   // Solid wall
.const OBJ_FLOOR  = 2   // Floor (explicit)
.const OBJ_ORB    = 3   // Time Node  - slides; ORB+ORB = match
.const OBJ_STATUE = 4   // Osiran Pillar - slides; STATUE+STATUE = match
.const OBJ_GATE   = 5   // Seal of Binding - solid; GATE+GATE = open
.const OBJ_ENEMY  = 6   // Lesser Servant - moves in loop
.const OBJ_RELIC  = 7   // False Relic - looks like ORB; RELIC+ORB = match

//////////////////////////////////////////////////////////////////////////////////////
// Screen codes (what goes into screen RAM $0400)
.const TILE_WALL        = $A0   // Solid block (reversed space in uppercase charset)
.const TILE_FLOOR       = $20   // Space
.const TILE_PLAYER      = $00   // @ (screen code for @)
.const TILE_ORB         = $0F   // O
.const TILE_STATUE      = $13   // S
.const TILE_GATE_CLOSED = $07   // G
.const TILE_ENEMY       = $18   // X
.const TILE_RELIC       = $0F   // R looks like O (the liar!)

//////////////////////////////////////////////////////////////////////////////////////
// Level layout constants
.const LEVEL_W        = 20      // Level width in tiles
.const LEVEL_H        = 10      // Level height in tiles
.const LEVEL_SCREEN_X = 10      // Screen column offset (centers 20-wide level on 40-wide screen)
.const LEVEL_SCREEN_Y = 5       // Screen row offset (leaves rows 0-4 for title/HUD)
.const LEVEL_COUNT    = 3       // Number of levels

//////////////////////////////////////////////////////////////////////////////////////
// Timer indices (beyond the standard ones in timers.il.asm)
.const TIMER_ENEMY_MOVE = 0     // Enemy movement speed
.const TIMER_WIN_PAUSE  = 1     // Pause after win before next level

//////////////////////////////////////////////////////////////////////////////////////
// Game state variables
menu_bgcolor:   .byte BLACK
game_state:     .byte 0         // 0=title, 1=playing, 2=win
current_level:  .byte 0

// Player position (tile coordinates within level)
player_x:       .byte 0
player_y:       .byte 0

// Match tracking
match_count:    .byte 0
match_goal:     .byte 0

// Move direction (signed: $01 = +1, $FF = -1, $00 = no movement)
move_dx:        .byte 0
move_dy:        .byte 0

// General purpose temps used by map routines and push logic
tmp_x:          .byte 0
tmp_y:          .byte 0
map_tmp:        .byte 0
map_val:        .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Enemy table (up to 4 enemies per level)
enemy_count:    .byte 0
enemy_x:        .byte 0,0,0,0
enemy_y:        .byte 0,0,0,0
enemy_dx:       .byte 0,0,0,0   // $01=right/down, $FF=left/up
enemy_dy:       .byte 0,0,0,0

//////////////////////////////////////////////////////////////////////////////////////
// game_map: one byte per tile, LEVEL_W * LEVEL_H = 200 bytes
// Stores OBJ_* type constants. Player position is NOT stored here.
game_map: .fill 200, OBJ_FLOOR

//////////////////////////////////////////////////////////////////////////////////////
// Precomputed screen RAM row base addresses (for the level viewport)
// level_row_lo/hi[y] = SCREEN_RAM + (LEVEL_SCREEN_Y + y) * 40 + LEVEL_SCREEN_X
level_row_lo:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte <(SCREEN_RAM + (LEVEL_SCREEN_Y + i) * 40 + LEVEL_SCREEN_X)
}
level_row_hi:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte >(SCREEN_RAM + (LEVEL_SCREEN_Y + i) * 40 + LEVEL_SCREEN_X)
}

// Precomputed color RAM row base addresses
color_row_lo:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte <(COLOR_RAM + (LEVEL_SCREEN_Y + i) * 40 + LEVEL_SCREEN_X)
}
color_row_hi:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte >(COLOR_RAM + (LEVEL_SCREEN_Y + i) * 40 + LEVEL_SCREEN_X)
}

//////////////////////////////////////////////////////////////////////////////////////
// Tile lookup tables indexed by OBJ_* type (0-7)
type_to_tile:
.byte TILE_FLOOR        // 0: OBJ_NONE  -> floor
.byte TILE_WALL         // 1: OBJ_WALL
.byte TILE_FLOOR        // 2: OBJ_FLOOR
.byte TILE_ORB          // 3: OBJ_ORB
.byte TILE_STATUE       // 4: OBJ_STATUE
.byte TILE_GATE_CLOSED  // 5: OBJ_GATE
.byte TILE_ENEMY        // 6: OBJ_ENEMY
.byte TILE_RELIC        // 7: OBJ_RELIC (same tile as ORB - the liar!)

type_to_color:
.byte BLACK             // 0: OBJ_NONE
.byte DARK_GRAY         // 1: OBJ_WALL
.byte BLACK             // 2: OBJ_FLOOR
.byte CYAN              // 3: OBJ_ORB
.byte WHITE             // 4: OBJ_STATUE
.byte ORANGE            // 5: OBJ_GATE
.byte RED               // 6: OBJ_ENEMY
.byte CYAN              // 7: OBJ_RELIC (same color as ORB - the liar!)

//////////////////////////////////////////////////////////////////////////////////////
// Push subroutine locals
gps_origin_x:       .byte 0
gps_origin_y:       .byte 0
gps_slide_x:        .byte 0
gps_slide_y:        .byte 0
gps_next_x:         .byte 0
gps_next_y:         .byte 0
gps_obj_type:       .byte 0
gps_blocker_type:   .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Draw subroutine locals
gd_row:             .byte 0
gd_col:             .byte 0
gd_row_base:        .byte 0
gd_tmp:             .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Strings (PETSCII uppercase)
.encoding "petscii_upper"
str_title:
.text "SUTEKH: DESTROYER OF WORLDS"
.byte 0
str_subtitle:
.text "  A GAME OF INEVITABILITY  "
.byte 0
str_press_start:
.text "PRESS FIRE OR KEY TO BEGIN"
.byte 0
str_rites_lbl:
.text "RITES: "
.byte 0
str_slash:
.text " / "
.byte 0
str_level_complete:
.text "** RITES COMPLETED **"
.byte 0
str_game_complete:
.text "* ALL RITES FULFILLED *"
.byte 0

//////////////////////////////////////////////////////////////////////////////////////
// IRQ timer hooks (required by timers.il.asm)
init_timers_user_hook:
    // Set TIMER_INPUT to 15 ticks (~0.25s) for puzzle game pacing
    lda #15
    SetTimerTo(TIMER_INPUT)
    // Set enemy move timer
    lda #30
    SetTimerTo(TIMER_ENEMY_MOVE)
    rts

irq_timer_user_hook:
    rts
