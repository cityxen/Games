//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — room.asm
// Draw the current room (floor, bordered walls with exit gaps, objects), build the
// collision map, handle room-to-room transitions, and shared coordinate/resource
// helpers used across the game.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// room_rec_ptr — zp_tmp -> room_table + var_room*ROOM_REC
//////////////////////////////////////////////////////////////////////////////////////
room_rec_ptr:
    lda var_room
    asl
    asl
    asl                     // *8 (ROOM_REC)
    clc
    adc #<room_table
    sta zp_tmp_lo
    lda #>room_table
    adc #0
    sta zp_tmp_hi
    rts

//////////////////////////////////////////////////////////////////////////////////////
// room_draw — full redraw of the current room
//////////////////////////////////////////////////////////////////////////////////////
room_draw:
    jsr room_rec_ptr
    ldy #0
    lda (zp_tmp_lo),y
    sta var_tmp_a           // bg_char
    ldy #1
    lda (zp_tmp_lo),y
    sta var_tmp_b           // bg_color
    jsr room_fill_play
    jsr room_clear_blockmap
    jsr room_draw_border
    jsr room_draw_objects
    jsr room_draw_barriers
    rts

// room_fill_play — fill rows 1-23 with var_tmp_a (char) in var_tmp_b (colour)
room_fill_play:
    lda #1
    sta var_tmp_c
!r:
    ldx var_tmp_c
    lda screen_row_lo,x
    sta zp_ptr_screen_lo
    lda screen_row_hi,x
    sta zp_ptr_screen_hi
    lda color_row_lo,x
    sta zp_ptr_color_lo
    lda color_row_hi,x
    sta zp_ptr_color_hi
    ldy #39
!c:
    lda var_tmp_a
    sta (zp_ptr_screen_lo),y
    lda var_tmp_b
    sta (zp_ptr_color_lo),y
    dey
    bpl !c-
    inc var_tmp_c
    lda var_tmp_c
    cmp #24
    bne !r-
    rts

// room_clear_blockmap — zero BLOCK_MAP rows 1-23
room_clear_blockmap:
    lda #1
    sta var_tmp_c
!r:
    ldx var_tmp_c
    lda screen_row_lo,x
    sta zp_tmp_lo
    lda screen_row_hi,x
    clc
    adc #BLOCK_OFFSET_HI
    sta zp_tmp_hi
    lda #0
    ldy #39
!c:
    sta (zp_tmp_lo),y
    dey
    bpl !c-
    inc var_tmp_c
    lda var_tmp_c
    cmp #24
    bne !r-
    rts

//////////////////////////////////////////////////////////////////////////////////////
// room_draw_border — wall the play-area edges, leaving a gap on any edge with an
// exit.  Walls are marked solid in the BLOCK_MAP.
//////////////////////////////////////////////////////////////////////////////////////
room_draw_border:
    jsr room_rec_ptr
    ldy #2
    lda (zp_tmp_lo),y
    sta var_wall_color

    ldy #4                  // exit_n
    lda (zp_tmp_lo),y
    jsr exit_gapflag
    sta var_tmp_a
    lda #1
    sta var_tmp_c
    jsr draw_hwall

    jsr room_rec_ptr
    ldy #5                  // exit_s
    lda (zp_tmp_lo),y
    jsr exit_gapflag
    sta var_tmp_a
    lda #23
    sta var_tmp_c
    jsr draw_hwall

    jsr room_rec_ptr
    ldy #6                  // exit_e
    lda (zp_tmp_lo),y
    jsr exit_gapflag
    sta var_tmp_a
    lda #39
    sta var_tmp_b
    jsr draw_vwall

    jsr room_rec_ptr
    ldy #7                  // exit_w
    lda (zp_tmp_lo),y
    jsr exit_gapflag
    sta var_tmp_a
    lda #0
    sta var_tmp_b
    jsr draw_vwall
    rts

// exit_gapflag — A = exit field -> A = 1 (leave a gap) if an exit exists, else 0
exit_gapflag:
    cmp #NO_EXIT
    beq !no+
    lda #1
    rts
!no:
    lda #0
    rts

// draw_hwall — var_tmp_c = row, var_tmp_a = gapflag (gap at cols 18-21)
draw_hwall:
    ldx var_tmp_c
    lda screen_row_lo,x
    sta zp_ptr_screen_lo
    lda screen_row_hi,x
    sta zp_ptr_screen_hi
    lda color_row_lo,x
    sta zp_ptr_color_lo
    lda color_row_hi,x
    sta zp_ptr_color_hi
    lda zp_ptr_screen_lo
    sta zp_tmp_lo
    lda zp_ptr_screen_hi
    clc
    adc #BLOCK_OFFSET_HI
    sta zp_tmp_hi
    ldy #39
!c:
    lda var_tmp_a
    beq !wall+
    cpy #18
    bcc !wall+
    cpy #22
    bcs !wall+
    lda #0                  // gap cell: floor, not solid
    sta (zp_tmp_lo),y
    jmp !next+
!wall:
    lda #SC_WALL
    sta (zp_ptr_screen_lo),y
    lda var_wall_color
    sta (zp_ptr_color_lo),y
    lda #1
    sta (zp_tmp_lo),y
!next:
    dey
    bpl !c-
    rts

// draw_vwall — var_tmp_b = col, var_tmp_a = gapflag (gap at rows 11-13)
draw_vwall:
    lda #1
    sta var_tmp_c
!r:
    ldx var_tmp_c
    lda screen_row_lo,x
    sta zp_ptr_screen_lo
    lda screen_row_hi,x
    sta zp_ptr_screen_hi
    lda color_row_lo,x
    sta zp_ptr_color_lo
    lda color_row_hi,x
    sta zp_ptr_color_hi
    lda zp_ptr_screen_lo
    sta zp_tmp_lo
    lda zp_ptr_screen_hi
    clc
    adc #BLOCK_OFFSET_HI
    sta zp_tmp_hi
    ldy var_tmp_b
    lda var_tmp_a
    beq !wall+
    lda var_tmp_c
    cmp #11
    bcc !wall+
    cmp #14
    bcs !wall+
    lda #0
    sta (zp_tmp_lo),y
    jmp !next+
!wall:
    lda #SC_WALL
    sta (zp_ptr_screen_lo),y
    lda var_wall_color
    sta (zp_ptr_color_lo),y
    lda #1
    sta (zp_tmp_lo),y
!next:
    inc var_tmp_c
    lda var_tmp_c
    cmp #24
    bne !r-
    rts

//////////////////////////////////////////////////////////////////////////////////////
// room_draw_objects — draw each live object in this room; mark solids in BLOCK_MAP
//////////////////////////////////////////////////////////////////////////////////////
// obj_table is >256 bytes, so it is walked with a 16-bit zero-page pointer
// (zp_ptr_2) advanced by OBJ_REC — NOT an 8-bit X offset.
room_draw_objects:
    lda #<obj_table
    sta zp_ptr_2_lo
    lda #>obj_table
    sta zp_ptr_2_hi
    lda #0
    sta var_obj_slot
!scan:
    ldy #0
    lda (zp_ptr_2_lo),y     // room ($FF = end)
    cmp #$FF
    beq !done+
    cmp var_room
    bne !next+
    ldx var_obj_slot
    lda obj_state,x
    bne !next+              // depleted
    jsr draw_one_object
!next:
    lda zp_ptr_2_lo
    clc
    adc #OBJ_REC
    sta zp_ptr_2_lo
    bcc !nc+
    inc zp_ptr_2_hi
!nc:
    inc var_obj_slot
    jmp !scan-
!done:
    rts

// draw_one_object — draw the object at (zp_ptr_2) as a 3x3 tile_char tile in the
// object's colour; mark non-space cells solid in the BLOCK_MAP when OBJ_SOLID.
draw_one_object:
    ldy #3
    lda (zp_ptr_2_lo),y     // kind → tile_char base index (kind*TILE_REC)
    sta var_tmp_a
    asl
    asl
    asl
    clc
    adc var_tmp_a           // *9
    sta var_tile_idx

    ldy #4
    lda (zp_ptr_2_lo),y     // colour
    sta var_tmp_b
    ldy #5
    lda (zp_ptr_2_lo),y     // flags & OBJ_SOLID (0 = walk-through tile)
    and #OBJ_SOLID
    sta var_tmp_c

    ldy #1
    lda (zp_ptr_2_lo),y     // col (left)
    sta var_tile_col
    ldy #2
    lda (zp_ptr_2_lo),y     // row (top)
    sta var_tile_row

    lda #TILE_H
    sta var_tile_rc
!row:
    ldx var_tile_row
    lda screen_row_lo,x
    sta zp_ptr_screen_lo
    lda screen_row_hi,x
    sta zp_ptr_screen_hi
    lda color_row_lo,x
    sta zp_ptr_color_lo
    lda color_row_hi,x
    sta zp_ptr_color_hi
    lda zp_ptr_screen_lo
    sta zp_tmp_lo
    lda zp_ptr_screen_hi
    clc
    adc #BLOCK_OFFSET_HI
    sta zp_tmp_hi

    ldy var_tile_col        // Y = screen column across this row
    lda #TILE_W
    sta var_tile_cc
!col:
    ldx var_tile_idx
    lda tile_char,x         // cell screen code
    sta (zp_ptr_screen_lo),y
    lda var_tmp_b
    sta (zp_ptr_color_lo),y
    lda var_tmp_c           // solid object?
    beq !next+
    lda tile_char,x
    cmp #SC_SPACE           // never make a transparent cell solid
    beq !next+
    lda #1
    sta (zp_tmp_lo),y
!next:
    inc var_tile_idx
    iny
    dec var_tile_cc
    bne !col-

    inc var_tile_row
    dec var_tile_rc
    bne !row-
    rts

//////////////////////////////////////////////////////////////////////////////////////
// room_draw_barriers — draw each uncleared barrier in this room (solid)
//////////////////////////////////////////////////////////////////////////////////////
room_draw_barriers:
    lda #0
    sta var_bar_off
!scan:
    ldx var_bar_off
    lda barrier_table,x         // room ($FF = end)
    cmp #$FF
    beq !done+
    cmp var_room
    bne !next+
    ldx var_bar_off
    lda barrier_table+6,x        // flag
    and var_flags
    bne !next+                  // already cleared
    jsr draw_one_barrier
!next:
    lda var_bar_off
    clc
    adc #BAR_REC
    sta var_bar_off
    jmp !scan-
!done:
    rts

draw_one_barrier:
    ldx var_bar_off
    lda barrier_table+2,x        // row
    tay
    lda screen_row_lo,y
    sta zp_ptr_screen_lo
    lda screen_row_hi,y
    sta zp_ptr_screen_hi
    lda color_row_lo,y
    sta zp_ptr_color_lo
    lda color_row_hi,y
    sta zp_ptr_color_hi
    lda zp_ptr_screen_lo
    sta zp_tmp_lo
    lda zp_ptr_screen_hi
    clc
    adc #BLOCK_OFFSET_HI
    sta zp_tmp_hi
    ldx var_bar_off
    ldy barrier_table+1,x        // col
    lda barrier_table+3,x        // char
    sta (zp_ptr_screen_lo),y
    lda barrier_table+4,x        // colour
    sta (zp_ptr_color_lo),y
    lda #1
    sta (zp_tmp_lo),y            // solid
    rts

//////////////////////////////////////////////////////////////////////////////////////
// room_enter — spawn this room's clone + show the area banner
//////////////////////////////////////////////////////////////////////////////////////
room_enter:
    jsr clone_spawn_for_room
    jsr room_rec_ptr
    ldy #3
    lda (zp_tmp_lo),y       // name_msg
    cmp #MSG_BLANK
    beq !nobanner+          // generated rooms are unnamed (no banner spam)
    ldx #MSG_SHORT
    jsr msg_show_id
!nobanner:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// room_go — A = target room id: switch room, redraw, re-enter, refresh HUD
//////////////////////////////////////////////////////////////////////////////////////
room_go:
    sta var_room
    jsr room_draw
    jsr room_enter
    jsr hud_draw
    rts

//////////////////////////////////////////////////////////////////////////////////////
// Coordinate helpers
//////////////////////////////////////////////////////////////////////////////////////
// col_to_px — A = screen col (<=28) → A = sprite X pixel (col*8 + 24, < 256)
col_to_px:
    asl
    asl
    asl
    clc
    adc #24
    rts

// row_to_py — A = screen row → A = sprite Y pixel (row*8 + 42)
row_to_py:
    asl
    asl
    asl
    clc
    adc #42
    rts

// player_to_col — A = player's approximate screen column (0..39)
player_to_col:
    lda var_player_x
    sec
    sbc #24
    sta var_tmp_b
    lda var_player_x_msb
    sbc #0
    sta var_tmp_c
    lsr var_tmp_c
    ror var_tmp_b
    lsr var_tmp_c
    ror var_tmp_b
    lsr var_tmp_c
    ror var_tmp_b
    lda var_tmp_b
    rts

// player_to_row — A = player's approximate screen row (0..24)
player_to_row:
    lda var_player_y
    sec
    sbc #42
    lsr
    lsr
    lsr
    rts

//////////////////////////////////////////////////////////////////////////////////////
// Resource helpers
//////////////////////////////////////////////////////////////////////////////////////
// add_energy — A = amount → Retronic Energy += A, capped at 9999
add_energy:
    clc
    adc var_re_lo
    sta var_re_lo
    bcc !nc+
    inc var_re_hi
!nc:
    lda var_re_hi
    cmp #$27
    bcc !ok+
    bne !cap+
    lda var_re_lo
    cmp #$10
    bcc !ok+
!cap:
    lda #$0F
    sta var_re_lo
    lda #$27
    sta var_re_hi
!ok:
    rts

// drain_energy — A = amount → Retronic Energy -= A (floor 0).
//   On return Z is set (BEQ) if energy is now zero.
drain_energy:
    sta var_tmp_a
    lda var_re_lo
    sec
    sbc var_tmp_a
    sta var_re_lo
    bcs !chk+
    lda var_re_hi
    beq !zero+
    dec var_re_hi
    jmp !chk+
!zero:
    lda #0
    sta var_re_lo
    sta var_re_hi
!chk:
    lda var_re_lo
    ora var_re_hi
    rts

// add_ci — A = amount → Collective Imagination += A, capped at 255
add_ci:
    clc
    adc var_ci
    bcc !ok+
    lda #255
!ok:
    sta var_ci
    rts
