//////////////////////////////////////////////////////////////////
// INLINE SUBROUTINES & VARS

#import "../../Commodore64_Programming/include/sys.il.asm"
#import "../../Commodore64_Programming/include/print.il.asm"

///////////////////////////////
// SYSTEM STUFF

DEBUG_MODE:             .byte 0
SCREEN_DRAW:            .byte 0
MESSAGE:                .byte 0
DID_HIT:                .byte 0
RANDOM_NUM:             .byte 0
GAME_MODE:              .byte 0

///////////////////////////////
// AUDIO STUFF

DEV_PLAY_MUSIC:         .byte 1
PLAY_MUSIC:             .byte 0
SOUND_PLAYING:          .byte 0

///////////////////////////////
// PLAYER STUFF

PLAYER_LIFE:            .byte 0
PLAYER_MANA:            .byte 0
PLAYER_LOC_X:           .byte 0
PLAYER_LOC_Y:           .byte 0
PLAYER_LOC_Z:           .byte 0

///////////////////////////////
// INPUT STUFF

UP:                     .byte 0
DOWN:                   .byte 0
LEFT:                   .byte 0
RIGHT:                  .byte 0
BUTTON:                 .byte 0


///////////////////////////////
// TIMER STUFF

IRQ_TIMER_JITTER_CMP:   .byte 20
IRQ_TIMER_JITTER:       .byte 0
IRQ_TIMER1:             .byte 0
IRQ_TIMER2:             .byte 0
IRQ_TIMER3:             .byte 0
IRQ_TIMER4:             .byte 0
IRQ_TIMER5:             .byte 0
IRQ_TIMER_SOUND:        .byte 0
IRQ_TIMER_JOYSTICK:     .byte 0
IRQ_TIMER_ALLOW_INPUT:  .byte 0
TRIG_1:                 .byte 0
TRIG_2:                 .byte 0
TRIG_3:                 .byte 0
TRIG_4:                 .byte 0
TRIG_SOUND:             .byte 0
TRIG_JOYSTICK:          .byte 0
TRIG_JITTER:            .byte 0
TRIG_INPUT:             .byte 0
TIMER_INSTRUCT:         .byte 0
TIMER_INSTRUCT2:        .byte 0
TIMER_INSTRUCT3:        .byte 0
