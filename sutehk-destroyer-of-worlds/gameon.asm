//////////////////////////////////////////////////////////////////////////////////////
// SUTEKH: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//////////////////////////////////////////////////////////////////////////////////////
// gameon.asm - Main game loop, input, push/match logic, draw routines

//////////////////////////////////////////////////////////////////////////////////////
// gameon: entry point from main menu
gameon:
    lda #0
    sta current_level
    jsr game_init_screen
    jsr init_level
    jsr game_draw

game_loop:
    jsr game_input
    jsr game_move_enemies
    jmp game_loop

//////////////////////////////////////////////////////////////////////////////////////
// game_init_screen: set up screen colors for the game
game_init_screen:
    lda #$93            // clear screen
    jsr KERNAL_CHROUT
    lda #BLACK
    sta BACKGROUND_COLOR
    sta BORDER_COLOR
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_draw: redraw the entire level, player, and HUD from scratch
game_draw:
    lda #0
    sta gd_row
gd_row_loop:
    // Set up screen/color RAM pointers for this row
    ldx gd_row
    lda level_row_lo,x
    sta zp_ptr_screen_lo
    lda level_row_hi,x
    sta zp_ptr_screen_hi
    lda color_row_lo,x
    sta zp_ptr_color_lo
    lda color_row_hi,x
    sta zp_ptr_color_hi

    // Compute row_base = row * 20 (for indexing into game_map)
    lda gd_row
    asl                 // *2
    asl                 // *4
    sta gd_tmp
    lda gd_row
    asl                 // *2
    asl                 // *4
    asl                 // *8
    asl                 // *16
    clc
    adc gd_tmp          // *16 + *4 = *20
    sta gd_row_base

    lda #0
    sta gd_col
gd_col_loop:
    // Compute map index = row_base + col
    lda gd_row_base
    clc
    adc gd_col
    tax                 // X = map index

    lda game_map,x
    tax                 // X = OBJ_* type

    ldy gd_col
    lda type_to_tile,x
    sta (zp_ptr_screen),y
    lda type_to_color,x
    sta (zp_ptr_color),y

    inc gd_col
    lda gd_col
    cmp #LEVEL_W
    bne gd_col_loop

    inc gd_row
    lda gd_row
    cmp #LEVEL_H
    bne gd_row_loop

    jsr game_draw_player
    jsr game_draw_hud
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_draw_player: draw @ at player_x, player_y
game_draw_player:
    ldy player_y
    lda level_row_lo,y
    sta zp_ptr_screen_lo
    lda level_row_hi,y
    sta zp_ptr_screen_hi
    lda color_row_lo,y
    sta zp_ptr_color_lo
    lda color_row_hi,y
    sta zp_ptr_color_hi
    ldy player_x
    lda #TILE_PLAYER
    sta (zp_ptr_screen),y
    lda #YELLOW
    sta (zp_ptr_color),y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_erase_player: restore map tile at player's current position
game_erase_player:
    lda player_x
    sta tmp_x
    lda player_y
    sta tmp_y
    jmp draw_map_cell   // tail call

//////////////////////////////////////////////////////////////////////////////////////
// draw_map_cell: draw game_map tile at (tmp_x, tmp_y) to screen+color RAM
draw_map_cell:
    jsr map_get_type    // A = OBJ_* type at (tmp_x, tmp_y)
    tax                 // X = type

    ldy tmp_y
    lda level_row_lo,y
    sta zp_ptr_screen_lo
    lda level_row_hi,y
    sta zp_ptr_screen_hi
    lda color_row_lo,y
    sta zp_ptr_color_lo
    lda color_row_hi,y
    sta zp_ptr_color_hi

    ldy tmp_x
    lda type_to_tile,x
    sta (zp_ptr_screen),y
    lda type_to_color,x
    sta (zp_ptr_color),y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_draw_hud: draw title banner and RITES count
game_draw_hud:
    // Title at row 1, col 6
    ldx #1
    ldy #6
    clc
    jsr KERNAL_PLOT
    Print(str_title)

    // RITES label at row 3, col 14
    ldx #3
    ldy #14
    clc
    jsr KERNAL_PLOT
    Print(str_rites_lbl)

    // Match count digit
    lda match_count
    clc
    adc #'0'
    jsr KERNAL_CHROUT

    Print(str_slash)

    // Match goal digit
    lda match_goal
    clc
    adc #'0'
    jsr KERNAL_CHROUT
    rts

//////////////////////////////////////////////////////////////////////////////////////
// map_get_type: return A = game_map[tmp_y * LEVEL_W + tmp_x]
// Clobbers: A, X (result in A). tmp_x, tmp_y must be set.
map_get_type:
    lda tmp_y
    asl                 // *2
    asl                 // *4
    sta map_tmp
    lda tmp_y
    asl                 // *2
    asl                 // *4
    asl                 // *8
    asl                 // *16
    clc
    adc map_tmp         // *20
    clc
    adc tmp_x
    tax
    lda game_map,x
    rts

//////////////////////////////////////////////////////////////////////////////////////
// map_set_type: game_map[tmp_y * LEVEL_W + tmp_x] = map_val
// Set map_val before calling. Clobbers: A, X.
map_set_type:
    lda tmp_y
    asl
    asl
    sta map_tmp
    lda tmp_y
    asl
    asl
    asl
    asl
    clc
    adc map_tmp
    clc
    adc tmp_x
    tax
    lda map_val
    sta game_map,x
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_input: read joystick 2 and keyboard, attempt player move on timer tick
game_input:
    GetTimerTr(TIMER_INPUT)
    bne !+
    jmp gi_done
!:    
    FullReset(TIMER_INPUT)

    // Read joystick port 2 directly ($DC00)
    // Bits: 0=up 1=down 2=left 3=right 4=fire (active LOW)
    lda JOYSTICK_PORT_2
    sta gi_joy

    and #%00000001          // UP
    bne gi_check_down
    lda #0
    sta move_dx
    lda #$FF                // dy = -1
    sta move_dy
    jmp gi_do_move

gi_check_down:
    lda gi_joy
    and #%00000010          // DOWN
    bne gi_check_left
    lda #0
    sta move_dx
    lda #1
    sta move_dy
    jmp gi_do_move

gi_check_left:
    lda gi_joy
    and #%00000100          // LEFT
    bne gi_check_right
    lda #$FF                // dx = -1
    sta move_dx
    lda #0
    sta move_dy
    jmp gi_do_move

gi_check_right:
    lda gi_joy
    and #%00001000          // RIGHT
    bne gi_check_keys
    lda #1
    sta move_dx
    lda #0
    sta move_dy
    jmp gi_do_move

gi_check_keys:
    // Keyboard fallback: WASD
    jsr KERNAL_GETIN
    cmp #KEY_W
    bne !+
    lda #0
    sta move_dx
    lda #$FF
    sta move_dy
    jmp gi_do_move
!:
    cmp #KEY_S
    bne !+
    lda #0
    sta move_dx
    lda #1
    sta move_dy
    jmp gi_do_move
!:
    cmp #KEY_A
    bne !+
    lda #$FF
    sta move_dx
    lda #0
    sta move_dy
    jmp gi_do_move
!:
    cmp #KEY_D
    bne gi_done
    lda #1
    sta move_dx
    lda #0
    sta move_dy

gi_do_move:
    jsr game_try_move

gi_done:
    rts

gi_joy: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// game_try_move: attempt to move player in direction (move_dx, move_dy)
game_try_move:
    // Compute candidate new position
    lda player_x
    clc
    adc move_dx
    sta tmp_x
    lda player_y
    clc
    adc move_dy
    sta tmp_y

    // Look up what's at the new position
    jsr map_get_type    // A = type

    cmp #OBJ_WALL
    beq gtm_fail
    cmp #OBJ_GATE
    beq gtm_fail
    cmp #OBJ_ENEMY
    beq gtm_fail

    // OBJ_FLOOR or OBJ_NONE: just move
    cmp #OBJ_FLOOR
    beq gtm_move
    cmp #OBJ_NONE
    beq gtm_move

    // Pushable: ORB, STATUE, RELIC - try to slide it
    jsr game_push_sliding
    bcc gtm_fail        // carry clear = blocked, can't push

    // Push succeeded: player steps into the object's ORIGIN tile
    // (game_push_sliding overwrites tmp_x/y, so restore from gps_origin_x/y)
    lda gps_origin_x
    sta tmp_x
    lda gps_origin_y
    sta tmp_y

gtm_move:
    // Save new position (tmp_x/y) before game_erase_player overwrites them
    lda tmp_x
    sta gtm_new_x
    lda tmp_y
    sta gtm_new_y
    jsr game_erase_player   // erases @ at current player_x/y; trashes tmp_x/y
    lda gtm_new_x
    sta player_x
    lda gtm_new_y
    sta player_y
    jsr game_draw_player
    jsr game_check_win

gtm_fail:
    rts

gtm_new_x: .byte 0
gtm_new_y: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// game_push_sliding: slide the object at (tmp_x,tmp_y) in (move_dx,move_dy)
//
// The object slides until it hits a non-floor cell.
// Match logic is applied when it stops adjacent to another object.
//
// Returns: carry set = object moved (success); carry clear = immediately blocked
//
// Side effects: modifies game_map, match_count; calls draw_map_cell
game_push_sliding:
    // Save origin and object type
    lda tmp_x
    sta gps_origin_x
    lda tmp_y
    sta gps_origin_y
    jsr map_get_type
    sta gps_obj_type

    // Init slide position to origin
    lda gps_origin_x
    sta gps_slide_x
    lda gps_origin_y
    sta gps_slide_y

gps_slide_loop:
    // Advance one step
    lda gps_slide_x
    clc
    adc move_dx
    sta gps_next_x
    lda gps_slide_y
    clc
    adc move_dy
    sta gps_next_y

    // Check what's at next position
    lda gps_next_x
    sta tmp_x
    lda gps_next_y
    sta tmp_y
    jsr map_get_type
    sta gps_blocker_type

    cmp #OBJ_FLOOR
    beq gps_advance
    cmp #OBJ_NONE
    beq gps_advance
    jmp gps_found_blocker

gps_advance:
    lda gps_next_x
    sta gps_slide_x
    lda gps_next_y
    sta gps_slide_y
    jmp gps_slide_loop

gps_found_blocker:
    // gps_slide_x/y = last floor position (stop position)
    // gps_next_x/y  = blocker position
    // gps_blocker_type = type at blocker

    // Immediately blocked if stop == origin
    lda gps_slide_x
    cmp gps_origin_x
    bne gps_not_stuck
    lda gps_slide_y
    cmp gps_origin_y
    bne gps_not_stuck
    clc
    rts

gps_not_stuck:
    // Clear the origin tile
    lda gps_origin_x
    sta tmp_x
    lda gps_origin_y
    sta tmp_y
    lda #OBJ_FLOOR
    sta map_val
    jsr map_set_type
    jsr draw_map_cell

    // Restore tmp_x/y to stop position for further use
    lda gps_slide_x
    sta tmp_x
    lda gps_slide_y
    sta tmp_y

    // --- Match logic ---

    // Case: same type?
    lda gps_obj_type
    cmp gps_blocker_type
    bne gps_check_relic_orb

    // Same type - check if RELIC (RELIC+RELIC = no match)
    cmp #OBJ_RELIC
    beq gps_relic_relic

    // ORB+ORB or STATUE+STATUE: both disappear, match+1
    // Origin already cleared. Clear the blocker too.
    lda gps_next_x
    sta tmp_x
    lda gps_next_y
    sta tmp_y
    lda #OBJ_FLOOR
    sta map_val
    jsr map_set_type
    jsr draw_map_cell
    inc match_count
    jsr game_draw_hud
    sec
    rts

gps_relic_relic:
    // RELIC+RELIC: no match, place RELIC at stop position
    lda gps_slide_x
    sta tmp_x
    lda gps_slide_y
    sta tmp_y
    lda #OBJ_RELIC
    sta map_val
    jsr map_set_type
    jsr draw_map_cell
    sec
    rts

gps_check_relic_orb:
    // Case: RELIC hits ORB (RELIC slides, blocker is ORB)
    lda gps_obj_type
    cmp #OBJ_RELIC
    bne gps_check_orb_relic
    lda gps_blocker_type
    cmp #OBJ_ORB
    bne gps_no_match
    // RELIC vanishes, ORB stays at blocker position: already correct (origin cleared)
    inc match_count
    jsr game_draw_hud
    sec
    rts

gps_check_orb_relic:
    // Case: ORB hits RELIC (ORB slides, blocker is RELIC)
    lda gps_obj_type
    cmp #OBJ_ORB
    bne gps_no_match
    lda gps_blocker_type
    cmp #OBJ_RELIC
    bne gps_no_match
    // ORB lands at stop, RELIC at blocker disappears
    lda gps_slide_x
    sta tmp_x
    lda gps_slide_y
    sta tmp_y
    lda #OBJ_ORB
    sta map_val
    jsr map_set_type
    jsr draw_map_cell
    lda gps_next_x
    sta tmp_x
    lda gps_next_y
    sta tmp_y
    lda #OBJ_FLOOR
    sta map_val
    jsr map_set_type
    jsr draw_map_cell
    inc match_count
    jsr game_draw_hud
    sec
    rts

gps_no_match:
    // No interaction: place object at stop position
    lda gps_slide_x
    sta tmp_x
    lda gps_slide_y
    sta tmp_y
    lda gps_obj_type
    sta map_val
    jsr map_set_type
    jsr draw_map_cell
    sec
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_check_win: check if match_count >= match_goal; advance level on win
game_check_win:
    lda match_count
    cmp match_goal
    bcc gcw_no_win      // A < goal: not done yet

    // Win! Show message at center of screen
    ldx #12
    ldy #9
    clc
    jsr KERNAL_PLOT
    Print(str_level_complete)

    // Pause briefly then wait for any key/fire
gcw_wait:
    jsr KERNAL_GETIN
    cmp #0
    bne gcw_advance
    lda JOYSTICK_PORT_2
    and #%00010000      // fire button
    beq gcw_advance     // fire pressed (active low)
    jmp gcw_wait

gcw_advance:
    inc current_level
    lda current_level
    cmp #LEVEL_COUNT
    bcc gcw_load
    // All levels done
    ldx #12
    ldy #8
    clc
    jsr KERNAL_PLOT
    Print(str_game_complete)
gcw_wait_end:
    jsr KERNAL_GETIN
    cmp #0
    beq gcw_wait_end
    lda #0
    sta current_level   // wrap back to level 1

gcw_load:
    jsr game_init_screen
    jsr init_level
    jsr game_draw

gcw_no_win:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_move_enemies: stub for enemy movement (no enemies in levels 1-3)
game_move_enemies:
    lda enemy_count
    beq gme_done
    // TODO: enemy movement (Lesser Servants) - levels with enemies coming soon
gme_done:
    rts
