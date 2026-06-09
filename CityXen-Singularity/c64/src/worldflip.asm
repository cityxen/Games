//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — worldflip.asm
// The Reality Inverter: flip between a CityXen room and its Nexytic mirror.  Inversion
// is GATED — you must first find the Inverter Key (search.asm grants ITEM_INVERTER),
// and you can only flip while standing on a Reality Rift (a K_RIFT object you SEARCH).
// Rifts are mirrored in both realities so you can always flip back.  Items and puzzle
// pieces live in BOTH realities, so you must flip back and forth to clear a sector.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

// invert_reality — called by search_resolve when the Inverter Key is held and a Rift
// is searched.  Spends Retronic Energy only, then flips to the mirror.
invert_reality:
    ldx var_room
    lda room_mirror,x
    cmp #NO_EXIT
    beq !nomir+
    lda var_world
    eor #1
    sta var_world
    lda #COST_INVERT            // flipping reality burns Retronic Energy
    jsr drain_energy
    lda #MSG_INV_DONE
    ldx #MSG_SHORT
    jsr msg_show_id
    ldx var_room
    lda room_mirror,x
    jmp room_go                 // redraw mirror room (player position preserved)
!nomir:
    lda #MSG_INV_NOMIR
    ldx #MSG_SHORT
    jsr msg_show_id
    rts
