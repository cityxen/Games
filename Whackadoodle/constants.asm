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

.const BUTTON_RED    = $FB // Buttons Stuff
.const BUTTON_GREEN  = $FE
.const BUTTON_YELLOW = $FD
.const BUTTON_BLUE   = $F7
.const BUTTON_WHITE  = $EF

.const MODE_EASY     = $00 // 10 Lives, Only Bad Doodles, no speed up
.const MODE_NORMAL   = $01 // 6 Lives, Speed up normal
.const MODE_HARD     = $02 // 3 Lives, Max Speed from start

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

.const doodle_speed_initial = $AF
.const doodle_speed_easy    = $AF
.const doodle_speed_hard    = $30

.const butt1_sprite_x = 70 // Sprite stuff
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
.const FLASH_TIMER_SPEED_CONST = $40

.const GAME_ON_SCORE_LOC_X   = 28
.const GAME_ON_SCORE_LOC_Y   = 02
.const GAME_OVER_SCORE_LOC_X = 27
.const GAME_OVER_SCORE_LOC_Y = 10

.const SFX_GET_READY = $01
.const SFX_DING      = $02
.const SFX_WRONG     = $04
.const SFX_POW       = $05
.const SFX_MISS      = $06
.const SFX_GAME_OVER = $07

