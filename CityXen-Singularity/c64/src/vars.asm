//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — vars.asm
// Mutable runtime state.  The per-sector level data (rooms, objects, barriers,
// clones, object-state) lives in generated RAM buffers at $C400+ (see config.asm).
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// Game / resources / progression
var_game_state:   .byte 0
var_re_lo:        .byte 0       // Retronic Energy (16-bit)
var_re_hi:        .byte 0
var_ci:           .byte 0       // Collective Imagination
var_items:        .byte 0
var_flags:        .byte 0       // barrier-cleared bits (anchor i needs bit 1<<i)
var_level:        .byte 1       // current sector (1-based)
var_anchors_need: .byte 0       // nodes to disable this sector
var_anchors_done: .byte 0
var_is_boss:      .byte 0       // 1 if this sector is a Miss DOS boss
var_boss_dead:    .byte 0       // boss defeated this sector

//////////////////////////////////////////////////////////////////////////////////////
// Current room / world
var_room:         .byte 0
var_world:        .byte 0       // WORLD_CITYXEN / WORLD_NEXYTIC
var_room_count:   .byte 0       // rooms generated this sector

//////////////////////////////////////////////////////////////////////////////////////
// Player (Clicky) — sprite slot 0
var_player_x:     .byte 0
var_player_x_msb: .byte 0
var_player_y:     .byte 0
var_facing:       .byte 0
var_moving:       .byte 0
var_old_x:        .byte 0
var_old_x_msb:    .byte 0
var_old_y:        .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Clones in the current room (VIC sprite slots 1..CLONE_MAX)
clone_active:     .fill CLONE_MAX, 0
clone_x:          .fill CLONE_MAX, 0
clone_y:          .fill CLONE_MAX, 0
clone_dir:        .fill CLONE_MAX, 0
var_clone_drain_ctr: .byte 0
var_clone_speed:  .byte 1       // px/frame (scales with depth)

//////////////////////////////////////////////////////////////////////////////////////
// Walk-animation phase (shared by player + clones)
var_anim_ctr:     .byte 0       // counts game frames
var_anim_frame:   .byte 0       // current walk frame (0..ANIM_FRAMES-1)

//////////////////////////////////////////////////////////////////////////////////////
// Interaction
var_fire_prev:    .byte 0
var_near_obj:     .byte $FF

//////////////////////////////////////////////////////////////////////////////////////
// Status-bar message
var_msg_ptr_lo:   .byte 0
var_msg_ptr_hi:   .byte 0
var_msg_timer:    .byte 0
var_hover:        .byte $FF      // hint msg id currently shown (hover), $FF = none

//////////////////////////////////////////////////////////////////////////////////////
// General temps
var_tmp_a:        .byte 0
var_tmp_b:        .byte 0
var_tmp_c:        .byte 0
var_tmp_joy:      .byte 0

// Room/object/search scratch
var_wall_color:   .byte 0
var_obj_slot:     .byte 0
var_pcol:         .byte 0
var_prow:         .byte 0

// 3x3 object-tile draw/erase scratch
var_tile_idx:     .byte 0       // running index into tile_char (kind*TILE_REC + cell)
var_tile_col:     .byte 0       // left column of the tile
var_tile_row:     .byte 0       // current (top→bottom) row of the tile
var_tile_rc:      .byte 0       // rows remaining
var_tile_cc:      .byte 0       // cols remaining

// Summon scratch
var_summon_crew:  .byte 0
var_bar_off:      .byte 0
var_near_bar:     .byte $FF

//////////////////////////////////////////////////////////////////////////////////////
// Level-generation scratch
var_rng:          .byte 1       // RNG state (never 0)
var_g0:           .byte 0
var_g1:           .byte 0
var_g2:           .byte 0
var_g3:           .byte 0
var_g4:           .byte 0
var_gobj_slot:    .byte 0       // objects generated so far
var_gbar:         .byte 0       // next free barrier byte-offset
var_gclone:       .byte 0       // next free clone byte-offset
var_exit_room:    .byte 0       // room holding the sector gate / boss
var_slot:         .byte 0       // slot index chosen by the last gen_find_slot
var_rift_slot:    .byte 0       // slot the current location's rift occupies (mirrored)
var_key_room:     .byte 0       // CityXen room hiding the Inverter Key this sector
// placement call args
var_pl_room:      .byte 0
var_pl_kind:      .byte 0
var_pl_arg:       .byte 0
var_pl_crew:      .byte 0
var_pl_flag:      .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Screen / colour RAM row-address lookup tables (static; also used for BLOCK_MAP).
screen_row_lo:    .fill 25, <(SCREEN_RAM + i*40)
screen_row_hi:    .fill 25, >(SCREEN_RAM + i*40)
color_row_lo:     .fill 25, <(COLOR_RAM  + i*40)
color_row_hi:     .fill 25, >(COLOR_RAM  + i*40)
