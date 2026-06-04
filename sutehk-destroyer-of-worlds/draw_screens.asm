//////////////////////////////////////////////////////////////////////////////////////
// SUTEHK: DESTROYER OF WORLDS - C64
// By Deadline / CityXen 2026
// https://cityxen.itch.io
//////////////////////////////////////////////////////////////////////////////////////
// draw_screens.asm

draw_main_screen:
    ClearScreen(BLACK)

    PrintPlot(6,8)
    PrintChr(KEY_YELLOW)
    Print(str_title)

    PrintPlot(8,10)
    PrintChr(KEY_CYAN)
    Print(str_subtitle)

    PrintPlot(7,15)
    PrintChr(KEY_WHITE)
    Print(str_press_start)

    PrintPlot(12,23)
    PrintChr(KEY_DK_GREY)
    Print(str_credit)

    jsr init_sprites_main
    rts



//////////////////////////////////////////////////////////////////////////////////////
// game_draw: redraw the entire level, player, and HUD from scratch
game_draw:
    lda #0
    sta gd_row
gd_row_loop:
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
    lda gd_row_base
    clc
    adc gd_col
    tax
    lda game_map,x
    tax
    ldy gd_screen_col
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

    inc gd_col
    inc gd_screen_col
    inc gd_screen_col
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
// game_draw_player: snap sprite 0 to player_x/y; cancels any animation in progress
game_draw_player:
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
    rol player_sprite_x_hi
    clc
    adc #20
    sta player_sprite_x_lo
    lda player_sprite_x_hi
    adc #0
    sta player_sprite_x_hi

    lda player_y
    asl
    asl
    asl
    asl
    clc
    adc #88
    sta player_sprite_y

    lda player_sprite_x_lo
    sta player_target_x_lo
    lda player_sprite_x_hi
    sta player_target_x_hi
    lda player_sprite_y
    sta player_target_y
    lda #0
    sta player_is_moving

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
// game_draw_orb_sprites: scan map for sprite objects, assign to sprite slots 1-6
game_draw_orb_sprites:
    lda orb_anim_frame
    bne gdos_frame2
    lda #sprite_pointer_emerald_frame1
    jmp gdos_ptr_set
gdos_frame2:
    lda #sprite_pointer_emerald_frame2
gdos_ptr_set:
    sta gdos_cur_ptr

    lda #1
    sta gdos_sprite_num
    lda #%00000001
    sta gdos_enable_mask
    lda SPRITE_MSB_X
    and #%00000001
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
    cmp #OBJ_EXIT_CLOSED
    beq gdos_is_exit_closed
    cmp #OBJ_EXIT_OPEN
    beq gdos_is_exit_open
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
    jmp gdos_check_slot

gdos_is_exit_closed:
    lda #sprite_pointer_fence
    sta gdos_place_ptr
    lda #ORANGE
    sta gdos_place_color
    jmp gdos_check_slot

gdos_is_exit_open:
    lda #sprite_pointer_gate_left
    sta gdos_place_ptr
    lda #ORANGE
    sta gdos_place_color

gdos_check_slot:
    lda gdos_sprite_num
    cmp #7                      // limit to slots 1-6; slot 7 reserved for bat
    bne gdos_place
    jmp gdos_apply

gdos_place:
    asl
    sta gdos_sprite_reg_off

    ldx gdos_sprite_num
    lda gdos_place_ptr
    sta SPRITE_POINTERS,x
    lda gdos_place_color
    sta SPRITE_COLORS,x

    lda gdos_row
    asl
    asl
    asl
    asl
    clc
    adc #88
    ldx gdos_sprite_reg_off
    sta SPRITE_LOCATIONS+1,x

    lda gdos_col
    cmp #15
    bcc gdos_x_lo
    ldy gdos_sprite_num
    lda sprite_bit_tbl,y
    ora gdos_msb_mask
    sta gdos_msb_mask

gdos_x_lo:
    lda gdos_col
    asl
    asl
    asl
    asl
    clc
    adc #20
    ldx gdos_sprite_reg_off
    sta SPRITE_LOCATIONS,x

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
    // Fold bat (sprite 7) into enable and MSB masks
    lda bat_active
    beq gdos_apply_write
    lda gdos_enable_mask
    ora #%10000000
    sta gdos_enable_mask
    lda bat_x_hi
    and #1
    beq gdos_apply_write
    lda gdos_msb_mask
    ora #%10000000
    sta gdos_msb_mask
gdos_apply_write:
    lda gdos_enable_mask
    sta SPRITE_ENABLE
    lda gdos_msb_mask
    sta SPRITE_MSB_X
    rts

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
