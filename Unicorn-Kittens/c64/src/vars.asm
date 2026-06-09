//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — vars.asm
// All mutable runtime state, plus the screen / colour-RAM row-address lookup tables.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// Game / progression
var_game_state:  .byte 0
var_score_lo:    .byte 0        // 16-bit score
var_score_hi:    .byte 0
var_level:       .byte 1
var_hp:          .byte 0        // damage = lost hearts
var_load:        .byte 0        // goodies carried (0..MAX_LOAD)
var_kittens:     .byte 0        // total kittens rehomed (capped 255)
var_delivered:   .byte 0        // goodies delivered this level
var_goal:        .byte 0        // deliveries needed this level

//////////////////////////////////////////////////////////////////////////////////////
// Difficulty (recomputed each level)
var_spawn_rate:  .byte 0        // frames between item spawns
var_spawn_ctr:   .byte 0        // counts down to the next spawn
var_fall_base:   .byte 1        // base falling speed
var_bad_weight:  .byte 2        // bad-item chance band (out of 16)

//////////////////////////////////////////////////////////////////////////////////////
// Player (Clicky the unicorn — hardware sprite 0)
var_uni_x:       .byte 0
var_uni_y:       .byte 0
var_facing:      .byte 0
var_anim_ctr:    .byte 0
var_anim_frame:  .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Input / feedback
var_joy:         .byte 0
var_fire_prev:   .byte 0
var_flash:       .byte 0        // border-flash frames remaining
var_enable:      .byte 0        // composed SPRITE_ENABLE mask

//////////////////////////////////////////////////////////////////////////////////////
// Falling items (parallel arrays, one entry per slot 0..NUM_ITEMS-1)
item_active:     .fill NUM_ITEMS, 0
item_type:       .fill NUM_ITEMS, 0
item_x:          .fill NUM_ITEMS, 0
item_y:          .fill NUM_ITEMS, 0
item_speed:      .fill NUM_ITEMS, 0

//////////////////////////////////////////////////////////////////////////////////////
// General temps
var_tmp_a:       .byte 0
var_tmp_b:       .byte 0
var_tmp_c:       .byte 0
var_tmp_d:       .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Screen / colour-RAM row-address lookup tables (static)
screen_row_lo:   .fill 25, <(SCREEN_RAM + i*40)
screen_row_hi:   .fill 25, >(SCREEN_RAM + i*40)
color_row_lo:    .fill 25, <(COLOR_RAM  + i*40)
color_row_hi:    .fill 25, >(COLOR_RAM  + i*40)
