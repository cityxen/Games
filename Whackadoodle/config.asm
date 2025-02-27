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

//////////////////////////////////////////////////////////////
// some inline subroutines

#import "input.il.asm"
#import "sys.il.asm"
#import "print.il.asm"
#import "music.il.asm"
#import "sfxkit.il.asm"
#import "timers.il.asm"
#import "string.il.asm"
#import "score.il.asm"
#import "random.il.asm"

//////////////////////////////////////////////////////////////
// some vars

GAME_NAME:
.encoding "petscii_mixed"
.text "whackadoodle!"
.byte 0

GAME_ML_SHORTCODE:
.encoding "screencode_mixed"
.text "WAD"
.byte 0

dev_mode:               .byte 0
play_music:             .byte 0
sound_playing:          .byte 0
screen_draw:            .byte 0
debug_mode:             .byte 0

whack_mode:             .byte 0 // EASY, NORMAL, HARD
whack_slot: 			.byte 0 // 5 positions for a thing to show up, represented by a byte
whack_hit: 				.byte 0 // which button has been hit (if any)
whack_life:             .byte 0
whack_key:              .byte 0
initial_life:           .byte 6
initial_life_hard:      .byte 3
initial_life_easy:      .byte 10
user_name_start:
.encoding "screencode_mixed"
.text "cityxen"
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
user_name_empty:
.encoding "screencode_mixed"
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
user_name:
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


button_to_hit:          .byte 0
button_actually_hit:    .byte 0
doodle:                 .byte 0
message:                .byte 0
did_hit:                .byte 0

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
msg_mode_easy:
.text "easy"
.byte 0
msg_mode_normal:
.text "normal"
.byte 0
msg_mode_hard:
.text "hard"
.byte 0
msg_mode_mode:
.text "mode:"
.byte 0
