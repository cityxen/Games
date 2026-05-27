//////////////////////////////////////////////////////////////////////////////////////
// ROGUE ENGINE 64 - C64
// gameon.asm - Game loop, input, combat, enemy AI, draw, HUD
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////
// gameon_start: entry point from main menu or new floor
gameon_start:
    lda #$93
    jsr KERNAL_CHROUT
    lda #BLACK
    sta BACKGROUND_COLOR
    sta BORDER_COLOR

    // Fresh game: reset player stats on floor 1
    lda player_floor
    cmp #1
    bne go_no_reset
    lda #20
    sta player_hp
    sta player_max_hp
    lda #3
    sta player_atk
    lda #1
    sta player_def

go_no_reset:
    lda #0
    sta game_state
    sta msg_active

    jsr dungeon_new
    jsr game_draw_all

game_loop:
    jsr game_input
    lda game_state
    bne game_loop_end

    IfTimerJmp(TIMER_ENEMY_MOVE, game_loop_enemy_tick)

game_loop_msg:
    lda msg_active
    beq game_loop
    GetTimerTr(TIMER_MSG_CLEAR)
    beq game_loop
    FullReset(TIMER_MSG_CLEAR)
    jsr game_clear_message
    jmp game_loop

game_loop_enemy_tick:
    jsr game_move_enemies
    jsr game_draw_all
    jmp game_loop_msg

game_loop_end:
    // Dead (1) or won (2)
    lda game_state
    cmp #1
    bne go_win
    PrintXY(str_dead, 7, 22)
    jmp go_final_wait
go_win:
    PrintXY(str_win, 8, 22)
go_final_wait:
    jsr KERNAL_GETIN
    cmp #0
    beq go_final_wait
    lda #1
    sta player_floor
    jmp mainmenu

//////////////////////////////////////////////////////////////////////////////////////
// game_input: poll keyboard (WASD/cursors) and joystick port 2; act on first input.
game_input:
    GetTimerTr(TIMER_INPUT)
    bne gi_active
    rts
gi_active:
    FullReset(TIMER_INPUT)

    jsr KERNAL_GETIN
    sta g_tmp

    lda g_tmp
    cmp #KEY_W
    beq gi_up
    cmp #KEY_S
    beq gi_down
    cmp #KEY_A
    beq gi_left
    cmp #KEY_D
    beq gi_right
    cmp #KEY_CURSOR_UP
    beq gi_up
    cmp #KEY_CURSOR_DOWN
    beq gi_down
    cmp #KEY_CURSOR_LEFT
    beq gi_left
    cmp #KEY_CURSOR_RIGHT
    beq gi_right

    // Joystick port 2 — $DC00 doubles as keyboard column register, so write $FF
    // (deselect all columns) before reading, guarded by sei/cli to prevent the
    // KERNAL IRQ from clobbering $DC00 between the write and read.
    sei
    lda #$FF
    sta JOYSTICK_PORT_2
    lda JOYSTICK_PORT_2
    cli
    tax
    and #%00000001
    beq gi_up
    txa
    and #%00000010
    beq gi_down
    txa
    and #%00000100
    beq gi_left
    txa
    and #%00001000
    beq gi_right
    jmp gi_done         // no input matched

gi_up:
    lda player_y
    beq gi_done
    sec
    sbc #1
    sta move_new_y
    lda player_x
    sta move_new_x
    jsr game_try_move
    jmp gi_done
gi_down:
    lda player_y
    cmp #(MAP_H-1)
    beq gi_done
    clc
    adc #1
    sta move_new_y
    lda player_x
    sta move_new_x
    jsr game_try_move
    jmp gi_done
gi_left:
    lda player_x
    beq gi_done
    sec
    sbc #1
    sta move_new_x
    lda player_y
    sta move_new_y
    jsr game_try_move
    jmp gi_done
gi_right:
    lda player_x
    cmp #(MAP_W-1)
    beq gi_done
    clc
    adc #1
    sta move_new_x
    lda player_y
    sta move_new_y
    jsr game_try_move

gi_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_try_move: attempt to move player to (move_new_x, move_new_y).
game_try_move:
    // Check each monster: if at new position, attack instead of moving
    ldx #0
gtm_mon_scan:
    cpx #MAX_MONSTERS
    beq gtm_tile_check
    lda monster_alive,x
    beq gtm_mon_next
    lda monster_x,x
    cmp move_new_x
    bne gtm_mon_next
    lda monster_y,x
    cmp move_new_y
    bne gtm_mon_next
    stx g_idx
    jsr game_attack_monster
    jsr game_draw_all
    rts
gtm_mon_next:
    inx
    jmp gtm_mon_scan

gtm_tile_check:
    lda move_new_x
    sta zp_tmp
    lda move_new_y
    sta zp_tmp_hi
    jsr dungeon_get_cell        // A = tile type
    cmp #TILE_WALL
    beq gtm_blocked

    // Pick up any item at destination
    jsr game_check_item_pickup

    // Reload tile to check for stairs
    lda move_new_x
    sta zp_tmp
    lda move_new_y
    sta zp_tmp_hi
    jsr dungeon_get_cell
    cmp #TILE_STAIRS
    bne gtm_do_move
    jsr game_next_floor
    rts

gtm_do_move:
    // Erase player from old cell
    lda player_x
    sta zp_tmp
    lda player_y
    sta zp_tmp_hi
    jsr draw_map_cell

    lda move_new_x
    sta player_x
    lda move_new_y
    sta player_y

    jsr draw_player_at_pos
    jsr game_draw_hud
    rts

gtm_blocked:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_attack_monster: attack monster at g_idx. Shows hit message, applies damage.
game_attack_monster:
    ldx g_idx
    lda monster_type,x
    cmp #MTYPE_RAT
    bne gam_bat
    jsr msg_hit_rat
    jmp gam_damage
gam_bat:
    cmp #MTYPE_BAT
    bne gam_gob
    jsr msg_hit_bat
    jmp gam_damage
gam_gob:
    jsr msg_hit_gob

gam_damage:
    lda #3
    jsr get_random_range
    clc
    adc player_atk
    sta g_dmg

    ldx g_idx
    lda monster_hp,x
    sec
    sbc g_dmg
    bcs gam_wounded
    lda #0
gam_wounded:
    sta monster_hp,x
    bne gam_counter            // monster still alive → counter-attack
    lda #0
    sta monster_alive,x
    jsr msg_enemy_slain
    rts

gam_counter:
    jsr game_monster_retaliates
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_monster_retaliates: monster at g_idx attacks the player back.
game_monster_retaliates:
    ldx g_idx
    lda monster_type,x
    tay
    lda monster_atk_tbl,y
    sta g_dmg

    lda #2
    jsr get_random_range
    clc
    adc g_dmg
    sec
    sbc player_def
    bcs gmr_min_ok
    lda #1
gmr_min_ok:
    sta g_dmg

    lda player_hp
    sec
    sbc g_dmg
    bcs gmr_alive
    lda #0
gmr_alive:
    sta player_hp
    jsr msg_got_hit
    lda player_hp
    bne gmr_done
    lda #1
    sta game_state           // player dead
gmr_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_check_item_pickup: collect item at (move_new_x, move_new_y) if any.
game_check_item_pickup:
    ldx #0
gcip_scan:
    cpx #MAX_ITEMS
    beq gcip_done
    lda item_active,x
    beq gcip_next
    lda item_x,x
    cmp move_new_x
    bne gcip_next
    lda item_y,x
    cmp move_new_y
    bne gcip_next

    // Found item — apply effect
    lda item_type,x
    bne gcip_weapon

    // Potion: +5 HP capped at max
    lda player_hp
    clc
    adc #5
    cmp player_max_hp
    bcc gcip_hp_set
    lda player_max_hp
gcip_hp_set:
    sta player_hp
    jsr msg_potion
    jmp gcip_deactivate

gcip_weapon:
    inc player_atk
    jsr msg_weapon

gcip_deactivate:
    lda #0
    sta item_active,x
    rts

gcip_next:
    inx
    jmp gcip_scan
gcip_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_next_floor: descend stairs; win on floor 6.
game_next_floor:
    inc player_floor
    lda player_floor
    cmp #6
    bne gnf_go
    lda #2
    sta game_state           // win
    rts
gnf_go:
    jsr msg_stairs
    jsr dungeon_new
    jsr game_draw_all
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_move_enemies: each alive monster moves one step toward the player.
// Horizontal movement is tried first; vertical if horizontal is blocked.
// Bumping the player causes an attack rather than a move.
game_move_enemies:
    lda #0
    sta g_idx

gme_loop:
    ldx g_idx
    cpx #MAX_MONSTERS
    bne gme_body
    jmp gme_done
gme_body:
    lda monster_alive,x
    bne gme_alive
    jmp gme_next
gme_alive:
    // Compute dx sign: player_x - monster_x[g_idx]
    lda player_x
    sec
    sbc monster_x,x
    bmi gme_dx_neg
    beq gme_dx_zero
    lda #1
    jmp gme_dx_ok
gme_dx_neg:
    lda #$ff
    jmp gme_dx_ok
gme_dx_zero:
    lda #0
gme_dx_ok:
    sta g_tmp               // dx sign ($01=right, $ff=left, $00=none)

    // Compute dy sign: player_y - monster_y[g_idx]
    ldx g_idx
    lda player_y
    sec
    sbc monster_y,x
    bmi gme_dy_neg
    beq gme_dy_zero
    lda #1
    jmp gme_dy_ok
gme_dy_neg:
    lda #$ff
    jmp gme_dy_ok
gme_dy_zero:
    lda #0
gme_dy_ok:
    sta g_tmp2              // dy sign

    // --- Try horizontal move ---
    lda g_tmp
    beq gme_try_v           // dx=0, skip horizontal

    ldx g_idx
    lda monster_x,x
    clc
    adc g_tmp               // add signed $01 or $FF
    sta move_new_x
    lda monster_y,x
    sta move_new_y

    // Attack player if adjacent (target = player pos)
    lda move_new_x
    cmp player_x
    bne gme_h_not_player
    lda move_new_y
    cmp player_y
    bne gme_h_not_player
    jsr game_monster_retaliates
    jmp gme_next

gme_h_not_player:
    // Save dx/dy around gme_try_pos (it clobbers g_tmp via zp_tmp/dungeon_get_cell)
    lda g_tmp
    pha
    lda g_tmp2
    pha
    jsr gme_try_pos         // carry set = blocked
    pla
    sta g_tmp2
    pla
    sta g_tmp
    bcs gme_try_v           // horizontal blocked, try vertical
    jmp gme_do_move

    // --- Try vertical move ---
gme_try_v:
    lda g_tmp2
    beq gme_next            // dy=0 too, monster truly stuck

    ldx g_idx
    lda monster_y,x
    clc
    adc g_tmp2
    sta move_new_y
    lda monster_x,x
    sta move_new_x

    lda move_new_x
    cmp player_x
    bne gme_v_not_player
    lda move_new_y
    cmp player_y
    bne gme_v_not_player
    jsr game_monster_retaliates
    jmp gme_next

gme_v_not_player:
    lda g_tmp
    pha
    lda g_tmp2
    pha
    jsr gme_try_pos
    pla
    sta g_tmp2
    pla
    sta g_tmp
    bcs gme_next            // vertical also blocked

gme_do_move:
    ldx g_idx
    lda move_new_x
    sta monster_x,x
    lda move_new_y
    sta monster_y,x

gme_next:
    inc g_idx
    jmp gme_loop
gme_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// gme_try_pos: check if (move_new_x, move_new_y) is passable for a monster.
// Uses X register as internal loop counter (preserves g_idx memory var).
// Returns: carry clear = passable, carry set = blocked.
gme_try_pos:
    lda move_new_x
    bmi gtp_blocked
    cmp #MAP_W
    bcs gtp_blocked
    lda move_new_y
    bmi gtp_blocked
    cmp #MAP_H
    bcs gtp_blocked

    lda move_new_x
    sta zp_tmp
    lda move_new_y
    sta zp_tmp_hi
    jsr dungeon_get_cell
    cmp #TILE_WALL
    beq gtp_blocked

    // Check no other alive monster occupies this position (skip self = g_idx)
    ldx #0
gtp_scan:
    cpx #MAX_MONSTERS
    beq gtp_pass
    lda monster_alive,x
    beq gtp_scan_next
    txa
    cmp g_idx
    beq gtp_scan_next       // skip the monster we are moving
    lda monster_x,x
    cmp move_new_x
    bne gtp_scan_next
    lda monster_y,x
    cmp move_new_y
    beq gtp_blocked
gtp_scan_next:
    inx
    jmp gtp_scan
gtp_pass:
    clc
    rts
gtp_blocked:
    sec
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_draw_all: full redraw — 2x2 map tiles, then entity overlays (TL only), HUD.
game_draw_all:
    lda #0
    sta gd_y
gda_row:
    lda gd_y
    cmp #MAP_H
    bne gda_row_body
    jmp gda_items
gda_row_body:
    ldx gd_y
    lda map_row_lo,x
    sta zp_ptr_map_lo
    lda map_row_hi,x
    sta zp_ptr_map_hi
    lda screen_row_lo,x
    sta zp_ptr_screen_lo
    lda screen_row_hi,x
    sta zp_ptr_screen_hi
    lda screen_row2_lo,x
    sta zp_ptr_screen2_lo
    lda screen_row2_hi,x
    sta zp_ptr_screen2_hi
    lda color_row_lo,x
    sta zp_ptr_color_lo
    lda color_row_hi,x
    sta zp_ptr_color_hi
    lda color_row2_lo,x
    sta zp_ptr_color2_lo
    lda color_row2_hi,x
    sta zp_ptr_color2_hi

    lda #0
    sta g_tmp               // map column counter (0..MAP_W-1)
gda_col:
    lda g_tmp
    cmp #MAP_W
    bne gda_col_body
    jmp gda_next_row
gda_col_body:
    ldy g_tmp
    lda (zp_ptr_map),y      // tile type
    tax

    lda g_tmp
    asl                     // screen col = map_col * 2
    tay

    lda tile_char_tbl,x     // same char for all 4 quadrants
    sta (zp_ptr_screen),y   // TL
    iny
    sta (zp_ptr_screen),y   // TR
    dey
    sta (zp_ptr_screen2),y  // BL
    iny
    sta (zp_ptr_screen2),y  // BR
    dey
    lda tile_color_tbl,x    // same color for all 4 quadrants
    sta (zp_ptr_color),y
    iny
    sta (zp_ptr_color),y
    dey
    sta (zp_ptr_color2),y
    iny
    sta (zp_ptr_color2),y

    inc g_tmp
    jmp gda_col

gda_next_row:
    inc gd_y
    jmp gda_row

    // Overlay items: entity char at TL quadrant (screen col = item_x*2)
gda_items:
    ldx #0
gda_items_loop:
    cpx #MAX_ITEMS
    bne gda_items_body
    jmp gda_monsters
gda_items_body:
    lda item_active,x
    bne gda_item_active
    jmp gda_item_next
gda_item_active:
    lda item_y,x
    tay
    lda screen_row_lo,y
    sta zp_ptr_screen_lo
    lda screen_row_hi,y
    sta zp_ptr_screen_hi
    lda screen_row2_lo,y
    sta zp_ptr_screen2_lo
    lda screen_row2_hi,y
    sta zp_ptr_screen2_hi
    lda color_row_lo,y
    sta zp_ptr_color_lo
    lda color_row_hi,y
    sta zp_ptr_color_hi
    lda color_row2_lo,y
    sta zp_ptr_color2_lo
    lda color_row2_hi,y
    sta zp_ptr_color2_hi
    lda item_type,x
    sta g_dmg           // save type for color lookup
    asl
    asl                 // type * 4
    tay
    lda item_chars_potion,y
    sta g_tmp
    iny
    lda item_chars_potion,y
    sta g_tr
    iny
    lda item_chars_potion,y
    sta g_bl
    iny
    lda item_chars_potion,y
    sta g_br
    ldy g_dmg
    lda item_color_tbl,y
    sta g_tmp2
    lda item_x,x
    asl                     // screen col = item_x * 2
    tay
    lda g_tmp
    sta (zp_ptr_screen),y   // TL
    iny
    lda g_tr
    sta (zp_ptr_screen),y   // TR
    dey
    lda g_bl
    sta (zp_ptr_screen2),y  // BL
    iny
    lda g_br
    sta (zp_ptr_screen2),y  // BR
    dey
    lda g_tmp2
    sta (zp_ptr_color),y
    iny
    sta (zp_ptr_color),y
    dey
    sta (zp_ptr_color2),y
    iny
    sta (zp_ptr_color2),y
gda_item_next:
    inx
    jmp gda_items_loop

    // Overlay monsters: entity char at TL quadrant
gda_monsters:
    ldx #0
gda_mons_loop:
    cpx #MAX_MONSTERS
    bne gda_mons_body
    jmp gda_player
gda_mons_body:
    lda monster_alive,x
    beq gda_mon_next
    lda monster_y,x
    tay
    lda screen_row_lo,y
    sta zp_ptr_screen_lo
    lda screen_row_hi,y
    sta zp_ptr_screen_hi
    lda screen_row2_lo,y
    sta zp_ptr_screen2_lo
    lda screen_row2_hi,y
    sta zp_ptr_screen2_hi
    lda color_row_lo,y
    sta zp_ptr_color_lo
    lda color_row_hi,y
    sta zp_ptr_color_hi
    lda color_row2_lo,y
    sta zp_ptr_color2_lo
    lda color_row2_hi,y
    sta zp_ptr_color2_hi
    lda monster_type,x
    asl
    asl                 // type * 4
    tay
    lda monster_chars_rat,y
    sta g_tmp
    iny
    lda monster_chars_rat,y
    sta g_tr
    iny
    lda monster_chars_rat,y
    sta g_bl
    iny
    lda monster_chars_rat,y
    sta g_br
    lda monster_x,x
    asl                     // screen col = monster_x * 2
    tay
    lda g_tmp
    sta (zp_ptr_screen),y   // TL
    iny
    lda g_tr
    sta (zp_ptr_screen),y   // TR
    dey
    lda g_bl
    sta (zp_ptr_screen2),y  // BL
    iny
    lda g_br
    sta (zp_ptr_screen2),y  // BR
    dey
    lda #COLOR_MONSTER
    sta (zp_ptr_color),y
    iny
    sta (zp_ptr_color),y
    dey
    sta (zp_ptr_color2),y
    iny
    sta (zp_ptr_color2),y
gda_mon_next:
    inx
    jmp gda_mons_loop

gda_player:
    jsr draw_player_at_pos
    jsr game_draw_hud
    rts

//////////////////////////////////////////////////////////////////////////////////////
// draw_player_at_pos: write '@' at TL of player's 2x2 tile.
draw_player_at_pos:
    ldx player_y
    lda screen_row_lo,x
    sta zp_ptr_screen_lo
    lda screen_row_hi,x
    sta zp_ptr_screen_hi
    lda screen_row2_lo,x
    sta zp_ptr_screen2_lo
    lda screen_row2_hi,x
    sta zp_ptr_screen2_hi
    lda color_row_lo,x
    sta zp_ptr_color_lo
    lda color_row_hi,x
    sta zp_ptr_color_hi
    lda color_row2_lo,x
    sta zp_ptr_color2_lo
    lda color_row2_hi,x
    sta zp_ptr_color2_hi
    lda player_x
    asl                     // screen col = player_x * 2
    tay
    lda player_chars+0
    sta (zp_ptr_screen),y   // TL
    iny
    lda player_chars+1
    sta (zp_ptr_screen),y   // TR
    dey
    lda player_chars+2
    sta (zp_ptr_screen2),y  // BL
    iny
    lda player_chars+3
    sta (zp_ptr_screen2),y  // BR
    dey
    lda #COLOR_PLAYER
    sta (zp_ptr_color),y
    iny
    sta (zp_ptr_color),y
    dey
    sta (zp_ptr_color2),y
    iny
    sta (zp_ptr_color2),y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_draw_hud: draw HP/ATK/DEF/FLOOR line at row 20.
game_draw_hud:
    ldx #20
    ldy #0
    clc
    jsr KERNAL_PLOT
    lda #COLOR_HUD
    sta CURSOR_COLOR
    Print(str_hp_lbl)
    lda player_hp
    jsr game_print_num
    Print(str_atk_lbl)
    lda player_atk
    jsr game_print_num
    Print(str_def_lbl)
    lda player_def
    jsr game_print_num
    Print(str_fl_lbl)
    lda player_floor
    jsr game_print_num
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_print_num: print A (0-99) as decimal via KERNAL_CHROUT.
game_print_num:
    sta g_tmp
    lda #0
    sta g_tmp2
gpn_tens:
    lda g_tmp
    cmp #10
    bcc gpn_ones
    sec
    sbc #10
    sta g_tmp
    inc g_tmp2
    jmp gpn_tens
gpn_ones:
    lda g_tmp2
    beq gpn_no_tens
    clc
    adc #$30
    jsr KERNAL_CHROUT
gpn_no_tens:
    lda g_tmp
    clc
    adc #$30
    jsr KERNAL_CHROUT
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_show_message: write message (zp_tmp_lo/hi → string) to row 21.
game_show_message:
    ldx #21
    ldy #0
    clc
    jsr KERNAL_PLOT
    lda #$20            // clear 38 chars
    ldx #38
gsm_clear:
    jsr KERNAL_CHROUT
    dex
    bne gsm_clear
    ldx #21
    ldy #1
    clc
    jsr KERNAL_PLOT
    lda #COLOR_MSG
    sta CURSOR_COLOR
    jsr print
    lda #1
    sta msg_active
    FullReset(TIMER_MSG_CLEAR)
    rts

//////////////////////////////////////////////////////////////////////////////////////
// game_clear_message: blank row 21.
game_clear_message:
    ldx #21
    ldy #0
    clc
    jsr KERNAL_PLOT
    lda #$20
    ldx #38
gcm_loop:
    jsr KERNAL_CHROUT
    dex
    bne gcm_loop
    lda #0
    sta msg_active
    rts

//////////////////////////////////////////////////////////////////////////////////////
// Message helpers — each loads a string and calls game_show_message.
msg_hit_rat:
    lda #<str_hit_rat
    sta zp_tmp_lo
    lda #>str_hit_rat
    sta zp_tmp_hi
    jsr game_show_message
    rts
msg_hit_bat:
    lda #<str_hit_bat
    sta zp_tmp_lo
    lda #>str_hit_bat
    sta zp_tmp_hi
    jsr game_show_message
    rts
msg_hit_gob:
    lda #<str_hit_gob
    sta zp_tmp_lo
    lda #>str_hit_gob
    sta zp_tmp_hi
    jsr game_show_message
    rts
msg_enemy_slain:
    lda #<str_enemy_slain
    sta zp_tmp_lo
    lda #>str_enemy_slain
    sta zp_tmp_hi
    jsr game_show_message
    rts
msg_got_hit:
    lda #<str_got_hit
    sta zp_tmp_lo
    lda #>str_got_hit
    sta zp_tmp_hi
    jsr game_show_message
    rts
msg_potion:
    lda #<str_potion
    sta zp_tmp_lo
    lda #>str_potion
    sta zp_tmp_hi
    jsr game_show_message
    rts
msg_weapon:
    lda #<str_weapon
    sta zp_tmp_lo
    lda #>str_weapon
    sta zp_tmp_hi
    jsr game_show_message
    rts
msg_stairs:
    lda #<str_stairs
    sta zp_tmp_lo
    lda #>str_stairs
    sta zp_tmp_hi
    jsr game_show_message
    rts
