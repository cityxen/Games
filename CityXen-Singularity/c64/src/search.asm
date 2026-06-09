//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — search.asm
// THE CORE VERB.  Press fire near an object to SEARCH it: terminals, desks,
// crates, trash cans, bookcases, Retronic Wells, allied APMs.  Rewards are items,
// clues, lore, Retronic Energy and Collective Imagination.  Exploration is always
// rewarded (Maniac Mansion + Impossible Mission, by way of the LO8BC).
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// search_update — edge-detect the fire button, search once per press
//////////////////////////////////////////////////////////////////////////////////////
search_update:
    lda JOYSTICK_PORT_2
    and #%00010000
    bne !notp+
    lda var_fire_prev
    bne !held+
    lda #1
    sta var_fire_prev
    jsr search_action
!held:
    rts
!notp:
    lda #0
    sta var_fire_prev
    rts

//////////////////////////////////////////////////////////////////////////////////////
// search_action — find the nearest searchable object; resolve it, or "nothing here"
//////////////////////////////////////////////////////////////////////////////////////
search_action:
    jsr search_find_near
    lda var_near_obj
    cmp #$FF
    beq !nothing+
    jmp search_resolve
!nothing:
    // Nothing searchable — is there a barrier here to hint about?
    lda #0
    sta var_summon_crew         // 0 = match any barrier (hint mode)
    jsr summon_find_barrier
    lda var_near_bar
    cmp #$FF
    beq !really+
    ldx var_near_bar
    lda barrier_table+7,x        // barrier description / hint
    ldx #MSG_LONG
    jsr msg_show_id
    rts
!really:
    lda #MSG_NOTHING
    ldx #MSG_SHORT
    jsr msg_show_id
    rts

//////////////////////////////////////////////////////////////////////////////////////
// search_find_near — nearest live searchable object in reach → var_near_obj (slot)
//   and var_obj_off (table offset).  First match within SEARCH_COL/SEARCH_ROW wins.
//////////////////////////////////////////////////////////////////////////////////////
search_find_near:
    lda #$FF
    sta var_near_obj
    jsr player_to_col
    sta var_pcol
    jsr player_to_row
    sta var_prow

    lda #<obj_table
    sta zp_ptr_2_lo
    lda #>obj_table
    sta zp_ptr_2_hi
    lda #0
    sta var_obj_slot
!scan:
    ldy #0
    lda (zp_ptr_2_lo),y         // room ($FF = end)
    cmp #$FF
    beq !done+
    cmp var_room
    bne !next+
    ldx var_obj_slot
    lda obj_state,x
    bne !next+                  // depleted
    ldy #5
    lda (zp_ptr_2_lo),y         // flags
    and #OBJ_SEARCH
    beq !next+

    // |tile_centre_col - player_col| <= SEARCH_COL ?  (tile is 3 wide; centre = col+1)
    ldy #1
    lda (zp_ptr_2_lo),y         // col (left)
    clc
    adc #1
    sec
    sbc var_pcol
    bpl !cp+
    eor #$FF
    clc
    adc #1
!cp:
    cmp #(SEARCH_COL+1)
    bcs !next+

    // |tile_centre_row - player_row| <= SEARCH_ROW ?  (tile is 3 tall; centre = row+1)
    ldy #2
    lda (zp_ptr_2_lo),y         // row (top)
    clc
    adc #1
    sec
    sbc var_prow
    bpl !rp+
    eor #$FF
    clc
    adc #1
!rp:
    cmp #(SEARCH_ROW+1)
    bcs !next+

    lda var_obj_slot
    sta var_near_obj            // zp_ptr_2 now points at this record
    rts
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

//////////////////////////////////////////////////////////////////////////////////////
// search_resolve — apply the matched object's result (var_obj_off / var_near_obj)
//////////////////////////////////////////////////////////////////////////////////////
search_resolve:
    // searching costs Retronic Energy (drains before var_tmp_a is loaded)
    lda #COST_SEARCH
    jsr drain_energy
    jsr hud_draw
    ldy #7
    lda (zp_ptr_2_lo),y         // arg (lore msg id / anchor required-flag)
    sta var_tmp_a
    ldy #6
    lda (zp_ptr_2_lo),y         // result type (far handlers → bne-skip + jmp)
    cmp #RES_WELL
    bne !n1+
    jmp !well+
!n1:
    cmp #RES_ENERGY
    bne !n2+
    jmp !energy+
!n2:
    cmp #RES_IMAG
    bne !n3+
    jmp !imag+
!n3:
    cmp #RES_ITEM
    bne !n4+
    jmp !gadget+
!n4:
    cmp #RES_ANCHOR
    bne !n5+
    jmp !anchor+
!n5:
    cmp #RES_EXIT
    bne !n6+
    jmp !exit+
!n6:
    cmp #RES_BOSS
    bne !n7+
    jmp !boss+
!n7:
    cmp #RES_KEY
    bne !n8+
    jmp !key+
!n8:
    cmp #RES_RIFT
    bne !n9+
    jmp !rift+
!n9:
    // RES_LORE / RES_NONE — arg = message id; re-readable, never depletes
    lda var_tmp_a
    ldx #MSG_LONG
    jsr msg_show_id
    rts

!anchor:
    // arg (var_tmp_a) = required barrier flag; it must be set
    lda var_tmp_a
    and var_flags
    bne !adisable+
    lda #MSG_ANCHOR_BLK
    ldx #MSG_SHORT
    jsr msg_show_id
    rts
!adisable:
    inc var_anchors_done
    jsr search_deplete
    jsr hud_draw
    lda #MSG_ANCHOR
    ldx #MSG_LONG
    jsr msg_show_id
    rts

!exit:
    lda var_anchors_done
    cmp var_anchors_need
    bcc !sealed+
    lda #MSG_EXIT_OPEN
    ldx #MSG_LONG
    jsr msg_show_id
    jmp level_advance           // descend (regenerates the sector)
!sealed:
    lda #MSG_EXIT_SEALED
    ldx #MSG_SHORT
    jsr msg_show_id
    rts

!boss:
    lda var_anchors_done
    cmp var_anchors_need
    bcc !bossno+
    lda #1
    sta var_boss_dead
    lda #MSG_BOSS_WIN
    ldx #MSG_LONG
    jsr msg_show_id
    jmp level_advance
!bossno:
    lda #MSG_BOSS_NO
    ldx #MSG_LONG
    jsr msg_show_id
    rts

!well:
    lda #RE_WELL                // a big refill (+2x RE_WELL), capped, never reduces
    jsr add_energy
    lda #RE_WELL
    jsr add_energy
    jsr search_deplete          // wells are one-time: disappear after use
    jsr hud_draw
    lda #MSG_WELL
    ldx #MSG_LONG
    jsr msg_show_id
    rts

!energy:
    lda #RE_PICKUP
    jsr add_energy
    jsr search_deplete
    jsr hud_draw
    lda #MSG_CRATE
    ldx #MSG_SHORT
    jsr msg_show_id
    rts

!imag:
    lda #CI_PICKUP
    jsr add_ci
    jsr search_deplete
    jsr hud_draw
    lda #MSG_ETHER
    ldx #MSG_SHORT
    jsr msg_show_id
    rts

!gadget:
    lda #RE_GADGET
    jsr add_energy
    lda #CI_GADGET
    jsr add_ci
    jsr search_deplete
    jsr hud_draw
    lda #MSG_GADGET
    ldx #MSG_LONG
    jsr msg_show_id
    rts

!key:
    // pick up the Inverter Key — one-time, unlocks every rift this sector
    lda var_items
    ora #ITEM_INVERTER
    sta var_items
    jsr search_deplete
    lda #MSG_KEY
    ldx #MSG_LONG
    jsr msg_show_id
    rts

!rift:
    // a Reality Rift — only flips once you hold the Inverter Key; reusable (no deplete)
    lda var_items
    and #ITEM_INVERTER
    bne !rgo+
    lda #MSG_INV_NEEDKEY
    ldx #MSG_SHORT
    jsr msg_show_id
    rts
!rgo:
    jmp invert_reality

//////////////////////////////////////////////////////////////////////////////////////
// search_deplete — mark the matched object searched and erase it back to floor
//////////////////////////////////////////////////////////////////////////////////////
search_deplete:
    ldx var_near_obj
    lda #1
    sta obj_state,x

    // background char/colour for this room
    jsr room_rec_ptr
    ldy #0
    lda (zp_tmp_lo),y
    sta var_tmp_b               // bg_char
    ldy #1
    lda (zp_tmp_lo),y
    sta var_tmp_c               // bg_color

    ldy #1
    lda (zp_ptr_2_lo),y         // col (left)
    sta var_tile_col
    ldy #2
    lda (zp_ptr_2_lo),y         // row (top)
    sta var_tile_row

    // erase the object's whole 3x3 tile back to floor + clear its solids
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

    ldy var_tile_col
    lda #TILE_W
    sta var_tile_cc
!col:
    lda var_tmp_b
    sta (zp_ptr_screen_lo),y
    lda var_tmp_c
    sta (zp_ptr_color_lo),y
    lda #0
    sta (zp_tmp_lo),y           // no longer solid
    iny
    dec var_tile_cc
    bne !col-

    inc var_tile_row
    dec var_tile_rc
    bne !row-
    rts
