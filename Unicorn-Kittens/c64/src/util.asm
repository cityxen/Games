//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — util.asm
// Shared helpers: RNG wrapper, weighted item-type picker, score add, SID blips, and the
// put_str screen-writer used by the HUD and presentation screens.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// get_rand — A = a fresh random byte (SID voice-3 noise)
//////////////////////////////////////////////////////////////////////////////////////
get_rand:
    jsr lda_random_sid
    rts

//////////////////////////////////////////////////////////////////////////////////////
// pick_type — A = a random item type, weighted by var_bad_weight (out of 16):
//   r < bad_weight            -> a BAD type (tool/poo/email)
//   next KITTEN_WEIGHT band    -> a kitten
//   otherwise                  -> a goodie (cake/candy)
//////////////////////////////////////////////////////////////////////////////////////
pick_type:
    jsr get_rand
    and #15
    cmp var_bad_weight
    bcs !notbad+
    // BAD: choose tool(3)/poo(4)/email(5)
    jsr get_rand
    and #3
    cmp #3
    bcc !ok+
    lda #0                      // fold the 4th value back to tool
!ok:
    clc
    adc #IT_TOOL
    rts
!notbad:
    sec
    sbc var_bad_weight
    cmp #KITTEN_WEIGHT
    bcs !good+
    lda #IT_KITTEN
    rts
!good:
    jsr get_rand
    and #1                      // cake(0) / candy(1)
    rts

//////////////////////////////////////////////////////////////////////////////////////
// add_score — A = amount -> 16-bit score += A (saturating at $FFFF)
//////////////////////////////////////////////////////////////////////////////////////
add_score:
    clc
    adc var_score_lo
    sta var_score_lo
    bcc !nc+
    lda var_score_hi
    cmp #$FF
    beq !nc+                    // already maxed
    inc var_score_hi
!nc:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// SID blips — sfx_note: A = freq hi, X = control (waveform|gate); retriggers the gate
//////////////////////////////////////////////////////////////////////////////////////
sfx_note:
    sta SID_V1_FREQ_HIGH
    lda #$00
    sta SID_V1_CONTROL_REG      // gate off
    stx SID_V1_CONTROL_REG      // gate on with chosen waveform
    rts
sfx_catch:
    lda #$30
    ldx #$11                    // triangle
    jmp sfx_note
sfx_bad:
    lda #$10
    ldx #$81                    // noise
    jmp sfx_note
sfx_deliver:
    lda #$48
    ldx #$21                    // sawtooth
    jmp sfx_note
sfx_barf:
    lda #$06
    ldx #$81                    // noise
    jmp sfx_note

//////////////////////////////////////////////////////////////////////////////////////
// put_str — A = row, X = col, var_tmp_c = colour, zp_ptr_2 -> 0-terminated screencodes
//////////////////////////////////////////////////////////////////////////////////////
put_str:
    stx var_tmp_b               // col
    tax                         // X = row
    lda screen_row_lo,x
    clc
    adc var_tmp_b
    sta zp_ptr_screen_lo
    lda screen_row_hi,x
    adc #0
    sta zp_ptr_screen_hi
    lda color_row_lo,x
    clc
    adc var_tmp_b
    sta zp_ptr_color_lo
    lda color_row_hi,x
    adc #0
    sta zp_ptr_color_hi
    ldy #0
!l:
    lda (zp_ptr_2_lo),y
    beq !done+
    sta (zp_ptr_screen_lo),y
    lda var_tmp_c
    sta (zp_ptr_color_lo),y
    iny
    jmp !l-
!done:
    rts
