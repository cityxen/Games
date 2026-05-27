//////////////////////////////////////////////////////////////////////////////////////
// ROGUE ENGINE 64 - C64
// dungeon.asm - Map generation and cell draw routines
//////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////
// get_random_range: return a random value in [0, A).
// Input: A = range (1-255). Output: A = result. Clobbers g_tmp.
get_random_range:
    sta g_tmp
    jsr lda_random_sid
grr_loop:
    cmp g_tmp
    bcc grr_done
    sec
    sbc g_tmp
    jmp grr_loop
grr_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_new: generate a complete dungeon floor.
// Called at game start and each time player takes stairs.
dungeon_new:
    jsr dungeon_fill_walls
    jsr dungeon_generate_rooms
    jsr dungeon_place_entities
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_fill_walls: set every cell in rogue_map to TILE_WALL.
// MAP_SIZE=200 fits in one 256-byte loop.
dungeon_fill_walls:
    lda #TILE_WALL
    ldx #0
dfw_loop:
    sta rogue_map,x
    inx
    cpx #MAP_SIZE
    bne dfw_loop
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_generate_rooms: carve MAX_ROOMS random rooms and connect them.
// Room coords kept 1 cell from edges so border wall is preserved.
dungeon_generate_rooms:
    lda #0
    sta room_count
    sta gen_room_idx

dgr_loop:
    lda gen_room_idx
    cmp #MAX_ROOMS
    bne dgr_body
    jmp dgr_done
dgr_body:

    // Random width: MIN_ROOM_W + random(MAX_ROOM_W - MIN_ROOM_W + 1)
    lda #(MAX_ROOM_W - MIN_ROOM_W + 1)
    jsr get_random_range
    clc
    adc #MIN_ROOM_W
    ldx gen_room_idx
    sta room_w,x
    sta room_cur_w

    // Random height: MIN_ROOM_H + random(MAX_ROOM_H - MIN_ROOM_H + 1)
    lda #(MAX_ROOM_H - MIN_ROOM_H + 1)
    jsr get_random_range
    clc
    adc #MIN_ROOM_H
    sta room_h,x
    sta room_cur_h

    // Random x: 1 + random(MAP_W - MAX_ROOM_W - 2)
    lda #(MAP_W - MAX_ROOM_W - 2)
    jsr get_random_range
    clc
    adc #1
    sta room_x,x
    sta room_cur_x

    // Random y: 1 + random(MAP_H - MAX_ROOM_H - 2)
    lda #(MAP_H - MAX_ROOM_H - 2)
    jsr get_random_range
    clc
    adc #1
    sta room_y,x
    sta room_cur_y

    // Compute center: cx = x + w/2
    lda room_cur_w
    lsr                 // w/2
    clc
    adc room_cur_x
    sta room_cx,x

    // cy = y + h/2
    lda room_cur_h
    lsr
    clc
    adc room_cur_y
    sta room_cy,x

    // Carve room interior
    jsr dungeon_carve_room

    // Connect to previous room (if not the first)
    lda gen_room_idx
    beq dgr_no_corridor
    tax
    dex                     // previous room index in X
    lda room_cx,x
    sta corr_x1
    lda room_cy,x
    sta corr_y1
    ldx gen_room_idx
    lda room_cx,x
    sta corr_x2
    lda room_cy,x
    sta corr_y2
    jsr dungeon_carve_corridor

dgr_no_corridor:
    inc room_count
    inc gen_room_idx
    jmp dgr_loop
dgr_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_carve_room: fill rect (room_cur_x,room_cur_y,room_cur_w,room_cur_h)
// with TILE_FLOOR.
dungeon_carve_room:
    lda #0
    sta dcr_dy
dcr_outer:
    lda dcr_dy
    cmp room_cur_h
    beq dcr_done

    // tmp_y = room_cur_y + dcr_dy
    lda room_cur_y
    clc
    adc dcr_dy
    sta zp_tmp          // use zp_tmp ($4e) as tmp_y

    // Set row pointers from map_row table
    tax
    lda map_row_lo,x
    sta zp_ptr_map_lo
    lda map_row_hi,x
    sta zp_ptr_map_hi

    lda #0
    sta dcr_dx
dcr_inner:
    lda dcr_dx
    cmp room_cur_w
    beq dcr_next_row

    // Y = room_cur_x + dcr_dx
    lda room_cur_x
    clc
    adc dcr_dx
    tay

    lda #TILE_FLOOR
    sta (zp_ptr_map),y

    inc dcr_dx
    jmp dcr_inner
dcr_next_row:
    inc dcr_dy
    jmp dcr_outer
dcr_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_carve_corridor: L-shaped corridor from (corr_x1,corr_y1) to (corr_x2,corr_y2).
// Goes horizontal first (along corr_y1), then vertical.
dungeon_carve_corridor:
    jsr dungeon_carve_h_line
    jsr dungeon_carve_v_line
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_carve_h_line: carve TILE_FLOOR from corr_x1 to corr_x2 along row corr_y1.
dungeon_carve_h_line:
    // Set map pointer for row corr_y1
    ldx corr_y1
    lda map_row_lo,x
    sta zp_ptr_map_lo
    lda map_row_hi,x
    sta zp_ptr_map_hi

    lda corr_x1
    sta zp_tmp          // current x
dchl_loop:
    ldy zp_tmp
    lda #TILE_FLOOR
    sta (zp_ptr_map),y

    lda zp_tmp
    cmp corr_x2
    beq dchl_done
    bcc dchl_right
    dec zp_tmp
    jmp dchl_loop
dchl_right:
    inc zp_tmp
    jmp dchl_loop
dchl_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_carve_v_line: carve TILE_FLOOR from corr_y1 to corr_y2 along column corr_x2.
dungeon_carve_v_line:
    lda corr_y1
    sta zp_tmp          // current y
dcvl_loop:
    ldx zp_tmp
    lda map_row_lo,x
    sta zp_ptr_map_lo
    lda map_row_hi,x
    sta zp_ptr_map_hi

    ldy corr_x2
    lda #TILE_FLOOR
    sta (zp_ptr_map),y

    lda zp_tmp
    cmp corr_y2
    beq dcvl_done
    bcc dcvl_down
    dec zp_tmp
    jmp dcvl_loop
dcvl_down:
    inc zp_tmp
    jmp dcvl_loop
dcvl_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_place_entities: place player, stairs, monsters, and items in rooms.
dungeon_place_entities:
    // Clear monster and item tables
    ldx #0
    lda #0
dpe_clear_m:
    sta monster_alive,x
    inx
    cpx #MAX_MONSTERS
    bne dpe_clear_m

    ldx #0
dpe_clear_i:
    sta item_active,x
    inx
    cpx #MAX_ITEMS
    bne dpe_clear_i

    // Player starts at center of room 0
    lda room_cx+0
    sta player_x
    lda room_cy+0
    sta player_y

    // Stairs at center of last room
    ldx room_count
    dex
    lda room_cx,x
    sta stairs_x
    lda room_cy,x
    sta stairs_y

    // Write TILE_STAIRS into map
    ldx stairs_y
    lda map_row_lo,x
    sta zp_ptr_map_lo
    lda map_row_hi,x
    sta zp_ptr_map_hi
    ldy stairs_x
    lda #TILE_STAIRS
    sta (zp_ptr_map),y

    // Place one monster per room (skip room 0 = player start)
    lda #0
    sta g_idx           // monster slot index
    lda #1
    sta g_tmp           // room index (start at 1)
dpe_mon_loop:
    lda g_tmp
    cmp room_count
    beq dpe_items
    ldx g_tmp
    lda room_cx,x
    ldx g_idx
    sta monster_x,x
    ldx g_tmp
    lda room_cy,x
    ldx g_idx
    sta monster_y,x

    // Type: random(3) weighted by floor (higher floors have more goblins)
    lda #3
    jsr get_random_range
    ldx g_idx
    sta monster_type,x

    // HP: base from type table, scaled by floor (floor 1=base, floor 2=base+1, ...)
    lda monster_type,x
    tay
    lda monster_max_hp_tbl,y
    clc
    adc player_floor
    sec
    sbc #1              // base_hp + (player_floor - 1)
    ldx g_idx
    sta monster_hp,x
    lda #1
    sta monster_alive,x

    inc g_idx
    inc g_tmp
    lda g_idx
    cmp #MAX_MONSTERS
    bne dpe_mon_loop

dpe_items:
    // Place one item per room starting at room 2
    lda #0
    sta g_idx           // item slot
    lda #2
    sta g_tmp           // room index
dpe_item_loop:
    lda g_tmp
    cmp room_count
    beq dpe_done
    ldx g_idx
    cmp #MAX_ITEMS
    beq dpe_done

    lda g_tmp
    tax
    lda room_cx,x
    ldx g_idx
    sta item_x,x

    lda g_tmp
    tax
    lda room_cy,x

    // Offset item slightly so it's not on stairs
    clc
    adc #1
    cmp #MAP_H
    bcc dpe_item_y_ok
    lda room_cy,x       // reset if out of bounds
dpe_item_y_ok:
    ldx g_idx
    sta item_y,x

    // Type: alternating POTION/WEAPON
    lda g_idx
    and #1
    sta item_type,x
    lda #1
    sta item_active,x

    inc g_idx
    inc g_tmp
    jmp dpe_item_loop

dpe_done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_get_cell: get map tile at (tmp_x, tmp_y).
//   Inputs: zp_tmp = y (row), X = x (column, or load into Y)
//   We pass y in zp_tmp_hi ($4f) and x in zp_tmp ($4e).
//   Returns: A = tile type; clobbers zp_ptr_map.
dungeon_get_cell:
    ldx zp_tmp_hi           // y
    lda map_row_lo,x
    sta zp_ptr_map_lo
    lda map_row_hi,x
    sta zp_ptr_map_hi
    ldy zp_tmp              // x
    lda (zp_ptr_map),y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// dungeon_set_cell: set map tile at (zp_tmp = x, zp_tmp_hi = y) to A.
dungeon_set_cell:
    pha
    ldx zp_tmp_hi
    lda map_row_lo,x
    sta zp_ptr_map_lo
    lda map_row_hi,x
    sta zp_ptr_map_hi
    pla
    ldy zp_tmp
    sta (zp_ptr_map),y
    rts

//////////////////////////////////////////////////////////////////////////////////////
// draw_map_cell: draw 2x2 tile at (zp_tmp=x, zp_tmp_hi=y).
// TL quadrant: entity char if present, else tile char.
// TR/BL/BR:    always tile char.  All 4 color cells: entity or tile color.
draw_map_cell:
    jsr dungeon_get_cell
    tax
    lda tile_char_tbl,x
    sta g_tmp               // TL
    sta g_tr                // TR
    sta g_bl                // BL
    sta g_br                // BR
    lda tile_color_tbl,x
    sta g_tmp2              // color

    // Check items
    lda #0
    sta g_idx
dmc_item_loop:
    ldx g_idx
    cpx #MAX_ITEMS
    beq dmc_check_monsters
    lda item_active,x
    beq dmc_item_next
    lda item_x,x
    cmp zp_tmp
    bne dmc_item_next
    lda item_y,x
    cmp zp_tmp_hi
    bne dmc_item_next
    lda item_type,x
    sta g_dmg           // save type for color lookup
    asl
    asl                 // type * 4 = byte offset into item_chars_*
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
dmc_item_next:
    inc g_idx
    jmp dmc_item_loop

dmc_check_monsters:
    lda #0
    sta g_idx
dmc_mon_loop:
    ldx g_idx
    cpx #MAX_MONSTERS
    beq dmc_check_player
    lda monster_alive,x
    beq dmc_mon_next
    lda monster_x,x
    cmp zp_tmp
    bne dmc_mon_next
    lda monster_y,x
    cmp zp_tmp_hi
    bne dmc_mon_next
    lda monster_type,x
    asl
    asl                 // type * 4 = byte offset into monster_chars_*
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
    lda #COLOR_MONSTER
    sta g_tmp2
dmc_mon_next:
    inc g_idx
    jmp dmc_mon_loop

dmc_check_player:
    lda player_x
    cmp zp_tmp
    bne dmc_write
    lda player_y
    cmp zp_tmp_hi
    bne dmc_write
    lda player_chars+0
    sta g_tmp
    lda player_chars+1
    sta g_tr
    lda player_chars+2
    sta g_bl
    lda player_chars+3
    sta g_br
    lda #COLOR_PLAYER
    sta g_tmp2

dmc_write:
    // Set up top and bottom screen/color row pointers (map y = zp_tmp_hi)
    ldx zp_tmp_hi
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

    // Screen column = map_x * 2
    lda zp_tmp
    asl
    tay

    // Write 4 quadrant chars
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

    // Write color: all 4 = entity color or tile color
    lda g_tmp2
    sta (zp_ptr_color),y
    iny
    sta (zp_ptr_color),y
    dey
    sta (zp_ptr_color2),y
    iny
    sta (zp_ptr_color2),y
    rts
