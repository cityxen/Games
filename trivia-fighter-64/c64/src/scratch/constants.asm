//////////////////////////////////////////////////////////////
// WHACKADOODLE for C64 by Deadline / CityXen 2024
//
// Cartridge code & Meatloaf support by Jaime Idolpx
//
// Fairground tune by Saul Cross
//
// Thanks to Logg & the Atlanta Historical Computing Society 
// (AHCS) for support and play testing
//
//////////////////////////////////////////////////////////////
// You will need the following repo in order to compile this
// https://github.com/cityxen/Commodore64_Programming
// use -l "path-to-lib" in KickAss command line 
//////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////
// Local Constants

// player initial values
.const PLAYER_INITIAL_HEALTH = 5

// select screen
.const PLAYER_1_SELECT_SCREEN_X = 28 // where to put names
.const PLAYER_1_SELECT_SCREEN_Y = 02
.const PLAYER_2_SELECT_SCREEN_X = 27
.const PLAYER_2_SELECT_SCREEN_Y = 10

// game stuff on
.const PLAYER_1_GAME_SCREEN_X = 28 // where to put names
.const PLAYER_1_GAME_SCREEN_Y = 02
.const PLAYER_2_GAME_SCREEN_X = 27
.const PLAYER_2_GAME_SCREEN_Y = 10

.const GAME_STEP_ANIM_INTRO  = 1
.const GAME_STEP_ROUND_1     = 2
.const GAME_STEP_ANIM_1      = 3
.const GAME_STEP_ROUND_2     = 4
.const GAME_STEP_ANIM_2      = 5
.const GAME_STEP_ROUND_3     = 6
.const GAME_STEP_ANIM_3      = 7
.const GAME_STEP_ROUND_4     = 8
.const GAME_STEP_ANIM_4      = 9
.const GAME_STEP_ROUND_5     = 10
.const GAME_STEP_ANIM_FINISH = 11

//////////////////////////////////////////////////////////////
// Button stuff

.const BUTTON_RED    = $FB // Buttons Stuff
.const BUTTON_GREEN  = $FE
.const BUTTON_YELLOW = $FD
.const BUTTON_BLUE   = $F7
.const BUTTON_WHITE  = $EF

.const BUTTON_LIGHT_GREEN   = %11111110 // Buttons Light / Action
.const BUTTON_LIGHT_YELLOW  = %11111101
.const BUTTON_LIGHT_BLUE    = %11111011
.const BUTTON_LIGHT_RED     = %11110111
.const BUTTON_ACTION_MISS   = %11101111
.const BUTTON_ACTION_POW    = %11011111
.const BUTTON_LIGHT_WHITE   = %10111111
.const BUTTON_ACTION_G_OVER = %01111111
.const BUTTON_LIGHT_ALL     = %00000000
.const BUTTON_LIGHT_NONE    = %11111111
.const BUTTON_ACTIONS       = %10110000
.const BUTTON_LIGHTS        = %01001111
.const FLASH_TIMER_SPEED_CONST = $40

//////////////////////////////////////////////////////////////
// Sprite stuff

.const butt1_sprite_x = 70 // Sprite stuff - > change to sprite locations for fight cuts
.const butt1_sprite_y = 165
.const butt1_sprite_m = 0
.const butt2_sprite_x = 120
.const butt2_sprite_y = 100
.const butt2_sprite_m = 0
.const butt3_sprite_x = 165
.const butt3_sprite_y = 165
.const butt3_sprite_m = 0
.const butt4_sprite_x = 215
.const butt4_sprite_y = 100
.const butt4_sprite_m = 0
.const butt5_sprite_x = 8
.const butt5_sprite_y = 165
.const butt5_sprite_m = 1
.const comic_sprite_x = 165
.const comic_sprite_y = 100

.const sp_pointers  = $c0 // Sprite Pointers
.const sp_happyface = $c0
.const sp_yinyang   = $c1
.const sp_heart     = $c2
.const sp_star      = $c3
.const sp_rad       = $c4
.const sp_skull     = $c5
.const sp_poo       = $c6
.const sp_frown     = $c7
.const sp_commodore = $c8
.const sp_msdos     = $c9
.const sp_dollar    = $ca
.const sp_left      = $cb
.const sp_fire      = $cc
.const sp_miss_l    = $cd
.const sp_miss_r    = $ce
.const sp_comic_m   = $cf
.const sp_pow_l     = $d0
.const sp_pow_r     = $d1
.const sp_plus      = $d2

