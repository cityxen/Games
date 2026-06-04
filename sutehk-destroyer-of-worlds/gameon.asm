//////////////////////////////////////////////////////////////////////////////////////
// SUTEHK: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//////////////////////////////////////////////////////////////////////////////////////
// gameon.asm - Main game loop, input, push/match logic

//////////////////////////////////////////////////////////////////////////////////////
// gameon: entry point from main menu
gameon:
    lda #0
    sta current_level
    jsr game_init_screen
    jsr init_level
    jsr init_exit
    jsr game_draw

game_loop:
    jsr game_input
    jsr game_animate_player
    jsr game_move_enemies
    jsr game_animate_orbs
    jsr game_bat_update
    jmp game_loop

//////////////////////////////////////////////////////////////////////////////////////
// game_erase_player: restore map tile at player's current position
game_erase_player:
    lda player_x
    sta tmp_x
    lda player_y
    sta tmp_y
    jmp draw_map_cell   // tail call

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
    jsr init_exit
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

    // Exit wall
    cmp #OBJ_EXIT_CLOSED
    beq gtm_fail
    cmp #OBJ_EXIT_OPEN
    beq gtm_advance

    // Pushable: ORB, STATUE, RELIC, PYRAMID - try to slide it
    jsr game_push_sliding
    bcc gtm_fail        // carry clear = blocked, can't push

    // Push succeeded: player steps into the object's ORIGIN tile
    lda gps_origin_x
    sta tmp_x
    lda gps_origin_y
    sta tmp_y

gtm_move:
    lda tmp_x
    sta gtm_new_x
    lda tmp_y
    sta gtm_new_y
    jsr game_erase_player
    lda gtm_new_x
    sta player_x
    lda gtm_new_y
    sta player_y
    jsr game_start_player_move
    jsr game_draw_orb_sprites
    jsr game_check_win

gtm_fail:
    rts

gtm_advance:
    jsr game_advance_level
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
// Returns: carry set = object moved (success); carry clear = immediately blocked
game_push_sliding:
    lda tmp_x
    sta gps_origin_x
    lda tmp_y
    sta gps_origin_y
    jsr map_get_type
    sta gps_obj_type

    lda gps_origin_x
    sta gps_slide_x
    lda gps_origin_y
    sta gps_slide_y

gps_slide_loop:
    lda gps_slide_x
    clc
    adc move_dx
    sta gps_next_x
    lda gps_slide_y
    clc
    adc move_dy
    sta gps_next_y

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
    lda gps_slide_x
    cmp gps_origin_x
    bne gps_not_stuck
    lda gps_slide_y
    cmp gps_origin_y
    bne gps_not_stuck
    clc
    rts

gps_not_stuck:
    lda gps_origin_x
    sta tmp_x
    lda gps_origin_y
    sta tmp_y
    lda #OBJ_FLOOR
    sta map_val
    jsr map_set_type
    jsr draw_map_cell

    lda gps_slide_x
    sta tmp_x
    lda gps_slide_y
    sta tmp_y

    // --- Match logic ---

    lda gps_obj_type
    cmp gps_blocker_type
    bne gps_check_relic_orb

    cmp #OBJ_RELIC
    beq gps_relic_relic

    // ORB+ORB or STATUE+STATUE: both disappear, match+1
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
    // RELIC+RELIC: no match, place at stop position
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
    // RELIC hits ORB
    lda gps_obj_type
    cmp #OBJ_RELIC
    bne gps_check_orb_relic
    lda gps_blocker_type
    cmp #OBJ_ORB
    bne gps_no_match
    inc match_count
    jsr game_draw_hud
    sec
    rts

gps_check_orb_relic:
    // ORB hits RELIC
    lda gps_obj_type
    cmp #OBJ_ORB
    bne gps_no_match
    lda gps_blocker_type
    cmp #OBJ_RELIC
    bne gps_no_match
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
// game_check_win: show rites-complete message and open exit when match_goal met
game_check_win:
    lda match_count
    cmp match_goal
    bcc gcw_no_win

    lda exit_open
    bne gcw_no_win      // already triggered

    ldx #12
    ldy #9
    clc
    jsr KERNAL_PLOT
    Print(str_level_complete)

    jsr game_open_exit

gcw_no_win:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_open_exit: change exit tile to OBJ_EXIT_OPEN and redraw it
game_open_exit:
    lda exit_open
    bne goe_done
    lda #1
    sta exit_open
    lda exit_x
    sta tmp_x
    lda exit_y
    sta tmp_y
    lda #OBJ_EXIT_OPEN
    sta map_val
    jsr map_set_type
    jsr draw_map_cell
    jsr game_draw_orb_sprites
goe_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_advance_level: move to next level; wraps to level 1 after final level
game_advance_level:
    inc current_level
    lda current_level
    cmp #LEVEL_COUNT
    bcc gal_load
    ldx #12
    ldy #8
    clc
    jsr KERNAL_PLOT
    Print(str_game_complete)
gal_wait_end:
    jsr KERNAL_GETIN
    cmp #0
    beq gal_wait_end
    lda #0
    sta current_level
gal_load:
    jsr game_init_screen
    jsr init_level
    jsr init_exit
    jsr game_draw
    rts

//////////////////////////////////////////////////////////////////////////////////////
// init_exit: pick a random OBJ_WALL tile and replace with OBJ_EXIT_CLOSED
init_exit:
    lda #0
    sta exit_open
    // LCG: next = prev*5 + 7 (keeps seed nonzero)
    lda exit_rng
    asl
    asl
    clc
    adc exit_rng
    clc
    adc #7
    sta exit_rng
    bne ie_nz
    inc exit_rng
ie_nz:
    lda #0
    sta exit_tmp_count
    ldx #0
ie_count:
    lda game_map,x
    cmp #OBJ_WALL
    bne ie_count_next
    inc exit_tmp_count
ie_count_next:
    inx
    cpx #200
    bne ie_count
    lda exit_tmp_count
    beq ie_no_walls
    lda exit_rng
ie_mod:
    cmp exit_tmp_count
    bcc ie_mod_done
    sec
    sbc exit_tmp_count
    jmp ie_mod
ie_mod_done:
    sta exit_wall_idx
    ldx #0
ie_find:
    lda game_map,x
    cmp #OBJ_WALL
    bne ie_find_next
    lda exit_wall_idx
    beq ie_found
    dec exit_wall_idx
ie_find_next:
    inx
    cpx #200
    bne ie_find
    jmp ie_no_walls
ie_found:
    lda #0
    sta exit_y
    txa
ie_divx:
    cmp #20
    bcc ie_divx_done
    sec
    sbc #20
    inc exit_y
    jmp ie_divx
ie_divx_done:
    sta exit_x
    lda exit_x
    sta tmp_x
    lda exit_y
    sta tmp_y
    lda #OBJ_EXIT_CLOSED
    sta map_val
    jsr map_set_type
ie_no_walls:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_move_enemies: stub for enemy movement (no enemies in levels 1-3)
game_move_enemies:
    lda enemy_count
    beq gme_done
    // TODO: enemy movement (Lesser Servants) - levels with enemies coming soon
gme_done:
    rts
