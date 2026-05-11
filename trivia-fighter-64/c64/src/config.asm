//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////

#importonce

//////////////////////////////////////////////////////////////
// some inline subroutines

#import "constants.asm"
#import "sys.il.asm"
#import "print.il.asm"
#import "input.il.asm"
#import "disk.il.asm"
#import "music.il.asm"
#import "sfxkit.il.asm"
#import "timers.il.asm"
#import "string.il.asm"
#import "score.il.asm"
#import "random.il.asm"
#import "meatloaf.il.asm"
#import "honkheckbutt.il.asm"
        


//////////////////////////////////////////////////////////////
// Sprite stuff

.const sprite_mc1 = 11
.const sprite_mc2 = 12


// sprite locations for select char screen

.const select_sprite_0_x = 50
.const select_sprite_0_y = 167
.const select_sprite_0_m = 0
.const select_sprite_1_x = 85
.const select_sprite_1_y = 167
.const select_sprite_1_m = 0
.const select_sprite_2_x = 120
.const select_sprite_2_y = 167
.const select_sprite_2_m = 0
.const select_sprite_3_x = 225
.const select_sprite_3_y = 167
.const select_sprite_3_m = 0
.const select_sprite_4_x = 5
.const select_sprite_4_y = 167
.const select_sprite_4_m = 1
.const select_sprite_5_x = 40
.const select_sprite_5_y = 167
.const select_sprite_5_m = 1
.const select_sprite_6_x = 160
.const select_sprite_6_y = 160
.const select_sprite_6_m = 0
.const select_sprite_7_x = 180
.const select_sprite_7_y = 180
.const select_sprite_7_m = 0

.const sp_disk_load_x = 165
.const sp_disk_load_y = 100

.const sp_pointers  = $c0 // Sprite Pointers
.const sp_happyface = $c0

.const sp_hg        = $c0
.const sp_eagull    = $c1
.const sp_clicky    = $c2
.const sp_rg5k      = $c3
.const sp_msdos     = $c4
.const sp_f1d0      = $c5
.const sp_trish     = $c6
.const sp_pokey     = $c7
.const sp_amy       = $c8
.const sp_victoria  = $c9
.const sp_disk_load = $ca


//////////////////////////////////////////////////////////////
// Local Constants

// player initial values
.const PLAYER_INITIAL_HEALTH = 5

// select screen
.const PLAYER_1_SELECT_SCREEN_X = 4 // where to put names
.const PLAYER_1_SELECT_SCREEN_Y = 12
.const PLAYER_2_SELECT_SCREEN_X = 26
.const PLAYER_2_SELECT_SCREEN_Y = 12

// game on
.const PLAYER_1_GAME_SCREEN_X = 1 // where to put names
.const PLAYER_1_GAME_SCREEN_Y = 2
.const PLAYER_2_GAME_SCREEN_X = 10
.const PLAYER_2_GAME_SCREEN_Y = 2

game_step:              .byte 0
game_step_t:
.encoding "petscii_upper"
.text "GAME STEP"
.byte 0

.const GAME_STEP_SELECT_     = 0
.const GAME_STEP_SELECT      = 1
.const GAME_STEP_ANIM_INTRO_ = 2
.const GAME_STEP_ANIM_INTRO  = 3
.const GAME_STEP_ROUND_1_    = 4
.const GAME_STEP_ROUND_1     = 5
.const GAME_STEP_ANIM_1_     = 6
.const GAME_STEP_ANIM_1      = 7
.const GAME_STEP_ROUND_2_    = 8
.const GAME_STEP_ROUND_2     = 9
.const GAME_STEP_ANIM_2_     = 10
.const GAME_STEP_ANIM_2      = 11
.const GAME_STEP_ROUND_3_    = 12
.const GAME_STEP_ROUND_3     = 13
.const GAME_STEP_ANIM_3_     = 14
.const GAME_STEP_ANIM_3      = 15
.const GAME_STEP_ROUND_4_    = 16
.const GAME_STEP_ROUND_4     = 17
.const GAME_STEP_ANIM_4_     = 18
.const GAME_STEP_ANIM_4      = 19
.const GAME_STEP_ROUND_5_    = 20
.const GAME_STEP_ROUND_5     = 21
.const GAME_STEP_ANIM_FINISH_= 22
.const GAME_STEP_ANIM_FINISH = 23

anim_text:
.encoding "petscii_mixed"
.text "Insert visually stunning anim here!"
.byte 0

// CityXen Avatars
.const CXN_AVATAR_CLICKY   = 0
cxn_avatar_clicky_t:
.encoding "petscii_upper"
.text "CLICKY    "
.byte 0
.const CXN_AVATAR_EAGULL   = 1
cxn_avatar_eagull_t:
.text "EAGULL    "
.byte 0
.const CXN_AVATAR_HG       = 2
cxn_avatar_hg_t:
.text "HELMET GUY"
.byte 0
.const CXN_AVATAR_RG5K     = 3
cxn_avatar_rg5k_t:
.text "ROBOGUY 5K"
.byte 0
.const CXN_AVATAR_MSDOS    = 4
cxn_avatar_msdos_t:
.text "MISS DOS  "
.byte 0
.const CXN_AVATAR_F1D0     = 5
cxn_avatar_f1d0_t:
.text "F1D0      "
.byte 0
.const CXN_AVATAR_TRISH    = 6
cxn_avatar_trish_t:
.text "TRISH     "
.byte 0
.const CXN_AVATAR_POKEY    = 7
cxn_avatar_pokey_t:
.text "POKEY     "
.byte 0
.const CXN_AVATAR_AMY      = 8
cxn_avatar_amy_t:
.text "AMY       "
.byte 0
.const CXN_AVATAR_VICTORIA = 9
cxn_avatar_victoria_t:
.text "VICTORIA  "
.byte 0

.const CXN_AVATAR_END = 10

cxn_avatar_t:
.word cxn_avatar_clicky_t
.word cxn_avatar_eagull_t
.word cxn_avatar_hg_t
.word cxn_avatar_rg5k_t
.word cxn_avatar_msdos_t
.word cxn_avatar_f1d0_t
.word cxn_avatar_trish_t
.word cxn_avatar_pokey_t
.word cxn_avatar_amy_t
.word cxn_avatar_victoria_t

cxn_avatar_t_i:
.byte 0,2,4,6,8,10,12,14,16,18

cxn_avatar_sprite_pointer_i:
.byte sp_clicky,sp_eagull,sp_hg,sp_rg5k,sp_msdos,sp_f1d0,sp_trish,sp_pokey,sp_amy,sp_victoria

cxn_avatar_sprite_color_i:
.byte GREEN,ORANGE,WHITE,RED,RED,GREEN,YELLOW,BLUE,LIGHT_RED,LIGHT_RED

.const print_pointer_lo = $fa
.const print_pointer_hi = $fb

game_anim: .byte 0

.const cxn_avatar_selected_p1  = %00000001
.const cxn_avatar_selected_p2  = %00000010
.const cxn_avatar_selected_both= %00000011
cxn_avatar_selected: .byte 0

//////////////////////////////////////////////////////////////
// Button stuff


.const FLASH_TIMER_SPEED_CONST = $40

//////////////////////////////////////////////////////////////
// some vars

GAME_NAME:
.encoding "petscii_mixed"
.text "trivia fighters 64!"
.byte 0

offline_trivia_file:    .byte 0  // load from disk (from random)
offline_trivia_q:       .byte 0  // there will be 2 questions in the block this will determine which (from 2nd random)

ml_total_trivia:        .byte 0
                        .byte 0
ml_total_trivia_text: .text "triva count:"
.byte 0

trivia_round_text: .text "Round:"
.byte 0

number_of_players:      .byte 0

dev_mode:               .byte 0
play_music:             .byte 0
sound_playing:          .byte 0
screen_draw:            .byte 0
debug_mode:             .byte 0

player_1_avatar:        .byte 0
player_1_healthbar:     .byte 0

player_2_avatar:        .byte 0
player_2_healthbar:     .byte 0

game_round_total:       .byte 5
game_round_current:     .byte 0

trivia_category_total:  .byte 5

trivia_question_current:.byte 0

trivia_current_question:.byte 0 // current question 0-250 (255 if it is a meatloaf question)
trivia_current_category:.byte 0 // 

button_did_hit: .byte 0
button_actually_hit: .byte 0
message: .byte 0

countdown_text: 
.byte $1e,KEY_HOME,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte 0
msg_init:
.byte 5,KEY_HOME,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte 0
msg_getready:
.encoding "screencode_mixed"
.text "GET READY"
.byte 0
msg_miss:
.text "   MISS"
.byte 0
msg_pow:
.text "   POW"
.byte 0
msg_wrong:
.text "  WRONG!"
.byte 0
msg_clr:
.encoding "petscii_mixed"
.text "             "
.byte 0

