.segment DefaultLevel [allowOverlap]
*=C_LEVEL_ROUTINE "DEFAULT LEVEL ROUTINE" // THIS IS A DUMMY FILLER LEVEL IN CASE LEVEL LOADING FAILS
    lda #$93; jsr KERNAL_CHROUT
	jmp over_level_message
level_message: .text "ERROR!"; .byte 0
over_level_message:
	PrintAtRainbow(10,24,level_message)

default_game_loop:
	jsr sub_read_joystick_2
	jsr sub_update_hud
	jsr sub_move_player
	jmp default_game_loop

#import "floridaman_level1.asm"
#import "floridaman_level2.asm"

