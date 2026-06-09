//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — levelgen.asm
// Procedural sector generator.  Builds a chain of locations (each a CityXen room +
// a Nexytic mirror), scatters items in BOTH realities, lays out the anchor/barrier
// puzzle (cross-reality at depth), places clones, and the gate (or Miss DOS on boss
// sectors) — all scaled by var_level into the RAM buffers at $C400+.
//
// Variable discipline: var_g1 = L (location count) persists across the whole pass;
// sub-routines use only var_g0/g2/g3/g4 + var_pl_* + var_tmp_* as locals.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

// Placement slots: an 8-col x 5-row grid of 3x3 tiles with a 1-cell gap on every
// side (col = 3 + (slot&7)*4, row = 3 + (slot>>3)*4 → see slot_to_colrow).
.const slot_used    = $C740     // NSLOTS placement-slot flags
.const NSLOTS       = 40        // 8 cols * 5 rows
.const anchor_room  = $C780     // MAX_ANCHORS
.const barrier_room = $C788
.const anchor_crew  = $C790
.const anchor_flag  = $C798

//////////////////////////////////////////////////////////////////////////////////////
// rng_next — 8-bit Galois LFSR (poly $1D); A = next byte (nonzero seed → period 255)
//////////////////////////////////////////////////////////////////////////////////////
rng_next:
    lda var_rng
    asl
    bcc !nf+
    eor #$1D
!nf:
    sta var_rng
    rts

// rng_below — A = modulus n → A = pseudo-random 0..n-1  (uses var_tmp_c; keeps X)
rng_below:
    sta var_tmp_c
    jsr rng_next
!s:
    cmp var_tmp_c
    bcc !d+
    sec
    sbc var_tmp_c
    jmp !s-
!d:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// level_generate — build the current sector (var_level) into the RAM buffers
//////////////////////////////////////////////////////////////////////////////////////
level_generate:
    // L = 2 + (level-1)/2, capped MAX_LOC ; rooms = L*2
    lda var_level
    sec
    sbc #1
    lsr
    clc
    adc #2
    cmp #(MAX_LOC+1)
    bcc !lok+
    lda #MAX_LOC
!lok:
    sta var_g1
    asl
    sta var_room_count

    // A = 1 + (level-1)/2, capped to min(L, MAX_ANCHORS)
    lda var_level
    sec
    sbc #1
    lsr
    clc
    adc #1
    cmp var_g1
    bcc !a1+
    lda var_g1
!a1:
    cmp #(MAX_ANCHORS+1)
    bcc !a2+
    lda #MAX_ANCHORS
!a2:
    sta var_anchors_need
    lda #0
    sta var_anchors_done

    // clone speed = 1 + (level-1)/4, capped 3
    lda var_level
    sec
    sbc #1
    lsr
    lsr
    clc
    adc #1
    cmp #4
    bcc !sok+
    lda #3
!sok:
    sta var_clone_speed

    // boss sector? (level mod BOSS_INTERVAL == 0)
    lda #0
    sta var_is_boss
    sta var_boss_dead
    ldx var_level
!bm:
    cpx #BOSS_INTERVAL
    bcc !bdone+
    txa
    sec
    sbc #BOSS_INTERVAL
    tax
    jmp !bm-
!bdone:
    cpx #0
    bne !noboss+
    lda #1
    sta var_is_boss
!noboss:

    // reset progress + object write pointer
    lda #<obj_table
    sta zp_ptr_2_lo
    lda #>obj_table
    sta zp_ptr_2_hi
    lda #0
    sta var_gobj_slot
    sta var_gbar
    sta var_gclone
    sta var_flags
    sta var_world
    sta var_room
    sta var_items               // each sector locks inversion again — re-find the key
    ldx #(OBJ_MAX-1)
!cs:
    sta obj_state,x
    dex
    bpl !cs-

    jsr gen_rooms
    jsr gen_puzzle              // assign anchors/barriers to rooms
    jsr gen_exit               // compute exit room

    // hide the Inverter Key in a CityXen room of location 1..L-1 (reachable on foot,
    // never the start room — you must explore for it before any rift will obey)
    lda var_g1
    sec
    sbc #1
    jsr rng_below              // 0..L-2
    clc
    adc #1                     // 1..L-1
    asl                        // *2 → that location's CityXen (even) room
    sta var_key_room

    jsr gen_items              // per-room placement (rifts/anchors/barriers/exit/items)
    jsr gen_clones

    // terminate tables
    ldy #0
    lda #$FF
    sta (zp_ptr_2_lo),y         // obj_table end
    ldx var_gbar
    lda #$FF
    sta barrier_table,x
    ldx var_gclone
    lda #$FF
    sta clone_table,x

    // player start: location 0, CityXen, centred
    lda #0
    sta var_room
    lda #WORLD_CITYXEN
    sta var_world
    lda #160
    sta var_player_x
    lda #0
    sta var_player_x_msb
    lda #120
    sta var_player_y
    lda #FACE_DOWN
    sta var_facing
    rts

//////////////////////////////////////////////////////////////////////////////////////
// gen_rooms — room_table + room_mirror for L locations, then chain CityXen rooms
//////////////////////////////////////////////////////////////////////////////////////
gen_rooms:
    lda #0
    sta var_g0                  // location i
!loc:
    lda var_g0
    asl
    sta var_g2                  // rc = 2i
    asl
    asl
    asl                         // rc*8
    tax
    jsr write_room_cx
    txa
    clc
    adc #8                      // rn*8
    tax
    jsr write_room_nx
    // mirror[rc]=rn, mirror[rn]=rc
    ldx var_g2
    lda var_g2
    clc
    adc #1
    sta room_mirror,x
    lda var_g2
    clc
    adc #1
    tax
    lda var_g2
    sta room_mirror,x
    inc var_g0
    lda var_g0
    cmp var_g1
    bne !loc-

    // chain rooms 0,2,4,... with random East/South links
    lda #0
    sta var_g0
!chain:
    lda var_g0
    clc
    adc #1
    cmp var_g1
    bcs !cdone+
    lda var_g0
    asl
    sta var_g2                  // a = 2i
    clc
    adc #2
    sta var_g3                  // b = 2(i+1)
    lda #2
    jsr rng_below
    cmp #1
    beq !south+
    lda var_g2
    asl
    asl
    asl
    tax
    lda var_g3
    sta room_table+6,x          // a.exit_e = b
    lda var_g3
    asl
    asl
    asl
    tax
    lda var_g2
    sta room_table+7,x          // b.exit_w = a
    jmp !cnext+
!south:
    lda var_g2
    asl
    asl
    asl
    tax
    lda var_g3
    sta room_table+5,x          // a.exit_s = b
    lda var_g3
    asl
    asl
    asl
    tax
    lda var_g2
    sta room_table+4,x          // b.exit_n = a
!cnext:
    inc var_g0
    jmp !chain-
!cdone:
    rts

// write_room_cx / write_room_nx — X = room byte offset
write_room_cx:
    lda #SC_SPACE
    sta room_table+0,x
    lda #BLACK
    sta room_table+1,x
    lda #LIGHT_BLUE
    sta room_table+2,x
    lda #MSG_BLANK
    sta room_table+3,x
    lda #NO_EXIT
    sta room_table+4,x
    sta room_table+5,x
    sta room_table+6,x
    sta room_table+7,x
    rts
write_room_nx:
    lda #SC_SPACE
    sta room_table+0,x
    lda #BLACK
    sta room_table+1,x
    lda #RED
    sta room_table+2,x
    lda #MSG_BLANK
    sta room_table+3,x
    lda #NO_EXIT
    sta room_table+4,x
    sta room_table+5,x
    sta room_table+6,x
    sta room_table+7,x
    rts

//////////////////////////////////////////////////////////////////////////////////////
// gen_puzzle — assign A anchors+barriers to rooms (cross-reality at depth)
//////////////////////////////////////////////////////////////////////////////////////
gen_puzzle:
    lda #0
    sta var_g0                  // k
!ploop:
    lda var_g0
    cmp var_anchors_need
    bcs !pdone+
    // lk = k mod L
    lda var_g0
!modL:
    cmp var_g1
    bcc !haveL+
    sec
    sbc var_g1
    jmp !modL-
!haveL:
    sta var_g2                  // lk
    lda #2
    jsr rng_below
    sta var_g3                  // anchor reality
    lda var_g2
    asl
    clc
    adc var_g3
    ldx var_g0
    sta anchor_room,x
    // barrier reality (cross at depth)
    lda var_level
    cmp #CROSS_LEVEL
    bcc !same+
    lda var_g3
    eor #1
    jmp !setbar+
!same:
    lda var_g3
!setbar:
    sta var_g4
    lda var_g2
    asl
    clc
    adc var_g4
    ldx var_g0
    sta barrier_room,x
    // crew 1..3
    lda #3
    jsr rng_below
    clc
    adc #1
    ldx var_g0
    sta anchor_crew,x
    // flag = 1<<k
    lda #FLAG_ANCH_BASE
    ldy var_g0
    beq !fdone+
!fsh:
    asl
    dey
    bne !fsh-
!fdone:
    ldx var_g0
    sta anchor_flag,x
    inc var_g0
    jmp !ploop-
!pdone:
    rts

// gen_exit — exit room = last CityXen room = 2*(L-1)
gen_exit:
    lda var_g1
    sec
    sbc #1
    asl
    sta var_exit_room
    rts

//////////////////////////////////////////////////////////////////////////////////////
// gen_items — per-room placement: assigned anchors/barriers/exit, then random items
//////////////////////////////////////////////////////////////////////////////////////
gen_items:
    lda #0
    sta var_g0                  // room R
!rloop:
    lda var_g0
    cmp var_room_count
    bcc !rgo+
    jmp !rdone+                  // (jmp: loop body is >127 bytes)
!rgo:
    jsr slots_clear
    jsr reserve_edge_slots      // keep objects out of the doorway approaches
    lda var_g0
    bne !nores+
    lda #1                      // reserve the slots under the player's start (room 0)
    sta slot_used+11
    sta slot_used+12
    sta slot_used+19
    sta slot_used+20
!nores:
    jsr place_room_rift         // mirrored inversion point (both realities)
    // the Inverter Key lives in exactly one CityXen room
    lda var_g0
    cmp var_key_room
    bne !nokey+
    lda var_g0
    sta var_pl_room
    lda #0
    sta var_pl_arg
    lda #K_KEY
    sta var_pl_kind
    jsr gen_place_kind
!nokey:
    jsr place_room_anchors
    jsr place_room_barriers
    lda var_g0
    cmp var_exit_room
    bne !noexit+
    jsr place_room_exit
!noexit:
    // 1 crate + 1 ether (ether in every room, both realities)
    lda var_g0
    sta var_pl_room
    lda #0
    sta var_pl_arg
    lda #K_CRATE
    sta var_pl_kind
    jsr gen_place_kind
    lda #K_ETHER
    sta var_pl_kind
    jsr gen_place_kind
    // lore terminal 50%
    lda #2
    jsr rng_below
    beq !nolore+
    lda #NLORE
    jsr rng_below
    tax
    lda lore_msg,x
    sta var_pl_arg
    lda #K_TERM
    sta var_pl_kind
    jsr gen_place_kind
    lda #0
    sta var_pl_arg
!nolore:
    // wells are sparse: only the start room gets one (a single base refill)
    lda var_g0
    bne !nowell+
    lda #K_WELL
    sta var_pl_kind
    jsr gen_place_kind
!nowell:
    inc var_g0
    jmp !rloop-
!rdone:
    rts

// place_room_rift — one Reality Rift per location, mirrored at the SAME slot in both
// its CityXen (even) and Nexytic (odd) rooms.  Even rooms pick the slot and remember
// it; the following odd room reuses it so you can always flip back.
place_room_rift:
    lda var_g0
    sta var_pl_room
    lda #0
    sta var_pl_arg
    lda #K_RIFT
    sta var_pl_kind
    lda var_g0
    and #1
    bne !mirror+
    // CityXen room — fresh slot, remember it for the mirror
    jsr gen_place_kind
    lda var_slot
    sta var_rift_slot
    rts
!mirror:
    // Nexytic room — same slot the CityXen room used
    ldy var_rift_slot
    lda #1
    sta slot_used,y             // reserve so random items avoid it
    jsr slot_to_colrow          // → var_g3/g4
    jsr gen_add_obj
    rts

place_room_anchors:
    lda #0
    sta var_g2                  // k
!a:
    lda var_g2
    cmp var_anchors_need
    bcs !adone+
    ldx var_g2
    lda anchor_room,x
    cmp var_g0
    bne !an+
    lda var_g0
    sta var_pl_room
    lda #K_ANCHOR
    sta var_pl_kind
    ldx var_g2
    lda anchor_flag,x
    sta var_pl_arg
    jsr gen_place_kind
!an:
    inc var_g2
    jmp !a-
!adone:
    rts

place_room_barriers:
    lda #0
    sta var_g2                  // k
!b:
    lda var_g2
    cmp var_anchors_need
    bcs !bdone+
    ldx var_g2
    lda barrier_room,x
    cmp var_g0
    bne !bn+
    lda var_g0
    sta var_pl_room
    ldx var_g2
    lda anchor_crew,x
    sta var_pl_crew
    lda anchor_flag,x
    sta var_pl_flag
    jsr gen_find_slot           // → var_g3 col, var_g4 row
    jsr gen_add_bar
!bn:
    inc var_g2
    jmp !b-
!bdone:
    rts

place_room_exit:
    lda var_g0
    sta var_pl_room
    lda #0
    sta var_pl_arg
    lda var_is_boss
    beq !gate+
    lda #K_BOSS
    jmp !pk+
!gate:
    lda #K_EXIT
!pk:
    sta var_pl_kind
    jsr gen_place_kind
    rts

//////////////////////////////////////////////////////////////////////////////////////
// gen_clones — scatter min(level,8) clones across random rooms/positions
//////////////////////////////////////////////////////////////////////////////////////
gen_clones:
    lda var_level
    cmp #9
    bcc !cok+
    lda #8
!cok:
    sta var_g2                  // C
    lda #0
    sta var_g0                  // i
!cl:
    lda var_g0
    cmp var_g2
    bcs !cldone+
    lda var_room_count
    jsr rng_below
    sta var_g3                  // room
    lda #30
    jsr rng_below
    clc
    adc #5
    sta var_g4                  // col 5..34
    lda #15
    jsr rng_below
    clc
    adc #4
    sta var_tmp_a               // row 4..18
    ldx var_gclone
    lda var_g3
    sta clone_table+0,x
    lda var_g4
    sta clone_table+1,x
    lda var_tmp_a
    sta clone_table+2,x
    lda var_gclone
    clc
    adc #CLONE_REC
    sta var_gclone
    inc var_g0
    jmp !cl-
!cldone:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// Placement primitives
//////////////////////////////////////////////////////////////////////////////////////
gen_place_kind:
    jsr gen_find_slot
    jsr gen_add_obj
    rts

// gen_add_obj — write one object record at zp_ptr_2 from var_pl_* + var_g3/g4
gen_add_obj:
    lda var_gobj_slot
    cmp #OBJ_MAX
    bcs gen_add_obj_full        // buffer full → skip (safety)
    ldy #0
    lda var_pl_room
    sta (zp_ptr_2_lo),y
    iny
    lda var_g3
    sta (zp_ptr_2_lo),y
    iny
    lda var_g4
    sta (zp_ptr_2_lo),y
    iny
    ldx var_pl_kind
    txa                         // byte3 = kind (draw_one_object looks up tile_char)
    sta (zp_ptr_2_lo),y
    iny
    lda kind_color,x
    sta (zp_ptr_2_lo),y
    iny
    lda #OBJ_SEARCH
    cpx #K_CRATE
    bcc !nf+
    cpx #(K_TERM+1)
    bcs !nf+
    ora #OBJ_SOLID              // crate/ether/gadget/term are solid
!nf:
    sta (zp_ptr_2_lo),y
    iny
    ldx var_pl_kind
    lda kind_result,x
    sta (zp_ptr_2_lo),y
    iny
    lda var_pl_arg
    sta (zp_ptr_2_lo),y
    lda zp_ptr_2_lo
    clc
    adc #OBJ_REC
    sta zp_ptr_2_lo
    bcc !adv+
    inc zp_ptr_2_hi
!adv:
    inc var_gobj_slot
gen_add_obj_full:
    rts

// gen_add_bar — write one barrier record from var_pl_* + var_g3/g4
gen_add_bar:
    lda var_gbar
    cmp #(BAR_MAX*BAR_REC)
    bcc !ok+
    rts                         // barrier buffer full → skip (safety)
!ok:
    ldx var_gbar
    lda var_pl_room
    sta barrier_table+0,x
    lda var_g3
    sta barrier_table+1,x
    lda var_g4
    sta barrier_table+2,x
    lda #SC_WALL
    sta barrier_table+3,x
    ldy var_pl_crew
    dey
    lda crew_bar_color,y
    sta barrier_table+4,x
    lda var_pl_crew
    sta barrier_table+5,x
    lda var_pl_flag
    sta barrier_table+6,x
    ldy var_pl_crew
    dey
    lda crew_hint_msg,y
    sta barrier_table+7,x
    lda var_gbar
    clc
    adc #BAR_REC
    sta var_gbar
    rts

// slots_clear — zero the placement-slot flags
slots_clear:
    ldx #(NSLOTS-1)
    lda #0
!c:
    sta slot_used,x
    dex
    bpl !c-
    rts

// reserve_edge_slots — block the slots whose 3x3 tile would sit in a doorway
// approach, so nothing ever spawns where the player walks in (no getting stuck).
// N/S door is cols 18-21 (top + bottom rows); E/W door is rows 11-13 (left + right
// cols).  See edge_slots; slot = (slot>>3 row)*8 + (slot&7 col).
reserve_edge_slots:
    ldx #0
!r:
    ldy edge_slots,x
    bmi !done+                  // $FF terminator
    lda #1
    sta slot_used,y
    inx
    jmp !r-
!done:
    rts

edge_slots:
    .byte 3, 4                   // N/S door, top    (col15/19, row3)
    .byte 35, 36                 // N/S door, bottom (col15/19, row19)
    .byte 16, 24                 // E/W door, left   (col3, row11/15)
    .byte 23, 31                 // E/W door, right  (col31, row11/15)
    .byte $FF

// gen_find_slot — pick a free slot → var_g3 = col, var_g4 = row
gen_find_slot:
    ldx #16
!try:
    lda #NSLOTS
    jsr rng_below
    tay
    lda slot_used,y
    beq !found+
    dex
    bne !try-
    ldy #0
!lin:
    lda slot_used,y
    beq !found+
    iny
    cpy #NSLOTS
    bne !lin-
    ldy #0
!found:
    lda #1
    sta slot_used,y
    sty var_slot                // remember which slot (for mirrored rifts)
    // fall through: Y still = slot

// slot_to_colrow — Y = slot index → var_g3 = col, var_g4 = row.
// 3x3 tiles on a 4-cell pitch leave a 1-cell gap between neighbours on both axes.
slot_to_colrow:
    tya
    and #7
    asl
    asl
    clc
    adc #3
    sta var_g3                  // col = 3 + (slot&7)*4  → 3,7,11,...,31
    tya
    lsr
    lsr
    lsr
    asl
    asl
    clc
    adc #3
    sta var_g4                  // row = 3 + (slot>>3)*4 → 3,7,11,15,19
    rts
