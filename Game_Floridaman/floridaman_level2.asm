.segment Level2 [allowOverlap]
*=C_LEVEL_ROUTINE "LEVEL 2 ROUTINE"
    lda #$93; jsr KERNAL_CHROUT
	jmp over_level_2_message
level_2_message: .text level_list.get(2); .byte 0
over_level_2_message:
    PrintAtRainbow(10,24,level_2_message)

level_2_game_loop:
	jsr sub_read_joystick_2
	jsr sub_update_hud
	jsr sub_move_player
	jmp level_2_game_loop


