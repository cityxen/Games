//////////////////////////////////////////////////////////////////
// some inline subroutines

#import "../../Commodore64_Programming/include/sys.il.asm"
#import "../../Commodore64_Programming/include/print.il.asm"

//////////////////////////////////////////////////////////////////
// some vars

whack_mode:             .byte 0 // BAR
                                // KIDS
                                // WIN
                                // HARD
                                // EASY

whack_slot: 			.byte 0 // 5 positions for a thing to show up, represented by a byte
whack_hit: 				.byte 0 // which button has been hit (if any)
whack_score_lo:         .byte 0
whack_score_hi:         .byte 0
whack_score_1:			.byte $30 // 6 bytes simple score for now, maybe highscores later
whack_score_2:          .byte $30
whack_score_3:			.byte $30
whack_score_4:          .byte $30
whack_score_5:			.byte $30
whack_score_6:			.byte $30

whack_life:             .byte 0

whack_key:              .byte 0
initial_life:           .byte 6
initial_life_hard:      .byte 3
initial_life_easy:
initial_life_win:
initial_life_kids:      .byte 10
up:                     .byte 0
down:                   .byte 0
left:                   .byte 0
right:                  .byte 0
button:                 .byte 0

irq_timer_jitter_cmp:   .byte 20
irq_timer_jitter:       .byte 0
irq_timer1:             .byte 0
irq_timer2:             .byte 0
irq_timer3:             .byte 0
irq_timer4:             .byte 0
irq_timer5:             .byte 0
irq_timer_sound:        .byte 0
sound_playing:          .byte 0
irq_timer_joystick:     .byte 0
irq_timer_allow_input:  .byte 0
trig_1:                 .byte 0
trig_2:                 .byte 0
trig_3:                 .byte 0
trig_4:                 .byte 0
trig_sound:             .byte 0
trig_joystick:          .byte 0
trig_jitter:            .byte 0
trig_input:             .byte 0
play_music:             .byte 0
timer_instruct:         .byte 0
timer_instruct2:        .byte 0
timer_instruct3:        .byte 0
screen_draw:            .byte 0
button_flash_state:     .byte 0
button_to_hit:          .byte 0
button_actually_hit:    .byte 0
doodle:                 .byte 0
message:                .byte 0
did_hit:                .byte 0
random_num:             .byte 0
countdown_text: 
.byte $1e,KEY_HOME,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte 0
msg_init:
.byte 5,KEY_HOME,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte 0
msg1:
.text "GET READY"
.byte 0
msg2:
.text "   MISS"
.byte 0
msg3:
.text "   POW"
.byte 0
msg4:
.text "  WRONG!"
.byte 0
msg_clr:
.text "             "
.byte 0


msg_mode_win:
.text "win!"
.byte 0
msg_mode_bar:
.text "bar"
.byte 0
msg_mode_hard:
.text "hard"
.byte 0
msg_mode_kids:
.text "kids"
.byte 0
msg_mode_easy:
.text "easy"
.byte 0
msg_mode_mode:
.text "mode:"
.byte 0

hiscore_msg:

.text "   TOP 10 WHACKADOODLE HI SCORES"
.byte $ff

meatloaf_hiscore_support:
.byte 0

