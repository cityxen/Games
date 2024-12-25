//////////////////////////////////////////////////////////////////
// LOCAL CONSTANTS

///////////////////////////////
// SYSTEM STUFF

.const MODE_EASY    = $00
.const MODE_NORMAL  = $01
.const MODE_HARD    = $02
.const SCORE_LOC_X  = 28
.const SCORE_LOC_Y  = 02

///////////////////////////////
// INPUT STUFF

.const JOY1_LEFT    = $FB
.const JOY1_UP      = $FE
.const JOY1_DOWN    = $FD
.const JOY1_RIGHT   = $F7
.const JOY1_FIRE    = $EF

///////////////////////////////
// PLAYER STUFF

.const PLAYER_INITIAL_LIFE = 10
.const PLAYER_INITIAL_MANA = 10

///////////////////////////////
// SPRITE STUFF

.const butt1_sprite_x = 70
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

///////////////////////////////
// SPRITE POINTERS

.const sp_pointers  = $c0
.const sp_happyface = $c0
.const sp_yinyang   = $c1
.const sp_heart     = $c2
.const sp_star      = $c3
.const sp_rad       = $c4
.const sp_skull     = $c5
.const sp_poo       = $c6
.const sp_frown     = $c7
.const sp_up        = $c8
.const sp_right     = $c9
.const sp_down      = $ca
.const sp_left      = $cb
.const sp_fire      = $cc
.const sp_miss_l    = $cd
.const sp_miss_r    = $ce
.const sp_comic_m   = $cf
.const sp_pow_l     = $d0
.const sp_pow_r     = $d1
.const sp_plus      = $d2
.const FLASH_TIMER_SPEED_CONST = $40
