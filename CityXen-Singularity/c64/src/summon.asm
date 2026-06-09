//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — summon.asm
// Keyboard input + the Collective Imagination summon system.  Spend Imagination to
// summon a member of the Baka Retro Crew (manifestations of collective belief) to
// clear the barrier they specialise in:
//   1 Helmet Guy  — software (locked code)
//   2 Eagull      — hardware (dormant gates)
//   3 RoboGuy 5000— translation (lost tongues)
// Reality inversion is no longer a key — find the Inverter Key, then SEARCH a Reality
// Rift to flip CityXen <-> Nexytic (search.asm -> worldflip.asm).
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// input_keys — poll the keyboard once per frame for summon keys
//////////////////////////////////////////////////////////////////////////////////////
input_keys:
    jsr KERNAL_GETIN
    beq !done+
    cmp #$31                    // '1'
    bne !k2+
    lda #CREW_HELMET
    jmp summon_do
!k2:
    cmp #$32                    // '2'
    bne !k3+
    lda #CREW_EAGULL
    jmp summon_do
!k3:
    cmp #$33                    // '3'
    bne !done+
    lda #CREW_ROBO
    jmp summon_do
!done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// summon_do — A = CREW_*.  If a matching uncleared barrier is adjacent and there is
// enough Imagination, clear it; otherwise explain why nothing happened.
//////////////////////////////////////////////////////////////////////////////////////
summon_do:
    sta var_summon_crew
    jsr summon_find_barrier
    lda var_near_bar
    cmp #$FF
    beq !none+
    lda var_ci
    cmp #SUMMON_COST
    bcc !poor+
    sec
    sbc #SUMMON_COST
    sta var_ci
    lda #COST_SUMMON_RE         // summoning also burns Retronic Energy
    jsr drain_energy
    jsr barrier_clear
    jsr hud_draw
    rts
!poor:
    lda #MSG_SUM_POOR
    ldx #MSG_SHORT
    jsr msg_show_id
    rts
!none:
    lda #MSG_SUM_NONE
    ldx #MSG_SHORT
    jsr msg_show_id
    rts

//////////////////////////////////////////////////////////////////////////////////////
// summon_find_barrier — nearest uncleared barrier in this room → var_near_bar (offset)
//   and var_bar_off.  Matches crew == var_summon_crew, OR any crew if it is 0 (hint
//   mode, used by the search "what is this?" path).
//////////////////////////////////////////////////////////////////////////////////////
summon_find_barrier:
    lda #$FF
    sta var_near_bar
    jsr player_to_col
    sta var_pcol
    jsr player_to_row
    sta var_prow

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
    ldx var_bar_off
    lda var_summon_crew
    beq !crewok+                // 0 = match any (hint mode)
    lda barrier_table+5,x        // crew
    cmp var_summon_crew
    bne !next+
!crewok:
    // |bar_col - player_col| <= SEARCH_COL ?
    ldx var_bar_off
    lda barrier_table+1,x
    sec
    sbc var_pcol
    bpl !cp+
    eor #$FF
    clc
    adc #1
!cp:
    cmp #(SEARCH_COL+1)
    bcs !next+
    // |bar_row - player_row| <= SEARCH_ROW ?
    ldx var_bar_off
    lda barrier_table+2,x
    sec
    sbc var_prow
    bpl !rp+
    eor #$FF
    clc
    adc #1
!rp:
    cmp #(SEARCH_ROW+1)
    bcs !next+
    lda var_bar_off
    sta var_near_bar
    rts
!next:
    lda var_bar_off
    clc
    adc #BAR_REC
    sta var_bar_off
    jmp !scan-
!done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// barrier_clear — set the matched barrier's flag, redraw the room (it vanishes),
// and show the crew-specific success message
//////////////////////////////////////////////////////////////////////////////////////
barrier_clear:
    ldx var_near_bar
    lda barrier_table+6,x        // flag bit
    ora var_flags
    sta var_flags
    jsr room_draw               // cleared barrier no longer drawn / solid

    lda var_summon_crew
    cmp #CREW_HELMET
    bne !c2+
    lda #MSG_SUM_HELMET
    jmp !show+
!c2:
    cmp #CREW_EAGULL
    bne !c3+
    lda #MSG_SUM_EAGULL
    jmp !show+
!c3:
    lda #MSG_SUM_ROBO
!show:
    ldx #MSG_LONG
    jsr msg_show_id
    rts
