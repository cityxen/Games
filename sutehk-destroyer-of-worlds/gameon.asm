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
    jsr game_animate_player
    jsr game_move_enemies
    jsr game_animate_orbs
    jmp game_loop

//////////////////////////////////////////////////////////////////////////////////////
// game_init_screen: set up screen colors and sprite 0 (sutehk) for the game
game_init_screen:
    lda #$93            // clear screen
    jsr KERNAL_CHROUT
    lda #BLACK
    sta BACKGROUND_COLOR
    sta BORDER_COLOR
    // Enable sprite 0; all sprites multicolor
    lda #%00000001
    sta SPRITE_ENABLE           // orb sprites added dynamically by game_draw_orb_sprites
    lda #%11111111
    sta SPRITE_MULTICOLOR       // all 8 sprites multicolor
    lda #sprite_multicolor_1
    sta SPRITE_MULTICOLOR_0
    lda #sprite_multicolor_2
    sta SPRITE_MULTICOLOR_1
    // Sprite 0 = sutehk (yellow); sprites 1-7 = emerald orbs (green)
    lda #YELLOW
    sta SPRITE_0_COLOR
    lda #GREEN
    sta SPRITE_1_COLOR
    sta SPRITE_2_COLOR
    sta SPRITE_3_COLOR
    sta SPRITE_4_COLOR
    sta SPRITE_5_COLOR
    sta SPRITE_6_COLOR
    sta SPRITE_7_COLOR
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_draw: redraw the entire level, player, and HUD from scratch
game_draw:
    lda #0
    sta gd_row
gd_row_loop:
    // Set up screen/color RAM pointers for both screen rows of this game row
    ldx gd_row
    lda level_row_lo,x
    sta zp_ptr_screen_lo
    lda level_row_hi,x
    sta zp_ptr_screen_hi
    lda level_row2_lo,x
    sta zp_ptr_screen2_lo
    lda level_row2_hi,x
    sta zp_ptr_screen2_hi
    lda color_row_lo,x
    sta zp_ptr_color_lo
    lda color_row_hi,x
    sta zp_ptr_color_hi
    lda color_row2_lo,x
    sta zp_ptr_color2_lo
    lda color_row2_hi,x
    sta zp_ptr_color2_hi

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
    sta gd_screen_col
gd_col_loop:
    // Compute map index = row_base + col
    lda gd_row_base
    clc
    adc gd_col
    tax                 // X = map index

    lda game_map,x
    tax                 // X = OBJ_* type

    ldy gd_screen_col   // Y = tile_col * 2 (left char column)
    lda type_to_tile_tl,x
    sta (zp_ptr_screen),y
    lda type_to_tile_bl,x
    sta (zp_ptr_screen2),y
    lda type_to_color,x
    sta (zp_ptr_color),y
    sta (zp_ptr_color2),y
    iny                 // Y = tile_col * 2 + 1 (right char column)
    lda type_to_tile_tr,x
    sta (zp_ptr_screen),y
    lda type_to_tile_br,x
    sta (zp_ptr_screen2),y
    lda type_to_color,x
    sta (zp_ptr_color),y
    sta (zp_ptr_color2),y

    inc gd_col
    inc gd_screen_col
    inc gd_screen_col   // +2 per tile (2 chars wide)
    lda gd_col
    cmp #LEVEL_W
    beq gd_col_done
    jmp gd_col_loop
gd_col_done:

    inc gd_row
    lda gd_row
    cmp #LEVEL_H
    beq gd_row_done
    jmp gd_row_loop
gd_row_done:

    jsr game_draw_player
    jsr game_draw_hud
    jsr game_draw_orb_sprites
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_draw_player: snap sprite 0 (sutehk) to player_x/y; cancels any animation.
// Called on full redraws, level inits, and restarts. Uses static directional sprite.
game_draw_player:
    // Compute pixel X = player_x * 16 + 24 as 16-bit lo/hi
    lda #0
    sta player_sprite_x_hi
    lda player_x
    asl
    rol player_sprite_x_hi
    asl
    rol player_sprite_x_hi
    asl
    rol player_sprite_x_hi
    asl
    rol player_sprite_x_hi     // hi:A = player_x * 16
    clc
    adc #24
    sta player_sprite_x_lo
    lda player_sprite_x_hi
    adc #0
    sta player_sprite_x_hi

    // Compute pixel Y = player_y * 16 + 90
    lda player_y
    asl
    asl
    asl
    asl
    clc
    adc #90
    sta player_sprite_y

    // Snap target to same position; clear animation
    lda player_sprite_x_lo
    sta player_target_x_lo
    lda player_sprite_x_hi
    sta player_target_x_hi
    lda player_sprite_y
    sta player_target_y
    lda #0
    sta player_is_moving

    // Static directional sprite based on last move direction
    lda move_dy
    bmi gdp_up
    cmp #1
    beq gdp_down
    lda move_dx
    bmi gdp_left
    cmp #1
    beq gdp_right
    lda #sprite_pointer_sutehk_down
    jmp gdp_set_ptr
gdp_up:
    lda #sprite_pointer_sutehk_up
    jmp gdp_set_ptr
gdp_down:
    lda #sprite_pointer_sutehk_down
    jmp gdp_set_ptr
gdp_left:
    lda #sprite_pointer_sutehk_left
    jmp gdp_set_ptr
gdp_right:
    lda #sprite_pointer_sutehk_right
gdp_set_ptr:
    sta SPRITE_0_POINTER

    // Write sprite registers
    lda player_sprite_x_hi
    and #1
    beq gdp_msb_clear
    lda SPRITE_MSB_X
    ora #%00000001
    sta SPRITE_MSB_X
    jmp gdp_write_x
gdp_msb_clear:
    lda SPRITE_MSB_X
    and #%11111110
    sta SPRITE_MSB_X
gdp_write_x:
    lda player_sprite_x_lo
    sta SPRITE_0_X
    lda player_sprite_y
    sta SPRITE_0_Y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_start_player_move: begin smooth glide from player_sprite_x/y to new tile.
// player_x/y already hold the new tile coords. Picks walk frame sprite.
game_start_player_move:
    // Compute target pixel X = player_x * 16 + 24 (16-bit)
    lda #0
    sta player_target_x_hi
    lda player_x
    asl
    rol player_target_x_hi
    asl
    rol player_target_x_hi
    asl
    rol player_target_x_hi
    asl
    rol player_target_x_hi
    clc
    adc #24
    sta player_target_x_lo
    lda player_target_x_hi
    adc #0
    sta player_target_x_hi

    // Compute target pixel Y = player_y * 16 + 90
    lda player_y
    asl
    asl
    asl
    asl
    clc
    adc #90
    sta player_target_y

    // Start animation countdown
    lda #PLAYER_MOVE_STEPS
    sta player_move_steps_rem
    lda #1
    sta player_is_moving

    // Toggle walk frame then pick directional walk sprite
    lda player_walk_frame
    eor #1
    sta player_walk_frame

    lda move_dy
    bmi gspm_up
    cmp #1
    beq gspm_down
    lda move_dx
    bmi gspm_left
    // right
    lda player_walk_frame
    beq gspm_right_f1
    lda #sprite_pointer_sutehk_walk_right_frame2
    jmp gspm_set
gspm_right_f1:
    lda #sprite_pointer_sutehk_walk_right_frame1
    jmp gspm_set
gspm_up:
    lda player_walk_frame
    beq gspm_up_f1
    lda #sprite_pointer_sutehk_walk_up_frame2
    jmp gspm_set
gspm_up_f1:
    lda #sprite_pointer_sutehk_walk_up_frame1
    jmp gspm_set
gspm_down:
    lda player_walk_frame
    beq gspm_down_f1
    lda #sprite_pointer_sutehk_walk_down_frame2
    jmp gspm_set
gspm_down_f1:
    lda #sprite_pointer_sutehk_walk_down_frame1
    jmp gspm_set
gspm_left:
    lda player_walk_frame
    beq gspm_left_f1
    lda #sprite_pointer_sutehk_walk_left_frame2
    jmp gspm_set
gspm_left_f1:
    lda #sprite_pointer_sutehk_walk_left_frame1
gspm_set:
    sta SPRITE_0_POINTER
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_animate_player: step sprite 0 one tick toward player_target; call each loop.
game_animate_player:
    GetTimerTr(TIMER_PLAYER_ANIM)
    bne gap_tick
    rts
gap_tick:
    FullReset(TIMER_PLAYER_ANIM)
    lda player_is_moving
    bne gap_do_step
    rts

gap_do_step:
    lda move_dx
    cmp #1
    beq gap_step_right
    cmp #$ff
    beq gap_step_left
    jmp gap_step_y
gap_step_right:
    lda player_sprite_x_lo
    clc
    adc #PLAYER_MOVE_SPEED
    sta player_sprite_x_lo
    lda player_sprite_x_hi
    adc #0
    sta player_sprite_x_hi
    jmp gap_step_y
gap_step_left:
    lda player_sprite_x_lo
    sec
    sbc #PLAYER_MOVE_SPEED
    sta player_sprite_x_lo
    lda player_sprite_x_hi
    sbc #0
    sta player_sprite_x_hi

gap_step_y:
    lda move_dy
    cmp #1
    beq gap_step_down
    cmp #$ff
    beq gap_step_up
    jmp gap_check_done
gap_step_down:
    lda player_sprite_y
    clc
    adc #PLAYER_MOVE_SPEED
    sta player_sprite_y
    jmp gap_check_done
gap_step_up:
    lda player_sprite_y
    sec
    sbc #PLAYER_MOVE_SPEED
    sta player_sprite_y

gap_check_done:
    dec player_move_steps_rem
    bne gap_write_pos

    // Arrived: snap exact, clear flag, switch to static sprite
    lda player_target_x_lo
    sta player_sprite_x_lo
    lda player_target_x_hi
    sta player_sprite_x_hi
    lda player_target_y
    sta player_sprite_y
    lda #0
    sta player_is_moving

    lda move_dy
    bmi gap_static_up
    cmp #1
    beq gap_static_down
    lda move_dx
    bmi gap_static_left
    cmp #1
    beq gap_static_right
    lda #sprite_pointer_sutehk_down
    jmp gap_set_sprite
gap_static_up:
    lda #sprite_pointer_sutehk_up
    jmp gap_set_sprite
gap_static_down:
    lda #sprite_pointer_sutehk_down
    jmp gap_set_sprite
gap_static_left:
    lda #sprite_pointer_sutehk_left
    jmp gap_set_sprite
gap_static_right:
    lda #sprite_pointer_sutehk_right
gap_set_sprite:
    sta SPRITE_0_POINTER

gap_write_pos:
    lda player_sprite_x_hi
    and #1
    beq gap_msb_clear
    lda SPRITE_MSB_X
    ora #%00000001
    sta SPRITE_MSB_X
    jmp gap_write_x
gap_msb_clear:
    lda SPRITE_MSB_X
    and #%11111110
    sta SPRITE_MSB_X
gap_write_x:
    lda player_sprite_x_lo
    sta SPRITE_0_X
    lda player_sprite_y
    sta SPRITE_0_Y
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
// draw_map_cell: draw 2x2 game_map tile at (tmp_x, tmp_y) to screen+color RAM
draw_map_cell:
    jsr map_get_type    // A = OBJ_* type at (tmp_x, tmp_y)
    tax                 // X = type

    ldy tmp_y
    lda level_row_lo,y
    sta zp_ptr_screen_lo
    lda level_row_hi,y
    sta zp_ptr_screen_hi
    lda level_row2_lo,y
    sta zp_ptr_screen2_lo
    lda level_row2_hi,y
    sta zp_ptr_screen2_hi
    lda color_row_lo,y
    sta zp_ptr_color_lo
    lda color_row_hi,y
    sta zp_ptr_color_hi
    lda color_row2_lo,y
    sta zp_ptr_color2_lo
    lda color_row2_hi,y
    sta zp_ptr_color2_hi

    // Screen col = tmp_x * 2
    lda tmp_x
    asl
    tay
    lda type_to_tile_tl,x
    sta (zp_ptr_screen),y
    lda type_to_tile_bl,x
    sta (zp_ptr_screen2),y
    lda type_to_color,x
    sta (zp_ptr_color),y
    sta (zp_ptr_color2),y
    iny
    lda type_to_tile_tr,x
    sta (zp_ptr_screen),y
    lda type_to_tile_br,x
    sta (zp_ptr_screen2),y
    lda type_to_color,x
    sta (zp_ptr_color),y
    sta (zp_ptr_color2),y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_draw_hud: draw title banner, level number, RITES count, restart hint
game_draw_hud:
    // Title at row 1, col 6
    ldx #1
    ldy #6
    clc
    jsr KERNAL_PLOT
    Print(str_title)

    // Level label at row 3, col 1
    ldx #3
    ldy #1
    clc
    jsr KERNAL_PLOT
    Print(str_level_lbl)
    // Level number 1-indexed; levels 10-15 (current_level 9-14) print two digits
    lda current_level
    cmp #9
    bcc gdh_lv_single       // current_level < 9: single digit
    lda #'1'
    jsr KERNAL_CHROUT
    lda current_level
    sec
    sbc #9                  // A = current_level - 9 (0 for lvl10 ... 5 for lvl15)
    clc
    adc #'0'                // -> '0'..'5'
    jsr KERNAL_CHROUT
    jmp gdh_lv_done
gdh_lv_single:
    clc
    adc #'1'                // current_level 0-8 -> '1'-'9'
    jsr KERNAL_CHROUT
gdh_lv_done:

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

    // Restart/quit hint at row 3, col 28
    ldx #3
    ldy #28
    clc
    jsr KERNAL_PLOT
    Print(str_restart_lbl)
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
    lda player_is_moving    // block new input while sprite is gliding
    beq !+
    jmp gi_done
!:

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
    bne gi_check_restart
    lda #1
    sta move_dx
    lda #0
    sta move_dy
    jmp gi_do_move

gi_check_restart:
    cmp #KEY_R
    bne gi_check_quit
    jsr game_restart_level
    jmp gi_done

gi_check_quit:
    cmp #KEY_Q
    bne gi_done
    jmp mainmenu

gi_do_move:
    jsr game_try_move

gi_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_restart_level: reload current level and redraw from scratch
game_restart_level:
    jsr game_init_screen
    jsr init_level
    jsr game_draw
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

    // Lever: player steps on it to toggle and move there
    cmp #OBJ_LEVER_UP
    beq gtm_lever
    cmp #OBJ_LEVER_DOWN
    beq gtm_lever

    // Pushable: ORB, STATUE, RELIC, PYRAMID - try to slide it
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
    jsr game_start_player_move
    jsr game_draw_orb_sprites
    jsr game_check_win

gtm_fail:
    rts

gtm_new_x: .byte 0
gtm_new_y: .byte 0
gtm_lev_x: .byte 0
gtm_lev_y: .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// gtm_lever: player steps on lever — toggle lever state and its target cell
// tmp_x/y = lever tile position (where player will move)
gtm_lever:
    lda tmp_x
    sta gtm_lev_x
    lda tmp_y
    sta gtm_lev_y
    jsr map_get_type          // A = current lever type (LEVER_UP or LEVER_DOWN)
    cmp #OBJ_LEVER_UP
    beq gtm_lev_activate

    // LEVER_DOWN → LEVER_UP: close (target becomes wall)
    lda #OBJ_LEVER_UP
    sta map_val
    jsr map_set_type
    jsr draw_map_cell
    lda #OBJ_WALL
    sta map_val
    jmp gtm_lev_target

gtm_lev_activate:
    // LEVER_UP → LEVER_DOWN: open (target becomes floor)
    lda #OBJ_LEVER_DOWN
    sta map_val
    jsr map_set_type
    jsr draw_map_cell
    lda #OBJ_FLOOR
    sta map_val

gtm_lev_target:
    lda lever_target_x
    sta tmp_x
    lda lever_target_y
    sta tmp_y
    jsr map_set_type
    jsr draw_map_cell

    lda gtm_lev_x
    sta tmp_x
    lda gtm_lev_y
    sta tmp_y
    jmp gtm_move

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

//////////////////////////////////////////////////////////////////////////////////////
// game_animate_orbs: flip animation frame on the enemy-move timer tick
game_animate_orbs:
    GetTimerTr(TIMER_ENEMY_MOVE)
    bne gao_tick
    rts
gao_tick:
    FullReset(TIMER_ENEMY_MOVE)
    lda orb_anim_frame
    eor #1
    sta orb_anim_frame
    jmp game_draw_orb_sprites

//////////////////////////////////////////////////////////////////////////////////////
// game_draw_orb_sprites: scan map for OBJ_ORB/OBJ_RELIC, place as sprites 1-7
// Uses current orb_anim_frame (emerald frame1 or frame2). Does NOT toggle it.
game_draw_orb_sprites:
    // Choose emerald sprite pointer from current animation frame
    lda orb_anim_frame
    bne gdos_frame2
    lda #sprite_pointer_emerald_frame1
    jmp gdos_ptr_set
gdos_frame2:
    lda #sprite_pointer_emerald_frame2
gdos_ptr_set:
    sta gdos_cur_ptr

    // Init: sprite 0 = player (always on); sprites 1+ assigned to orbs found
    lda #1
    sta gdos_sprite_num
    lda #%00000001              // start with only sprite 0 enabled
    sta gdos_enable_mask
    lda SPRITE_MSB_X
    and #%00000001              // preserve player sprite 0 X-MSB
    sta gdos_msb_mask

    lda #0
    sta gdos_row
gdos_outer:
    lda gdos_row
    asl
    asl
    sta gdos_tmp
    lda gdos_row
    asl
    asl
    asl
    asl
    clc
    adc gdos_tmp
    sta gdos_row_base

    lda #0
    sta gdos_col
gdos_inner:
    lda gdos_row_base
    clc
    adc gdos_col
    tax
    lda game_map,x
    cmp #OBJ_ORB
    beq gdos_is_orb
    cmp #OBJ_RELIC
    beq gdos_is_orb
    cmp #OBJ_STATUE
    beq gdos_is_statue
    cmp #OBJ_PYRAMID
    beq gdos_is_pyramid
    cmp #OBJ_LEVER_UP
    beq gdos_is_lever_up
    cmp #OBJ_LEVER_DOWN
    beq gdos_is_lever_down
    jmp gdos_next_col

gdos_is_orb:
    lda gdos_cur_ptr
    sta gdos_place_ptr
    lda #GREEN
    sta gdos_place_color
    jmp gdos_check_slot

gdos_is_statue:
    lda #sprite_pointer_statue
    sta gdos_place_ptr
    lda #WHITE
    sta gdos_place_color
    jmp gdos_check_slot

gdos_is_pyramid:
    lda #sprite_pointer_pyramid
    sta gdos_place_ptr
    lda #YELLOW
    sta gdos_place_color
    jmp gdos_check_slot

gdos_is_lever_up:
    lda #sprite_pointer_lever_up
    sta gdos_place_ptr
    lda #ORANGE
    sta gdos_place_color
    jmp gdos_check_slot

gdos_is_lever_down:
    lda #sprite_pointer_lever_down
    sta gdos_place_ptr
    lda #ORANGE
    sta gdos_place_color

gdos_check_slot:
    lda gdos_sprite_num
    cmp #8
    bne gdos_place
    jmp gdos_apply              // all 7 sprite slots used

gdos_place:
    asl                         // A = sprite_num * 2
    sta gdos_sprite_reg_off

    // Set sprite pointer and color
    ldx gdos_sprite_num
    lda gdos_place_ptr
    sta SPRITE_POINTERS,x
    lda gdos_place_color
    sta SPRITE_COLORS,x

    // Sprite Y = row * 16 + 90
    lda gdos_row
    asl
    asl
    asl
    asl
    clc
    adc #90
    ldx gdos_sprite_reg_off
    sta SPRITE_LOCATIONS+1,x

    // Sprite X MSB: col >= 15 needs bit set in SPRITE_MSB_X
    lda gdos_col
    cmp #15
    bcc gdos_x_lo
    ldy gdos_sprite_num
    lda sprite_bit_tbl,y
    ora gdos_msb_mask
    sta gdos_msb_mask

gdos_x_lo:
    // Sprite X lo = col * 16 + 24
    lda gdos_col
    asl
    asl
    asl
    asl
    clc
    adc #24
    ldx gdos_sprite_reg_off
    sta SPRITE_LOCATIONS,x

    // Accumulate enable bit for this sprite
    ldy gdos_sprite_num
    lda sprite_bit_tbl,y
    ora gdos_enable_mask
    sta gdos_enable_mask

    inc gdos_sprite_num

gdos_next_col:
    inc gdos_col
    lda gdos_col
    cmp #LEVEL_W
    beq gdos_end_col
    jmp gdos_inner
gdos_end_col:
    inc gdos_row
    lda gdos_row
    cmp #LEVEL_H
    beq gdos_apply
    jmp gdos_outer

gdos_apply:
    lda gdos_enable_mask
    sta SPRITE_ENABLE
    lda gdos_msb_mask
    sta SPRITE_MSB_X
    rts
