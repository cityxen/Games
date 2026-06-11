
// ANIM_1 "Brawl" — p1 charges in, punch then kick, p2 reels back
anim1_table:
//      p1x  p1y    p2x  p2y
.byte    50, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   4,   0,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_body_left_2,   4,   0,   sp_ptr_body_right_2,   0,   0
.byte sp_ptr_body_left_3,   4,   0,   sp_ptr_body_right_3,   0,   0
.byte sp_ptr_body_left_4,   4,   0,   sp_ptr_body_right_4,   0,   0
.byte sp_ptr_body_left_5,   4,   0,   sp_ptr_body_right_5,   0,   0
.byte sp_ptr_body_left_6,   4,   0,   sp_ptr_body_right_6,   0,   0
.byte sp_ptr_punch_left,    0,   0,   sp_ptr_body_right_1,   6,  -2
.byte sp_ptr_punch_left,    0,   0,   sp_ptr_body_right_2,   6,  -2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_3,   2,   2
.byte sp_ptr_kick_left,     0,   0,   sp_ptr_body_right_4,   5,   2
.byte sp_ptr_kick_left,     0,   0,   sp_ptr_body_right_5,   5,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_6,   0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,   0,   0
.byte $ff

// ANIM_2 "Counter" — p2 rushes in, p1 backpedals then counter-strikes
anim2_table:
//      p1x  p1y    p2x  p2y
.byte    60, 150,   210, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  -4,   0
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_body_right_2,  -4,   0
.byte sp_ptr_body_left_3,   0,   0,   sp_ptr_body_right_3,  -4,   0
.byte sp_ptr_body_left_4,  -3,   0,   sp_ptr_body_right_4,  -4,   0
.byte sp_ptr_body_left_5,  -3,   0,   sp_ptr_body_right_5,  -3,   0
.byte sp_ptr_body_left_6,  -3,   0,   sp_ptr_punch_right,   -2,   0
.byte sp_ptr_body_left_1,  -2,   0,   sp_ptr_punch_right,    0,   0
.byte sp_ptr_punch_left,    5,   0,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_punch_left,    5,   0,   sp_ptr_body_right_2,   4,  -2
.byte sp_ptr_kick_left,     2,   0,   sp_ptr_body_right_3,   5,   2
.byte sp_ptr_kick_left,     0,   0,   sp_ptr_body_right_4,   4,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,   0,   0
.byte $ff

// ANIM_3 "Showdown" — both close in, bob, glare (frown), then back off
anim3_table:
//      p1x  p1y    p2x  p2y
.byte    40, 150,   215, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   4,   0,   sp_ptr_body_right_1,  -4,   0
.byte sp_ptr_body_left_2,   4,   0,   sp_ptr_body_right_2,  -4,   0
.byte sp_ptr_body_left_3,   4,   0,   sp_ptr_body_right_3,  -4,   0
.byte sp_ptr_body_left_4,   4,   0,   sp_ptr_body_right_4,  -4,   0
.byte sp_ptr_body_left_5,   3,   0,   sp_ptr_body_right_5,  -3,   0
.byte sp_ptr_body_left_1,   0,  -2,   sp_ptr_body_right_1,   0,  -2
.byte sp_ptr_body_left_2,   0,   2,   sp_ptr_body_right_2,   0,   2
.byte sp_ptr_body_left_1,   0,  -2,   sp_ptr_body_right_1,   0,  -2
.byte sp_ptr_body_left_2,   0,   2,   sp_ptr_body_right_2,   0,   2
.byte sp_ptr_frown,         0,   0,   sp_ptr_frown,          0,   0
.byte sp_ptr_frown,         0,   0,   sp_ptr_frown,          0,   0
.byte sp_ptr_body_left_1,  -4,   0,   sp_ptr_body_right_1,   4,   0
.byte sp_ptr_body_left_2,  -4,   0,   sp_ptr_body_right_2,   4,   0
.byte sp_ptr_body_left_3,  -4,   0,   sp_ptr_body_right_3,   4,   0
.byte $ff

// Effect / attack sprite pointers (sp_ptr_skull, sp_ptr_heart, sp_ptr_star,
// sp_ptr_poo, sp_ptr_dollar, sp_ptr_atk_lightning, sp_ptr_atk_swirl, ...) can
// be dropped into a BODY column for a stylized beat. The static head still
// floats above, so a fighter momentarily "becomes" the effect — swap to taste.

// ANIM_4 "KO Punch" — p1 lands a haymaker, p2 turns to a skull and drops
anim4_table:
//      p1x  p1y    p2x  p2y
.byte    40, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   6,   0,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_body_left_2,   6,   0,   sp_ptr_body_right_2,   0,   0
.byte sp_ptr_body_left_3,   6,   0,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_body_left_4,   4,   0,   sp_ptr_body_right_2,   0,   0
.byte sp_ptr_punch_left,    2,   0,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_punch_left,    0,   0,   sp_ptr_skull,          7,  -5
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_skull,          6,  -2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_skull,          4,   5
.byte sp_ptr_kick_left,     0,   0,   sp_ptr_skull,          2,   9
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_skull,          0,   6
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_skull,          0,   0
.byte $ff

// ANIM_5 "Dizzy" — both stagger, swirling stars (effect sprites in body slot)
anim5_table:
//      p1x  p1y    p2x  p2y
.byte    80, 150,   190, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_atk_swirl,     0,  -1,   sp_ptr_atk_swirl,      0,  -1
.byte sp_ptr_star,          2,   1,   sp_ptr_star,          -2,   1
.byte sp_ptr_atk_star,     -2,  -1,   sp_ptr_atk_star,       2,  -1
.byte sp_ptr_atk_swirl,     2,   1,   sp_ptr_atk_swirl,     -2,   1
.byte sp_ptr_star,         -2,  -1,   sp_ptr_star,           2,  -1
.byte sp_ptr_atk_star,      2,   1,   sp_ptr_atk_star,      -2,   1
.byte sp_ptr_atk_swirl,    -2,  -1,   sp_ptr_atk_swirl,      2,  -1
.byte sp_ptr_star,          0,   1,   sp_ptr_star,           0,   1
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,   0,   0
.byte $ff

// ANIM_6 "Taunt" — p1 struts up taunting (poo/frown), p2 fumes then charges
anim6_table:
//      p1x  p1y    p2x  p2y
.byte    60, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_poo,           2,   0,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_poo,           2,  -2,   sp_ptr_body_right_2,   0,   0
.byte sp_ptr_frown,         2,   2,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_poo,           2,  -2,   sp_ptr_body_right_2,   0,   0
.byte sp_ptr_frown,         2,   2,   sp_ptr_frown,          0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_frown,         -2,   0
.byte sp_ptr_body_left_1,  -2,   0,   sp_ptr_body_right_1,  -4,   0
.byte sp_ptr_body_left_2,  -3,   0,   sp_ptr_body_right_2,  -4,   0
.byte sp_ptr_body_left_3,  -3,   0,   sp_ptr_punch_right,   -2,   0
.byte sp_ptr_body_left_4,  -3,   0,   sp_ptr_punch_right,    0,   0
.byte $ff

// ANIM_7 "Love" — both hop together trailing hearts, meet in the middle
anim7_table:
//      p1x  p1y    p2x  p2y
.byte    50, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   3,  -4,   sp_ptr_body_right_1,  -3,  -4
.byte sp_ptr_heart,         3,   4,   sp_ptr_heart,         -3,   4
.byte sp_ptr_body_left_1,   3,  -4,   sp_ptr_body_right_1,  -3,  -4
.byte sp_ptr_heart,         3,   4,   sp_ptr_heart,         -3,   4
.byte sp_ptr_body_left_1,   3,  -4,   sp_ptr_body_right_1,  -3,  -4
.byte sp_ptr_heart,         2,   4,   sp_ptr_heart,         -2,   4
.byte sp_ptr_heart,         0,  -3,   sp_ptr_heart,          0,  -3
.byte sp_ptr_heart,         0,   3,   sp_ptr_heart,          0,   3
.byte sp_ptr_heart,         0,  -3,   sp_ptr_heart,          0,  -3
.byte sp_ptr_heart,         0,   3,   sp_ptr_heart,          0,   3
.byte $ff

// ANIM_8 "Money" — p1 dances with dollar signs, p2 greedily gives chase
anim8_table:
//      p1x  p1y    p2x  p2y
.byte    70, 150,   210, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_dollar,        0,  -5,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_dollar,        0,   5,   sp_ptr_body_right_2,  -2,   0
.byte sp_ptr_dollar,       -3,  -5,   sp_ptr_body_right_1,  -3,   0
.byte sp_ptr_dollar,       -3,   5,   sp_ptr_body_right_2,  -3,   0
.byte sp_ptr_dollar,       -3,  -5,   sp_ptr_body_right_1,  -3,   0
.byte sp_ptr_dollar,        3,   5,   sp_ptr_body_right_2,  -2,   0
.byte sp_ptr_dollar,        3,  -5,   sp_ptr_punch_right,   -1,   0
.byte sp_ptr_dollar,        3,   5,   sp_ptr_body_right_1,   0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,   0,   0
.byte $ff

// ANIM_9 "Lightning Duel" — both charge, lightning clash, bounce, repeat, logo
anim9_table:
//      p1x  p1y    p2x  p2y
.byte    40, 150,   210, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,    6,   0,  sp_ptr_body_right_1,  -6,   0
.byte sp_ptr_body_left_2,    6,   0,  sp_ptr_body_right_2,  -6,   0
.byte sp_ptr_body_left_3,    6,   0,  sp_ptr_body_right_3,  -6,   0
.byte sp_ptr_atk_lightning,  4,   0,  sp_ptr_atk_lightning, -4,   0
.byte sp_ptr_atk_lightning,  0,   0,  sp_ptr_atk_lightning,  0,   0
.byte sp_ptr_body_left_1,   -6,   0,  sp_ptr_body_right_1,   6,   0
.byte sp_ptr_body_left_2,   -4,   0,  sp_ptr_body_right_2,   4,   0
.byte sp_ptr_body_left_3,    6,   0,  sp_ptr_body_right_3,  -6,   0
.byte sp_ptr_atk_lightning,  4,   0,  sp_ptr_atk_lightning, -4,   0
.byte sp_ptr_atk_lightning,  0,   0,  sp_ptr_atk_lightning,  0,   0
.byte sp_ptr_commodore,      0,  -2,  sp_ptr_commodore,      0,  -2
.byte sp_ptr_commodore,      0,   2,  sp_ptr_commodore,      0,   2
.byte $ff

// ANIM_10 "Banana Slip" — p2 steps on a banana and wipes out
anim10_table:
//      p1x  p1y    p2x  p2y
.byte    60, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_atk_banana,    0,   0
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_atk_banana,    0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,  -2
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_body_right_3,  0,  -4
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_5,  2,   2
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_skull,         2,   8
.byte sp_ptr_punch_left,    0,   0,   sp_ptr_skull,         0,  10
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_skull,         0,   0
.byte $ff

// ANIM_11 "Wifi Hack" — p1 jams p2's signal, p2 glitches into a crash
anim11_table:
//      p1x  p1y    p2x  p2y
.byte    55, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_atk_wifi,      0,   0,   sp_ptr_body_right_2,  0,   0
.byte sp_ptr_atk_wifi,      0,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_atk_darts,     0,   0,   sp_ptr_msdos,         0,   0
.byte sp_ptr_atk_darts,     0,   0,   sp_ptr_rad,           0,   0
.byte sp_ptr_atk_wifi,      0,   0,   sp_ptr_msdos,         0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_rad,           0,  -2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_skull,         0,   2
.byte $ff

// ANIM_12 "Storm Cloud" — a rain cloud parks over p2, who sinks into gloom
anim12_table:
//      p1x  p1y    p2x  p2y
.byte    60, 150,   200, 130
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_atk_cloud,     0,   0
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_atk_cloud,     0,   2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_atk_cloud,     0,   2
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_frown,         0,   4
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_frown,         0,   2
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_atk_cloud,     0,  -2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_frown,         0,   2
.byte $ff

// ANIM_13 "Yin Spin" — both whirl through the full yin-yang frame set
anim13_table:
//      p1x  p1y    p2x  p2y
.byte    80, 150,   190, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_yin_1,         1,   0,   sp_ptr_yin_1,        -1,   0
.byte sp_ptr_yin_2,         1,   0,   sp_ptr_yin_2,        -1,   0
.byte sp_ptr_yin_3,         1,   0,   sp_ptr_yin_3,        -1,   0
.byte sp_ptr_yin_4,         1,   0,   sp_ptr_yin_4,        -1,   0
.byte sp_ptr_yin_5,        -1,   0,   sp_ptr_yin_5,         1,   0
.byte sp_ptr_yin_6,        -1,   0,   sp_ptr_yin_6,         1,   0
.byte sp_ptr_yin_7,        -1,   0,   sp_ptr_yin_7,         1,   0
.byte sp_ptr_yin_8,        -1,   0,   sp_ptr_yin_8,         1,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_14 "Star Power" — p1 charges up with stars, then unleashes a combo
anim14_table:
//      p1x  p1y    p2x  p2y
.byte    50, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,  -2,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_star,          0,   2,   sp_ptr_body_right_2,  0,   0
.byte sp_ptr_atk_star,      0,  -2,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_star,          0,   2,   sp_ptr_body_right_2,  0,   0
.byte sp_ptr_atk_star,      4,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_atk_star,      4,   0,   sp_ptr_body_right_2,  2,   0
.byte sp_ptr_punch_left,    2,   0,   sp_ptr_body_right_1,  4,  -2
.byte sp_ptr_kick_left,     0,   0,   sp_ptr_body_right_3,  4,   2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_15 "Trash Talk" — a back-and-forth of comic bubbles, poo and frowns
anim15_table:
//      p1x  p1y    p2x  p2y
.byte    60, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_comic_bubble,  0,  -2,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_poo,           0,   2,   sp_ptr_body_right_2,  0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_comic_bubble,  0,  -2
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_frown,         0,   2
.byte sp_ptr_comic_bubble,  0,  -2,   sp_ptr_poo,           0,   0
.byte sp_ptr_frown,         0,   2,   sp_ptr_comic_bubble,  0,  -2
.byte sp_ptr_poo,           0,   0,   sp_ptr_frown,         0,   2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_16 "Avatar Cameo" — p1 morphs through the whole CityXen roster
anim16_table:
//      p1x  p1y    p2x  p2y
.byte    40, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_clicky,            3,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_eagull,            3,   0,   sp_ptr_body_right_2,  0,   0
.byte sp_hg,                3,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_rg5k,              3,   0,   sp_ptr_body_right_2,  0,   0
.byte sp_f1d0,              3,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_trish,             3,   0,   sp_ptr_body_right_2,  0,   0
.byte sp_pokey,             3,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_amy,               3,   0,   sp_ptr_body_right_2,  0,   0
.byte sp_victoria,          3,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_17 "Arrow Volley" — p1 looses arrows and darts, p2 bobs to dodge
anim17_table:
//      p1x  p1y    p2x  p2y
.byte    50, 150,   205, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_punch_left,    0,   0,   sp_ptr_body_right_2,  0,   0
.byte sp_ptr_arrow,         0,   0,   sp_ptr_body_right_1,  0,  -2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_2,  0,   2
.byte sp_ptr_arrow,         0,   0,   sp_ptr_body_right_1,  0,  -2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_2,  0,   2
.byte sp_ptr_atk_darts,     0,   0,   sp_ptr_body_right_1,  0,  -2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_frown,         0,   2
.byte $ff

// ANIM_18 "Center Hug" — both rush to the middle and share hearts
anim18_table:
//      p1x  p1y    p2x  p2y
.byte    40, 150,   210, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   4,   0,   sp_ptr_body_right_1, -4,   0
.byte sp_ptr_body_left_2,   4,   0,   sp_ptr_body_right_2, -4,   0
.byte sp_ptr_body_left_3,   4,   0,   sp_ptr_body_right_3, -4,   0
.byte sp_ptr_body_left_4,   4,   0,   sp_ptr_body_right_4, -4,   0
.byte sp_ptr_center_body,   2,   0,   sp_ptr_center_body,  -2,   0
.byte sp_ptr_center_body,   0,   0,   sp_ptr_center_body,   0,   0
.byte sp_ptr_heart,         0,  -2,   sp_ptr_heart,         0,  -2
.byte sp_ptr_heart,         0,   2,   sp_ptr_heart,         0,   2
.byte sp_ptr_heart,         0,  -2,   sp_ptr_heart,         0,  -2
.byte $ff

// ANIM_19 "Radioactive" — p2 goes critical (rad/skull), p1 backs away
anim19_table:
//      p1x  p1y    p2x  p2y
.byte    60, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_rad,           0,   0
.byte sp_ptr_body_left_2,  -2,   0,   sp_ptr_rad,           0,  -2
.byte sp_ptr_body_left_1,  -2,   0,   sp_ptr_rad,           0,   2
.byte sp_ptr_frown,        -2,   0,   sp_ptr_skull,         0,   0
.byte sp_ptr_body_left_1,  -3,   0,   sp_ptr_rad,           0,  -2
.byte sp_ptr_body_left_2,  -3,   0,   sp_ptr_skull,         0,   2
.byte sp_ptr_body_left_1,  -2,   0,   sp_ptr_rad,           0,   0
.byte $ff

// ANIM_20 "Kick Flurry" — p2 storms in with a flurry of kicks, p1 reels back
anim20_table:
//      p1x  p1y    p2x  p2y
.byte    60, 150,   210, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1, -5,   0
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_body_right_2, -5,   0
.byte sp_ptr_body_left_3,   0,   0,   sp_ptr_body_right_3, -5,   0
.byte sp_ptr_body_left_4,   0,   0,   sp_ptr_body_right_4, -5,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_kick_right,   -3,   0
.byte sp_ptr_body_left_2,  -5,  -2,   sp_ptr_kick_right,    0,   0
.byte sp_ptr_body_left_3,  -5,   2,   sp_ptr_kick_right,    0,   0
.byte sp_ptr_frown,        -3,   0,   sp_ptr_kick_right,    2,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_21 "Jackpot" — both bounce for joy as dollar signs rain down
anim21_table:
//      p1x  p1y    p2x  p2y
.byte    70, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,  -3,   sp_ptr_body_right_1,  0,  -3
.byte sp_ptr_dollar,        0,   3,   sp_ptr_dollar,        0,   3
.byte sp_ptr_body_left_2,   3,  -3,   sp_ptr_body_right_2, -3,  -3
.byte sp_ptr_dollar,        3,   3,   sp_ptr_dollar,       -3,   3
.byte sp_ptr_body_left_1,   3,  -3,   sp_ptr_body_right_1, -3,  -3
.byte sp_ptr_dollar,        3,   3,   sp_ptr_dollar,       -3,   3
.byte sp_ptr_dollar,        0,  -4,   sp_ptr_dollar,        0,  -4
.byte sp_ptr_dollar,        0,   4,   sp_ptr_dollar,        0,   4
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_22 "Blue Screen" — p2 hacks back: p1 glitches into a crash (Wifi Hack mirrored)
anim22_table:
//      p1x  p1y    p2x  p2y
.byte    55, 150,   205, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_body_left_2,   0,   0,   sp_ptr_atk_wifi,      0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_atk_wifi,      0,   0
.byte sp_ptr_msdos,         0,   0,   sp_ptr_atk_darts,     0,   0
.byte sp_ptr_rad,           0,   0,   sp_ptr_atk_darts,     0,   0
.byte sp_ptr_msdos,         0,   0,   sp_ptr_atk_wifi,      0,   0
.byte sp_ptr_rad,           0,  -2,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_skull,         0,   2,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_23 "Leap Frog" — p1 takes a running vault clean over p2's head
anim23_table:
//      p1x  p1y    p2x  p2y
.byte    50, 150,   160, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,  12,  -8,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_body_left_2,  16, -10,   sp_ptr_body_right_2,  0,   0
.byte sp_ptr_body_left_3,  16,  -6,   sp_ptr_body_right_3,  0,   0
.byte sp_ptr_body_left_4,  16,   0,   sp_ptr_body_right_4,  0,   0
.byte sp_ptr_body_left_5,  16,   0,   sp_ptr_body_right_5,  0,   0
.byte sp_ptr_body_left_6,  16,   6,   sp_ptr_body_right_6,  0,   0
.byte sp_ptr_body_left_1,  16,  10,   sp_ptr_body_right_1,  0,   0
.byte sp_ptr_body_left_2,  12,   8,   sp_ptr_body_right_2,  0,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_24 "Frenemies" — a heated glare-off that melts into hearts
anim24_table:
//      p1x  p1y    p2x  p2y
.byte    50, 150,   205, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   5,   0,   sp_ptr_body_right_1, -5,   0
.byte sp_ptr_body_left_2,   5,   0,   sp_ptr_body_right_2, -5,   0
.byte sp_ptr_body_left_3,   5,   0,   sp_ptr_body_right_3, -5,   0
.byte sp_ptr_frown,         0,   0,   sp_ptr_frown,         0,   0
.byte sp_ptr_frown,         0,  -2,   sp_ptr_frown,         0,  -2
.byte sp_ptr_frown,         0,   2,   sp_ptr_frown,         0,   2
.byte sp_ptr_heart,         0,  -2,   sp_ptr_heart,         0,  -2
.byte sp_ptr_heart,         0,   2,   sp_ptr_heart,         0,   2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_25 "Meteor Shower" — stars crash down while both scramble for cover
anim25_table:
//      p1x  p1y    p2x  p2y
.byte    60, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_atk_star,      0,  -8,   sp_ptr_body_right_1, -3,   0
.byte sp_ptr_star,          0,   8,   sp_ptr_body_right_2,  3,   0
.byte sp_ptr_body_left_1,   3,   0,   sp_ptr_atk_star,      0,  -8
.byte sp_ptr_body_left_2,  -3,   0,   sp_ptr_star,          0,   8
.byte sp_ptr_atk_star,      0,  -8,   sp_ptr_atk_star,      0,  -8
.byte sp_ptr_star,          0,   8,   sp_ptr_star,          0,   8
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_26 "Roster Rumble" — p2 morphs through the roster (Avatar Cameo mirrored)
anim26_table:
//      p1x  p1y    p2x  p2y
.byte    60, 150,   215, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,   0,   sp_victoria,         -3,   0
.byte sp_ptr_body_left_2,   0,   0,   sp_amy,              -3,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_pokey,            -3,   0
.byte sp_ptr_body_left_2,   0,   0,   sp_trish,            -3,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_f1d0,             -3,   0
.byte sp_ptr_body_left_2,   0,   0,   sp_rg5k,             -3,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_hg,               -3,   0
.byte sp_ptr_body_left_2,   0,   0,   sp_eagull,           -3,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_clicky,           -3,   0
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_27 "Double KO" — simultaneous haymakers, both turn to skulls and drop
anim27_table:
//      p1x  p1y    p2x  p2y
.byte    45, 150,   210, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   5,   0,   sp_ptr_body_right_1, -5,   0
.byte sp_ptr_body_left_2,   5,   0,   sp_ptr_body_right_2, -5,   0
.byte sp_ptr_body_left_3,   5,   0,   sp_ptr_body_right_3, -5,   0
.byte sp_ptr_body_left_4,   5,   0,   sp_ptr_body_right_4, -5,   0
.byte sp_ptr_punch_left,    2,   0,   sp_ptr_punch_right,  -2,   0
.byte sp_ptr_punch_left,    0,   0,   sp_ptr_punch_right,   0,   0
.byte sp_ptr_skull,        -5,  -4,   sp_ptr_skull,         5,  -4
.byte sp_ptr_skull,        -4,   4,   sp_ptr_skull,         4,   4
.byte sp_ptr_skull,        -2,   6,   sp_ptr_skull,         2,   6
.byte sp_ptr_skull,         0,   0,   sp_ptr_skull,         0,   0
.byte $ff

// ANIM_28 "Victory Dance" — p1 boogies with stars, p2 sulks off stage right
anim28_table:
//      p1x  p1y    p2x  p2y
.byte    70, 150,   200, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   0,  -3,   sp_ptr_frown,         2,   0
.byte sp_ptr_body_left_2,   0,   3,   sp_ptr_frown,         2,   0
.byte sp_ptr_star,          2,  -3,   sp_ptr_body_right_1,  3,   0
.byte sp_ptr_body_left_3,   2,   3,   sp_ptr_body_right_2,  3,   0
.byte sp_ptr_star,         -2,  -3,   sp_ptr_frown,         3,   0
.byte sp_ptr_body_left_4,  -2,   3,   sp_ptr_body_right_1,  3,   0
.byte sp_ptr_star,          0,  -3,   sp_ptr_body_right_2,  3,   0
.byte sp_ptr_body_left_1,   0,   3,   sp_ptr_body_right_1,  0,   0
.byte $ff

// ANIM_29 "Banana Chaos" — bananas everywhere, both fighters wipe out
anim29_table:
//      p1x  p1y    p2x  p2y
.byte    55, 150,   205, 150
//     p1 body            p1dx p1dy   p2 body              p2dx p2dy
.byte sp_ptr_body_left_1,   3,   0,   sp_ptr_body_right_1, -3,   0
.byte sp_ptr_atk_banana,    0,   0,   sp_ptr_body_right_2, -3,   0
.byte sp_ptr_atk_banana,    0,   0,   sp_ptr_atk_banana,    0,   0
.byte sp_ptr_body_left_3,   0,  -4,   sp_ptr_atk_banana,    0,   0
.byte sp_ptr_body_left_5,   2,   2,   sp_ptr_body_right_3,  0,  -4
.byte sp_ptr_skull,         2,   6,   sp_ptr_body_right_5, -2,   2
.byte sp_ptr_skull,         0,   2,   sp_ptr_skull,        -2,   6
.byte sp_ptr_body_left_1,   0,  -4,   sp_ptr_skull,         0,   2
.byte sp_ptr_body_left_1,   0,   0,   sp_ptr_body_right_1,  0,  -4
.byte $ff

//////////////////////////////////////////////////////////////
// Animation registry — drives the main-screen player (press A).
// To add an animation: write a new animN_table above, then add its label and
// name to the four .byte lists and the names below (and bump ANIM_MENU_COUNT).
// The menu shows ANIM_MENU_PAGE_SIZE entries per page, labelled 1-9 then a-f;
// SPACE flips to the next page (wrapping), so any count is reachable.
.const ANIM_MENU_COUNT = 29
.const ANIM_MENU_PAGE_SIZE = 15
anim_menu_base: .byte 0 // registry index of the first entry on the current page
anim_menu_tbl_lo:
.byte <anim1_table,  <anim2_table,  <anim3_table,  <anim4_table,  <anim5_table
.byte <anim6_table,  <anim7_table,  <anim8_table,  <anim9_table,  <anim10_table
.byte <anim11_table, <anim12_table, <anim13_table, <anim14_table, <anim15_table
.byte <anim16_table, <anim17_table, <anim18_table, <anim19_table, <anim20_table
.byte <anim21_table, <anim22_table, <anim23_table, <anim24_table, <anim25_table
.byte <anim26_table, <anim27_table, <anim28_table, <anim29_table
anim_menu_tbl_hi:
.byte >anim1_table,  >anim2_table,  >anim3_table,  >anim4_table,  >anim5_table
.byte >anim6_table,  >anim7_table,  >anim8_table,  >anim9_table,  >anim10_table
.byte >anim11_table, >anim12_table, >anim13_table, >anim14_table, >anim15_table
.byte >anim16_table, >anim17_table, >anim18_table, >anim19_table, >anim20_table
.byte >anim21_table, >anim22_table, >anim23_table, >anim24_table, >anim25_table
.byte >anim26_table, >anim27_table, >anim28_table, >anim29_table
anim_menu_name_lo:
.byte <anim_name_1,  <anim_name_2,  <anim_name_3,  <anim_name_4,  <anim_name_5
.byte <anim_name_6,  <anim_name_7,  <anim_name_8,  <anim_name_9,  <anim_name_10
.byte <anim_name_11, <anim_name_12, <anim_name_13, <anim_name_14, <anim_name_15
.byte <anim_name_16, <anim_name_17, <anim_name_18, <anim_name_19, <anim_name_20
.byte <anim_name_21, <anim_name_22, <anim_name_23, <anim_name_24, <anim_name_25
.byte <anim_name_26, <anim_name_27, <anim_name_28, <anim_name_29
anim_menu_name_hi:
.byte >anim_name_1,  >anim_name_2,  >anim_name_3,  >anim_name_4,  >anim_name_5
.byte >anim_name_6,  >anim_name_7,  >anim_name_8,  >anim_name_9,  >anim_name_10
.byte >anim_name_11, >anim_name_12, >anim_name_13, >anim_name_14, >anim_name_15
.byte >anim_name_16, >anim_name_17, >anim_name_18, >anim_name_19, >anim_name_20
.byte >anim_name_21, >anim_name_22, >anim_name_23, >anim_name_24, >anim_name_25
.byte >anim_name_26, >anim_name_27, >anim_name_28, >anim_name_29
.encoding "petscii_mixed"
anim_menu_title: .text "Trivia Fighters Animations"
.byte 0
anim_menu_prompt: .text "1-9,a-f play, spc next page, q exit"
.byte 0
anim_name_1: .text "Brawl"
.byte 0
anim_name_2: .text "Counter"
.byte 0
anim_name_3: .text "Showdown"
.byte 0
anim_name_4: .text "KO Punch"
.byte 0
anim_name_5: .text "Dizzy"
.byte 0
anim_name_6: .text "Taunt"
.byte 0
anim_name_7: .text "Love"
.byte 0
anim_name_8: .text "Money"
.byte 0
anim_name_9: .text "Lightning Duel"
.byte 0
anim_name_10: .text "Banana Slip"
.byte 0
anim_name_11: .text "Wifi Hack"
.byte 0
anim_name_12: .text "Storm Cloud"
.byte 0
anim_name_13: .text "Yin Spin"
.byte 0
anim_name_14: .text "Star Power"
.byte 0
anim_name_15: .text "Trash Talk"
.byte 0
anim_name_16: .text "Avatar Cameo"
.byte 0
anim_name_17: .text "Arrow Volley"
.byte 0
anim_name_18: .text "Center Hug"
.byte 0
anim_name_19: .text "Radioactive"
.byte 0
anim_name_20: .text "Kick Flurry"
.byte 0
anim_name_21: .text "Jackpot"
.byte 0
anim_name_22: .text "Blue Screen"
.byte 0
anim_name_23: .text "Leap Frog"
.byte 0
anim_name_24: .text "Frenemies"
.byte 0
anim_name_25: .text "Meteor Shower"
.byte 0
anim_name_26: .text "Roster Rumble"
.byte 0
anim_name_27: .text "Double KO"
.byte 0
anim_name_28: .text "Victory Dance"
.byte 0
anim_name_29: .text "Banana Chaos"
.byte 0