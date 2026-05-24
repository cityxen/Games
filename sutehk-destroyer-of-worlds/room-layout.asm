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
//   4 = OBJ_STATUE  5 = OBJ_GATE    6 = OBJ_ENEMY   7 = OBJ_RELIC   8 = OBJ_PYRAMID
//   9 = OBJ_LEVER_UP

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
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 4: orbs at x=10, x=16
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
// LEVEL 4 - Two Liars
// Goal: 2 Rites. Two RELICs and two ORBs — cross-matched across rows.
// RELIC+RELIC = nothing; player must match each RELIC with an ORB.
level4_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 7, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 3, 2, 1  // row 2: relic x=2, wall x=10, orb x=17
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4
.byte    1, 2, 2, 2, 2, 9, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5: lever x=5, player@(10,5)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 7, 2, 1  // row 7: orb x=2, relic x=17
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level4_px:    .byte 10
level4_py:    .byte 5
level4_goal:  .byte 2
level4_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 5 - All Rites
// Goal: 3 Rites. One of every matching pair: statues, orbs, and relic+orb.
// Statues on row 2, relic+orb on row 4, orb pair on row 7.
level5_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 2, 1  // row 2: statues x=1, x=18
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3
.byte    1, 7, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 1  // row 4: relic x=1, orb x=18
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5 player@(10,5)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 1  // row 7: orbs x=1, x=18
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level5_px:    .byte 10
level5_py:    .byte 5
level5_goal:  .byte 3
level5_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 6 - Vertical
// Goal: 3 Rites. All matches require vertical pushes (up/down) instead of horizontal.
// ORB pair and STATUE pair share columns; RELIC above its ORB in col 10.
level6_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 1  // row 2: orb x=5, statue x=14
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3: relic x=10
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5 player@(3,5)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 2, 2, 3, 2, 2, 2, 2, 3, 2, 2, 2, 4, 2, 2, 2, 2, 1  // row 7: orb x=5, orb x=10, statue x=14
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level6_px:    .byte 3
level6_py:    .byte 5
level6_goal:  .byte 3
level6_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 7 - Three Rows
// Goal: 3 Rites. Three independent pairs, one per row: ORBs, STATUEs, RELIC+ORB.
// Player starts at top; navigate left to push each pair rightward.
level7_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1 player@(10,1)
.byte    1, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 2: orbs x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 9, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3: lever x=10
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4
.byte    1, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 2, 2, 1  // row 5: statues x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 7, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 7: relic x=3, wall x=9, orb x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level7_px:    .byte 10
level7_py:    .byte 1
level7_goal:  .byte 3
level7_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 8 - Chain Reaction
// Goal: 3 Rites. RELIC+ORB creates a surviving ORB; push it down into another ORB.
// Statues provide the third match independently.
level8_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 2
.byte    1, 2, 7, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 1  // row 3: relic x=2, orb x=17
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5
.byte    1, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 1  // row 6: statues x=3, x=12
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 1  // row 7: orb x=17
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8 player@(10,8)
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level8_px:    .byte 10
level8_py:    .byte 8
level8_goal:  .byte 3
level8_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 9 - Crowded
// Goal: 4 Rites. RELIC+ORB twice creates two surviving ORBs in col 16;
// push one into the other for the 4th match. Statues add a 1st match.
level9_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 2, 2, 1  // row 2: statues x=3, x=16
.byte    1, 2, 2, 2, 2, 9, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3: lever x=5
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4 player@(10,4)
.byte    1, 2, 2, 7, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 5: relic x=3, wall x=10, orb x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 7: relic x=3, orb x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level9_px:    .byte 10
level9_py:    .byte 4
level9_goal:  .byte 4
level9_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 10 - All Is Revealed
// Goal: 5 Rites. Two RELICs create two surviving ORBs in col 16 that chain together;
// statues add 1; a separate ORB pair at row 8 adds the 5th.
level10_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 2, 2, 1  // row 2: statues x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3 player@(10,3)
.byte    1, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 4: relic x=3, orb x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5
.byte    1, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 6: relic x=3, orb x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 7
.byte    1, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 1  // row 8: orbs x=8, x=11
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level10_px:    .byte 10
level10_py:    .byte 3
level10_goal:  .byte 5
level10_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 11 - The Monument Rises
// Goal: 1 Rite. Introduce the Pyramid (slides; PYRAMID+PYRAMID = match).
// Push the two Pyramids together horizontally.
level11_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 2
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3
.byte    1, 2, 2, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 2, 2, 1  // row 4: pyramids x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5 player@(10,5)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 7
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level11_px:    .byte 10
level11_py:    .byte 5
level11_goal:  .byte 1
level11_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 12 - Twin Monuments
// Goal: 2 Rites. Two pairs of Pyramids on separate rows; match each pair.
level12_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 2, 2, 1  // row 2: pyramids x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5 player@(10,5)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 2, 2, 1  // row 7: pyramids x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level12_px:    .byte 10
level12_py:    .byte 5
level12_goal:  .byte 2
level12_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 13 - Three Kinds
// Goal: 3 Rites. One of every pushable type: Pyramid pair, Orb pair, Relic+Orb.
level13_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 2, 2, 1  // row 2: pyramids x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4 player@(10,4)
.byte    1, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 5: orbs x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 7: relic x=3, orb x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level13_px:    .byte 10
level13_py:    .byte 4
level13_goal:  .byte 3
level13_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 14 - The Tombs
// Goal: 3 Rites. All matches require vertical pushes.
// Pyramid pair in col 5, Statue pair in col 14, Relic+Orb in col 10.
level14_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 2, 2, 8, 2, 2, 2, 2, 2, 2, 2, 2, 4, 2, 2, 2, 2, 1  // row 2: pyramid x=5, statue x=14
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3: relic x=10
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 5 player@(3,5)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 2, 2, 8, 2, 2, 2, 2, 3, 2, 2, 2, 4, 2, 2, 2, 2, 1  // row 7: pyramid x=5, orb x=10, statue x=14
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level14_px:    .byte 3
level14_py:    .byte 5
level14_goal:  .byte 3
level14_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 15 - Grand Design
// Goal: 4 Rites. Four pairs using all pushable types.
// Pyramid pair, Statue pair, Orb pair, Relic+Orb — push each from the left wall.
level15_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 8, 2, 2, 1  // row 2: pyramids x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4 player@(10,4)
.byte    1, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 2, 2, 1  // row 5: statues x=3, x=16
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 7: orbs x=3, x=16
.byte    1, 2, 2, 7, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 1  // row 8: relic x=3, orb x=16
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level15_px:    .byte 10
level15_py:    .byte 4
level15_goal:  .byte 4
level15_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// LEVEL 16 - The Seal
// Goal: 1 Rite. Introduce the lever. A wall at (10,5) blocks the two Pyramids from
// matching. Step on the Lever at (10,7) to open the gap, then push them together.
level16_data:
// col: 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 0
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 1
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 2
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 3 player@(4,3)
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 4
.byte    1, 2, 8, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 8, 2, 1  // row 5: pyramid x=2, wall x=10, pyramid x=17
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 6
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 9, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 7: lever x=10
.byte    1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1  // row 8
.byte    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1  // row 9
level16_px:    .byte 4
level16_py:    .byte 3
level16_goal:  .byte 1
level16_enemies: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Level pointer tables (indexed by current_level)
level_data_lo:   .byte <level1_data,  <level2_data,  <level3_data,  <level4_data,  <level5_data
                 .byte <level6_data,  <level7_data,  <level8_data,  <level9_data,  <level10_data
                 .byte <level11_data, <level12_data, <level13_data, <level14_data, <level15_data
                 .byte <level16_data
level_data_hi:   .byte >level1_data,  >level2_data,  >level3_data,  >level4_data,  >level5_data
                 .byte >level6_data,  >level7_data,  >level8_data,  >level9_data,  >level10_data
                 .byte >level11_data, >level12_data, >level13_data, >level14_data, >level15_data
                 .byte >level16_data
level_px_tbl:    .byte 10, 10, 10, 10, 10,  3, 10, 10, 10, 10, 10, 10, 10,  3, 10,  4
level_py_tbl:    .byte  4,  5,  4,  5,  5,  5,  1,  8,  4,  3,  5,  5,  4,  5,  4,  3
level_goal_tbl:  .byte  1,  2,  1,  2,  3,  3,  3,  3,  4,  5,  1,  2,  3,  3,  4,  1
level_enemy_tbl: .byte  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
// Lever target cell per level (0,0 = no lever; cell (0,0) is always a border wall)
level_lever_tx_tbl: .byte  0,  0,  0, 10,  0,  0,  9,  0, 10,  0,  0,  0,  0,  0,  0, 10
level_lever_ty_tbl: .byte  0,  0,  0,  2,  0,  0,  7,  0,  5,  0,  0,  0,  0,  0,  0,  5

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

    // Load lever target cell
    lda level_lever_tx_tbl,x
    sta lever_target_x
    lda level_lever_ty_tbl,x
    sta lever_target_y

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
