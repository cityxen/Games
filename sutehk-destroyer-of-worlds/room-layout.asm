//////////////////////////////////////////////////////////////////////////////////////
// SUTEKH: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//////////////////////////////////////////////////////////////////////////////////////
// room-layout.asm - Level data and initialization

.const width  = LEVEL_W
.const height = LEVEL_H

//////////////////////////////////////////////////////////////////////////////////////
// Level data: LEVEL_W * LEVEL_H = 200 bytes per level
// Object type codes: 1=wall 2=floor 3=orb 4=statue 5=gate 6=enemy 7=relic
//
// Level tile key:
//   1 = OBJ_WALL    2 = OBJ_FLOOR   3 = OBJ_ORB
//   4 = OBJ_STATUE  5 = OBJ_GATE    6 = OBJ_ENEMY   7 = OBJ_RELIC

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 1 - Teach Matching
// Goal: push two Time Nodes (ORBs) together for 1 Rite
// Player starts at center. Two ORBs on row 1, push them together.
level1_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 1: orbs at x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 2
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4 player@(10,4)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 7
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level1_px:    .byte 10
level1_py:    .byte 4
level1_goal:  .byte 1
level1_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 2 - Space vs Score
// Goal: match 2 Rites (Pillars/Statues + ORB)
// Two Osiran Pillars (statues) at row 1; one Time Node (ORB) below;
// a Seal of Binding (gate) on the right of row 1.
level2_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 4, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 5, 2, 2, 2, 2, 1  // row 1: statues x=3,9; gate x=14
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 2
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4: orb at x=10
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5 player@(10,5)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 7
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level2_px:    .byte 10
level2_py:    .byte 5
level2_goal:  .byte 2
level2_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 3 - The Liar
// Goal: find the right match for 1 Rite
// One ORB and one RELIC (looks identical to ORB) on row 1.
// RELIC+ORB = match; RELIC+RELIC = nothing (teaches observation).
level3_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 7, 2, 2, 2, 2, 2, 1  // row 1: orb x=3, relic x=13
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 2
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4 player@(10,4)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 7
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level3_px:    .byte 10
level3_py:    .byte 4
level3_goal:  .byte 1
level3_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Level pointer tables (indexed by current_level)
level_data_lo:   .byte <level1_data,  <level2_data,  <level3_data
level_data_hi:   .byte >level1_data,  >level2_data,  >level3_data
level_px_tbl:    .byte 10, 10, 10
level_py_tbl:    .byte 4,  5,  4
level_goal_tbl:  .byte 1,  2,  1
level_enemy_tbl: .byte 0,  0,  0

//////////////////////////////////////////////////////////////////////////////////////
// init_level: loads current_level data into game_map and resets player/match state
// Clobbers: A, X, Y
init_level:
    ldx current_level

    // Reset match state
    lda #0
    sta match_count

    // Load match goal
    lda level_goal_tbl,x
    sta match_goal

    // Load player start position
    lda level_px_tbl,x
    sta player_x
    lda level_py_tbl,x
    sta player_y

    // Load enemy count
    lda level_enemy_tbl,x
    sta enemy_count

    // Set source pointer to level data
    lda level_data_lo,x
    sta zp_ptr_2_lo
    lda level_data_hi,x
    sta zp_ptr_2_hi

    // Copy 200 bytes into game_map
    ldy #0
il_copy:
    lda (zp_ptr_2),y
    sta game_map,y
    iny
    cpy #200
    bne il_copy

    rts
