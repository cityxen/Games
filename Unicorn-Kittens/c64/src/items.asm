//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — items.asm
// The stuff falling from the sky: spawning, falling, catching (goodies -> load,
// kittens -> rescue, bad -> damage), the delivery check at the Good People Center, and
// drawing the item sprites (1..NUM_ITEMS).
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// items_update — spawn on the timer, then fall + collide every active item
//////////////////////////////////////////////////////////////////////////////////////
items_update:
    dec var_spawn_ctr
    bne !nospawn+
    jsr item_spawn
    lda var_spawn_rate
    sta var_spawn_ctr
!nospawn:
    ldx #0
!loop:
    lda item_active,x
    beq !next+
    // fall
    lda item_y,x
    clc
    adc item_speed,x
    sta item_y,x
    cmp #ITEM_BOTTOM
    bcc !onscreen+
    lda #0                      // off the bottom -> missed
    sta item_active,x
    jmp !next+
!onscreen:
    txa
    pha                         // check_catch may clobber X via SFX — keep the index
    jsr check_catch
    pla
    tax
!next:
    inx
    cpx #NUM_ITEMS
    bne !loop-
    rts

//////////////////////////////////////////////////////////////////////////////////////
// item_spawn — fill the first free slot with a fresh random item at the top
//////////////////////////////////////////////////////////////////////////////////////
item_spawn:
    ldx #0
!f:
    lda item_active,x
    beq !found+
    inx
    cpx #NUM_ITEMS
    bne !f-
    rts                         // all slots busy
!found:
    jsr pick_type
    sta item_type,x
    // x in 40..167 (kept clear of the edges and the HUD)
    jsr get_rand
    and #$7F
    clc
    adc #40
    sta item_x,x
    lda #ITEM_TOP
    sta item_y,x
    // speed = item_fall[type] + level bonus (var_fall_base - FALL_MIN) + (0..1) jitter
    ldy item_type,x
    lda item_fall,y
    clc
    adc var_fall_base
    sec
    sbc #FALL_MIN
    sta var_tmp_a
    jsr get_rand                // preserves X
    and #1
    clc
    adc var_tmp_a
    sta item_speed,x
    lda #1
    sta item_active,x
    rts

//////////////////////////////////////////////////////////////////////////////////////
// check_catch — X = slot.  If the unicorn overlaps it, resolve by category.
//////////////////////////////////////////////////////////////////////////////////////
check_catch:
    // |uni_x - item_x| < CATCH_DX ?
    lda var_uni_x
    sec
    sbc item_x,x
    bpl !cp+
    eor #$FF
    clc
    adc #1
!cp:
    cmp #CATCH_DX
    bcs !no+
    // |uni_y - item_y| < CATCH_DY ?
    lda var_uni_y
    sec
    sbc item_y,x
    bpl !rp+
    eor #$FF
    clc
    adc #1
!rp:
    cmp #CATCH_DY
    bcs !no+

    // overlap — branch on category (NOTE: deactivate using X BEFORE any SFX call,
    // since the SID helpers clobber X)
    ldy item_type,x
    lda item_cat,y
    cmp #CAT_GOOD
    beq !good+
    cmp #CAT_KITTEN
    beq !kitten+

    // BAD: vanish, then take damage
    lda #0
    sta item_active,x
    jsr hit_bad
!no:
    rts

!good:
    lda var_load
    cmp #MAX_LOAD
    bcs !no-                    // hands full — let it keep falling
    inc var_load
    lda #0
    sta item_active,x
    jsr sfx_catch
    rts

!kitten:
    lda var_kittens
    cmp #255
    bcs !kscore+
    inc var_kittens
!kscore:
    lda #KITTEN_BONUS
    jsr add_score              // preserves X
    lda #0
    sta item_active,x
    jsr sfx_catch
    rts

//////////////////////////////////////////////////////////////////////////////////////
// hit_bad — lose a heart and flash the border
//////////////////////////////////////////////////////////////////////////////////////
hit_bad:
    lda var_hp
    beq !f+
    dec var_hp
!f:
    lda #FLASH_HIT
    sta var_flash
    jsr sfx_bad
    rts

//////////////////////////////////////////////////////////////////////////////////////
// center_check — deliver the load when the unicorn reaches the Good People Center
//////////////////////////////////////////////////////////////////////////////////////
center_check:
    lda var_load
    beq !no+                    // nothing to drop off
    // |uni_x - CENTER_X| < CATCH_DX ?
    lda var_uni_x
    sec
    sbc #CENTER_X
    bpl !cp+
    eor #$FF
    clc
    adc #1
!cp:
    cmp #CATCH_DX
    bcs !no+
    // |uni_y - CENTER_Y| < CATCH_DY ?
    lda var_uni_y
    sec
    sbc #CENTER_Y
    bpl !rp+
    eor #$FF
    clc
    adc #1
!rp:
    cmp #CATCH_DY
    bcs !no+

    // deliver: score += load * PTS_PER_GOODIE, delivered += load, load = 0
    ldx var_load
!sc:
    lda #PTS_PER_GOODIE
    jsr add_score
    dex
    bne !sc-
    lda var_delivered
    clc
    adc var_load
    sta var_delivered
    lda #0
    sta var_load
    jsr sfx_deliver
    lda #FLASH_DELIVER
    sta var_flash
!no:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// items_draw — position + point + colour each active item sprite (1..NUM_ITEMS)
//////////////////////////////////////////////////////////////////////////////////////
items_draw:
    ldx #0
!loop:
    lda item_active,x
    beq !next+
    // X/Y register pair: hardware sprite (slot+1) -> $D002 + slot*2
    txa
    asl
    tay
    lda item_x,x
    sta SPRITE_1_X,y
    lda item_y,x
    sta SPRITE_1_Y,y
    // pointer + colour by type (sprite (slot+1) -> +slot from sprite 1)
    ldy item_type,x
    lda item_sprite,y
    sta SPRITE_1_POINTER,x
    lda item_color,y
    sta SPRITE_1_COLOR,x
!next:
    inx
    cpx #NUM_ITEMS
    bne !loop-
    rts

//////////////////////////////////////////////////////////////////////////////////////
// build_enable — compose SPRITE_ENABLE: unicorn (0) + center (7) + active items
//////////////////////////////////////////////////////////////////////////////////////
build_enable:
    lda #%10000001              // sprite 0 (unicorn) + sprite 7 (center)
    sta var_enable
    ldx #0
!e:
    lda item_active,x
    beq !sk+
    lda var_enable
    ora item_bit,x
    sta var_enable
!sk:
    inx
    cpx #NUM_ITEMS
    bne !e-
    lda var_enable
    sta SPRITE_ENABLE
    rts
