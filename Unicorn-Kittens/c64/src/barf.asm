//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — barf.asm
// THE CRAZY GIMMICK: RAINBOW BARF.  Press FIRE and the unicorn pukes a rainbow that
// vaporises every bad thing currently on screen.  It runs on sugar, so it costs one
// goodie from your load.  No goodies = nothing to barf.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// barf_update — edge-detect FIRE, barf once per press
//////////////////////////////////////////////////////////////////////////////////////
barf_update:
    lda JOYSTICK_PORT_2
    and #%00010000
    bne !released+
    // held / pressed
    lda var_fire_prev
    bne !done+                  // already counted this press
    lda #1
    sta var_fire_prev
    jsr do_barf
    rts
!released:
    lda #0
    sta var_fire_prev
!done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// do_barf — spend a goodie, nuke all on-screen bad items, flash the rainbow
//////////////////////////////////////////////////////////////////////////////////////
do_barf:
    lda var_load
    beq !nofuel+                // need sugar to barf
    dec var_load
    ldx #0
!l:
    lda item_active,x
    beq !n+
    ldy item_type,x
    lda item_cat,y
    cmp #CAT_BAD
    bne !n+
    lda #0
    sta item_active,x
    lda #BARF_PTS
    jsr add_score
!n:
    inx
    cpx #NUM_ITEMS
    bne !l-
    lda #FLASH_BARF
    sta var_flash
    jsr sfx_barf
!nofuel:
    rts
