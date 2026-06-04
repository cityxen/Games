//////////////////////////////////////////////////////////////////////////////////////
// SUTEHK: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//////////////////////////////////////////////////////////////////////////////////////
// vars.asm - Game constants, variables, lookup tables

//////////////////////////////////////////////////////////////////////////////////////
// Extra zero-page pointers for 2x2 tile drawing (second screen/color row)
.const zp_ptr_screen2    = $92
.const zp_ptr_screen2_lo = $92
.const zp_ptr_screen2_hi = $93
.const zp_ptr_color2     = $94
.const zp_ptr_color2_lo  = $94
.const zp_ptr_color2_hi  = $95

//////////////////////////////////////////////////////////////////////////////////////
// Object type constants
.const OBJ_NONE   = 0   // Empty / floor (alias)
.const OBJ_WALL   = 1   // Solid wall
.const OBJ_FLOOR  = 2   // Floor (explicit)
.const OBJ_ORB    = 3   // Time Node  - slides; ORB+ORB = match
.const OBJ_STATUE = 4   // Osiran Pillar - slides; STATUE+STATUE = match
.const OBJ_GATE   = 5   // Seal of Binding - solid; GATE+GATE = open
.const OBJ_ENEMY  = 6   // Lesser Servant - moves in loop
.const OBJ_RELIC   = 7   // False Relic - looks like ORB; RELIC+ORB = match
.const OBJ_PYRAMID  = 8   // Eternal Monument - slides; PYRAMID+PYRAMID = match
.const OBJ_LEVER_UP = 9   // Switch - player activates to open target cell
.const OBJ_LEVER_DOWN = 10 // Switch in activated state
.const OBJ_EXIT_CLOSED = 11 // Closed exit wall (fence sprite overlay)
.const OBJ_EXIT_OPEN   = 12 // Open exit (gate sprite overlay)

//////////////////////////////////////////////////////////////////////////////////////
// 2x2 tile screen codes (TL=top-left  TR=top-right  BL=bottom-left  BR=bottom-right)
.const TILE_WALL_TL    = $A0
.const TILE_WALL_TR    = $A0
.const TILE_WALL_BL    = $A0
.const TILE_WALL_BR    = $A0

.const TILE_FLOOR_TL   = $20
.const TILE_FLOOR_TR   = $20
.const TILE_FLOOR_BL   = $20
.const TILE_FLOOR_BR   = $20

.const TILE_PLAYER_TL  = $00   // @ screen code
.const TILE_PLAYER_TR  = $00
.const TILE_PLAYER_BL  = $00
.const TILE_PLAYER_BR  = $00

.const TILE_ORB_TL     = $0F   // O
.const TILE_ORB_TR     = $0F
.const TILE_ORB_BL     = $0F
.const TILE_ORB_BR     = $0F

.const TILE_STATUE_TL  = $A0   // solid white pillar
.const TILE_STATUE_TR  = $A0
.const TILE_STATUE_BL  = $A0
.const TILE_STATUE_BR  = $A0

.const TILE_GATE_TL    = $A0   // diagonal checkerboard
.const TILE_GATE_TR    = $20
.const TILE_GATE_BL    = $20
.const TILE_GATE_BR    = $A0

.const TILE_ENEMY_TL   = $18   // X
.const TILE_ENEMY_TR   = $18
.const TILE_ENEMY_BL   = $18
.const TILE_ENEMY_BR   = $18

.const TILE_RELIC_TL   = $0F   // O same as ORB (the liar!)
.const TILE_RELIC_TR   = $0F
.const TILE_RELIC_BL   = $0F
.const TILE_RELIC_BR   = $0F

//////////////////////////////////////////////////////////////////////////////////////
// Level layout constants
.const LEVEL_W        = 20      // Level width in tiles
.const LEVEL_H        = 10      // Level height in tiles
.const LEVEL_SCREEN_X = 0       // 20 tiles * 2 chars wide = 40 fills the screen
.const LEVEL_SCREEN_Y = 5       // Screen row offset (leaves rows 0-4 for title/HUD)
.const LEVEL_COUNT    = 16      // Number of levels

//////////////////////////////////////////////////////////////////////////////////////
// Timer indices (beyond the standard ones in timers.il.asm)
.const TIMER_ENEMY_MOVE  = 0    // Enemy movement speed
.const TIMER_WIN_PAUSE   = 1    // Pause after win before next level
.const TIMER_PLAYER_ANIM = 2    // Fires every IRQ tick for smooth player movement
.const TIMER_BAT         = 6    // Bat movement and animation (index 6, period overridden to 3 in hook)

.const PLAYER_MOVE_SPEED = 2    // Pixels per animation tick
.const PLAYER_MOVE_STEPS = 8    // 16px / 4px = 4 ticks per tile

.const BAT_SPEED         = 4    // Bat pixels per timer tick (~100px/sec at 60Hz)

//////////////////////////////////////////////////////////////////////////////////////
// Game state variables
menu_bgcolor:      .byte BLACK
game_state:        .byte 0         // 0=title, 1=playing, 2=win
current_level:     .byte 0
menu_anim_frame:   .byte 0         // 0 or 1 toggle for 2-frame menu sprites
menu_dollar_frame: .byte 0         // 0, 1, or 2 for dollar 3-frame cycle

// Player position (tile coordinates within level)
player_x:       .byte 0
player_y:       .byte 0
player_walk_frame: .byte 0   // 0 or 1; toggles on every successful step

// Smooth movement state (pixel-level animation between tiles)
player_is_moving:      .byte 0  // 1 while sprite is gliding between tiles
player_move_steps_rem: .byte 0  // countdown ticks remaining in current move
player_sprite_x_lo:    .byte 0  // current sprite pixel X lo byte
player_sprite_x_hi:    .byte 0  // current sprite pixel X hi byte (MSB, 0 or 1)
player_sprite_y:       .byte 0  // current sprite pixel Y
player_target_x_lo:    .byte 0  // destination pixel X lo
player_target_x_hi:    .byte 0  // destination pixel X hi
player_target_y:       .byte 0  // destination pixel Y

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
// Bat state (sprite 7)
bat_active:      .byte 0    // 0=off-screen, 1=flying across
bat_x_lo:        .byte 0    // current pixel X lo byte
bat_x_hi:        .byte 0    // current pixel X hi byte (0 or 1)
bat_y:           .byte 0    // current pixel Y
bat_dx:          .byte 0    // $01=moving right, $FF=moving left
bat_anim_sub:    .byte 0    // sub-tick counter for 2-frame animation
bat_spawn_delay: .byte 80   // ticks until next bat launch
bat_y_idx:       .byte 0    // cycles through bat_y_table

// 8 Y pixel rows covering the game area (row*16+90 for rows 0-7)
bat_y_table:
.byte 88, 104, 120, 136, 152, 168, 184, 200

// Spawn delay table (ticks at TIMER_BAT rate before next bat launch)
bat_delay_table:
.byte 70, 90, 60, 100, 80, 50, 110, 75

// Bat spawn locals
gbs_row:        .byte 0
gbs_row_tmp:    .byte 0
gbs_tries:      .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// game_map: one byte per tile, LEVEL_W * LEVEL_H = 200 bytes
// Stores OBJ_* type constants. Player position is NOT stored here.
game_map: .fill 200, OBJ_FLOOR

//////////////////////////////////////////////////////////////////////////////////////
// Precomputed screen RAM row base addresses for 2x2 tiles
// level_row_lo/hi[i]  = top    screen row of game row i
// level_row2_lo/hi[i] = bottom screen row of game row i
level_row_lo:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte <(SCREEN_RAM + (LEVEL_SCREEN_Y + i*2) * 40 + LEVEL_SCREEN_X)
}
level_row_hi:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte >(SCREEN_RAM + (LEVEL_SCREEN_Y + i*2) * 40 + LEVEL_SCREEN_X)
}
level_row2_lo:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte <(SCREEN_RAM + (LEVEL_SCREEN_Y + i*2 + 1) * 40 + LEVEL_SCREEN_X)
}
level_row2_hi:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte >(SCREEN_RAM + (LEVEL_SCREEN_Y + i*2 + 1) * 40 + LEVEL_SCREEN_X)
}

// Precomputed color RAM row base addresses for 2x2 tiles
color_row_lo:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte <(COLOR_RAM + (LEVEL_SCREEN_Y + i*2) * 40 + LEVEL_SCREEN_X)
}
color_row_hi:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte >(COLOR_RAM + (LEVEL_SCREEN_Y + i*2) * 40 + LEVEL_SCREEN_X)
}
color_row2_lo:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte <(COLOR_RAM + (LEVEL_SCREEN_Y + i*2 + 1) * 40 + LEVEL_SCREEN_X)
}
color_row2_hi:
.for (var i = 0; i < LEVEL_H; i++) {
    .byte >(COLOR_RAM + (LEVEL_SCREEN_Y + i*2 + 1) * 40 + LEVEL_SCREEN_X)
}

//////////////////////////////////////////////////////////////////////////////////////
// 2x2 tile lookup tables indexed by OBJ_* type (0-10)
type_to_tile_tl:
.byte TILE_FLOOR_TL     // 0: OBJ_NONE
.byte TILE_WALL_TL      // 1: OBJ_WALL
.byte TILE_FLOOR_TL     // 2: OBJ_FLOOR
.byte TILE_FLOOR_TL     // 3: OBJ_ORB     (sprite overlay)
.byte TILE_FLOOR_TL     // 4: OBJ_STATUE  (sprite overlay)
.byte TILE_GATE_TL      // 5: OBJ_GATE
.byte TILE_ENEMY_TL     // 6: OBJ_ENEMY
.byte TILE_FLOOR_TL     // 7: OBJ_RELIC   (sprite overlay)
.byte TILE_FLOOR_TL     // 8: OBJ_PYRAMID (sprite overlay)
.byte TILE_FLOOR_TL     // 9: OBJ_LEVER_UP   (sprite overlay)
.byte TILE_FLOOR_TL     // 10: OBJ_LEVER_DOWN (sprite overlay)
.byte TILE_FLOOR_TL     // 11: OBJ_EXIT_CLOSED (sprite overlay)
.byte TILE_FLOOR_TL     // 12: OBJ_EXIT_OPEN   (sprite overlay)

type_to_tile_tr:
.byte TILE_FLOOR_TR
.byte TILE_WALL_TR
.byte TILE_FLOOR_TR
.byte TILE_FLOOR_TR     // 3: OBJ_ORB     (sprite overlay)
.byte TILE_FLOOR_TR     // 4: OBJ_STATUE  (sprite overlay)
.byte TILE_GATE_TR
.byte TILE_ENEMY_TR
.byte TILE_FLOOR_TR     // 7: OBJ_RELIC   (sprite overlay)
.byte TILE_FLOOR_TR     // 8: OBJ_PYRAMID (sprite overlay)
.byte TILE_FLOOR_TR     // 9: OBJ_LEVER_UP   (sprite overlay)
.byte TILE_FLOOR_TR     // 10: OBJ_LEVER_DOWN (sprite overlay)
.byte TILE_FLOOR_TR     // 11: OBJ_EXIT_CLOSED (sprite overlay)
.byte TILE_FLOOR_TR     // 12: OBJ_EXIT_OPEN   (sprite overlay)

type_to_tile_bl:
.byte TILE_FLOOR_BL
.byte TILE_WALL_BL
.byte TILE_FLOOR_BL
.byte TILE_FLOOR_BL     // 3: OBJ_ORB     (sprite overlay)
.byte TILE_FLOOR_BL     // 4: OBJ_STATUE  (sprite overlay)
.byte TILE_GATE_BL
.byte TILE_ENEMY_BL
.byte TILE_FLOOR_BL     // 7: OBJ_RELIC   (sprite overlay)
.byte TILE_FLOOR_BL     // 8: OBJ_PYRAMID (sprite overlay)
.byte TILE_FLOOR_BL     // 9: OBJ_LEVER_UP   (sprite overlay)
.byte TILE_FLOOR_BL     // 10: OBJ_LEVER_DOWN (sprite overlay)
.byte TILE_FLOOR_BL     // 11: OBJ_EXIT_CLOSED (sprite overlay)
.byte TILE_FLOOR_BL     // 12: OBJ_EXIT_OPEN   (sprite overlay)

type_to_tile_br:
.byte TILE_FLOOR_BR
.byte TILE_WALL_BR
.byte TILE_FLOOR_BR
.byte TILE_FLOOR_BR     // 3: OBJ_ORB     (sprite overlay)
.byte TILE_FLOOR_BR     // 4: OBJ_STATUE  (sprite overlay)
.byte TILE_GATE_BR
.byte TILE_ENEMY_BR
.byte TILE_FLOOR_BR     // 7: OBJ_RELIC   (sprite overlay)
.byte TILE_FLOOR_BR     // 8: OBJ_PYRAMID (sprite overlay)
.byte TILE_FLOOR_BR     // 9: OBJ_LEVER_UP   (sprite overlay)
.byte TILE_FLOOR_BR     // 10: OBJ_LEVER_DOWN (sprite overlay)
.byte TILE_FLOOR_BR     // 11: OBJ_EXIT_CLOSED (sprite overlay)
.byte TILE_FLOOR_BR     // 12: OBJ_EXIT_OPEN   (sprite overlay)

type_to_color:
.byte BLACK             // 0: OBJ_NONE
.byte RED               // 1: OBJ_WALL
.byte BLACK             // 2: OBJ_FLOOR
.byte BLACK             // 3: OBJ_ORB     (sprite; char color irrelevant)
.byte BLACK             // 4: OBJ_STATUE  (sprite; char color irrelevant)
.byte ORANGE            // 5: OBJ_GATE
.byte RED               // 6: OBJ_ENEMY
.byte BLACK             // 7: OBJ_RELIC   (sprite; char color irrelevant)
.byte BLACK             // 8: OBJ_PYRAMID (sprite; char color irrelevant)
.byte BLACK             // 9: OBJ_LEVER_UP   (sprite; char color irrelevant)
.byte BLACK             // 10: OBJ_LEVER_DOWN (sprite; char color irrelevant)
.byte BLACK             // 11: OBJ_EXIT_CLOSED (sprite; char color irrelevant)
.byte BLACK             // 12: OBJ_EXIT_OPEN   (sprite; char color irrelevant)

//////////////////////////////////////////////////////////////////////////////////////
// Lever target cell (loaded per-level from room-layout tables)
lever_target_x:     .byte 0
lever_target_y:     .byte 0

// Exit state
exit_x:             .byte 0   // tile X of exit wall
exit_y:             .byte 0   // tile Y of exit wall
exit_open:          .byte 0   // 0=closed, 1=open
exit_rng:           .byte $37 // LCG seed (kept nonzero)
exit_tmp_count:     .byte 0
exit_wall_idx:      .byte 0

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
gd_screen_col:      .byte 0     // gd_col * 2 (screen column for 2x2 tiles)
gd_row_base:        .byte 0
gd_tmp:             .byte 0

// Orb sprite scan locals (game_draw_orb_sprites)
orb_anim_frame:         .byte 0     // 0 = emerald frame1, 1 = emerald frame2
gdos_row:               .byte 0
gdos_col:               .byte 0
gdos_row_base:          .byte 0
gdos_tmp:               .byte 0
gdos_sprite_num:        .byte 0     // next sprite slot to assign (starts at 1)
gdos_sprite_reg_off:    .byte 0     // sprite_num * 2 for SPRITE_LOCATIONS indexing
gdos_cur_ptr:           .byte 0     // emerald frame pointer being used this scan
gdos_enable_mask:       .byte 0     // accumulates SPRITE_ENABLE bits
gdos_msb_mask:          .byte 0     // accumulates SPRITE_MSB_X bits
gdos_place_ptr:         .byte 0     // sprite pointer for current object type
gdos_place_color:       .byte 0     // sprite color for current object type

// One-hot bit mask per sprite (indexed by sprite number 0-7)
sprite_bit_tbl:
.byte %00000001, %00000010, %00000100, %00001000
.byte %00010000, %00100000, %01000000, %10000000

//////////////////////////////////////////////////////////////////////////////////////
// Strings (PETSCII uppercase)
.encoding "petscii_upper"
str_title:
.byte KEY_YELLOW
.text "SUTEHK: DESTROYER OF WORLDS"
.byte KEY_LT_GREEN
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
str_level_lbl:
.text "LVL: "
.byte 0
str_restart_lbl:
.byte KEY_WHITE
.text "R"
.byte KEY_YELLOW
.text "=RST "
.byte KEY_WHITE
.text "Q"
.byte KEY_YELLOW
.text "=QUIT"
.byte 0
str_level_complete:
.byte KEY_LT_GREEN
.text "** RITES COMPLETED **"
.byte 0
str_game_complete:
.byte KEY_RED
.text "* ALL RITES FULFILLED *"
.byte 0
str_credit:
.text "BY DEADLINE / CITYXEN 2026"
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
    // Set player animation timer to 1 tick (fires every IRQ, ~16ms at 60Hz)
    lda #1
    SetTimerTo(TIMER_PLAYER_ANIM)
    // Bat moves every 3 ticks (~20 times/sec at 60Hz)
    lda #3
    SetTimerTo(TIMER_BAT)
    rts

irq_timer_user_hook:
    rts


.const sprite_multicolor_1 = DARK_GREY
.const sprite_multicolor_2 = WHITE

.const sprite_pointer_sutehk_down  = $c0
.const sprite_pointer_sutehk_up    = $c1
.const sprite_pointer_sutehk_right = $c2
.const sprite_pointer_sutehk_left  = $c3

.const sprite_pointer_pyramid      = $c4

.const sprite_pointer_bat_frame1   = $c5
.const sprite_pointer_bat_frame2   = $c6
.const sprite_bat_color            = LIGHT_RED
.const sprite_bat_multicolor       = $00


.const sprite_pointer_ankh         = $c7
.const sprite_pointer_orb          = $c8

.const sprite_pointer_dollar_frame1 = $c9
.const sprite_pointer_dollar_frame2 = $ca
.const sprite_pointer_dollar_frame3 = $cb

.const sprite_pointer_lever_up      = $cc
.const sprite_pointer_lever_down    = $cd

.const sprite_pointer_energy_frame1 = $ce
.const sprite_pointer_energy_frame2 = $cf

.const sprite_pointer_statue        = $d0

.const sprite_pointer_fence         = $d1
.const sprite_pointer_gate_left     = $d2
.const sprite_pointer_gate_right    = $d3

.const sprite_pointer_emerald_frame1 = $d4
.const sprite_pointer_emerald_frame2 = $d5

.const sprite_pointer_spider_web     = $d6

.const sprite_pointer_sutehk_walk_down_frame1    = $d7
.const sprite_pointer_sutehk_walk_down_frame2    = $d8

.const sprite_pointer_sutehk_walk_up_frame1    = $d9
.const sprite_pointer_sutehk_walk_up_frame2    = $da

.const sprite_pointer_sutehk_walk_right_frame1    = $db
.const sprite_pointer_sutehk_walk_right_frame2    = $dc

.const sprite_pointer_sutehk_walk_left_frame1    = $dd
.const sprite_pointer_sutehk_walk_left_frame2    = $de



 










