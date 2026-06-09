//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — hud.asm
// HUD bar (row 0), status/message bar (row 24), and numeric print helpers.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// hud_draw — redraw the stat bar on row 0:  RE:####  CI:###  CLICKY
//////////////////////////////////////////////////////////////////////////////////////
hud_draw:
    lda screen_row_lo
    sta zp_ptr_screen_lo
    lda screen_row_hi
    sta zp_ptr_screen_hi
    lda color_row_lo
    sta zp_ptr_color_lo
    lda color_row_hi
    sta zp_ptr_color_hi

    // colour + blank the row
    ldy #39
!row:
    lda #CYAN
    sta (zp_ptr_color_lo),y
    lda #SC_SPACE
    sta (zp_ptr_screen_lo),y
    dey
    bpl !row-

    // "RE:" label
    ldy #0;  lda #$12; sta (zp_ptr_screen_lo),y   // R
    ldy #1;  lda #$05; sta (zp_ptr_screen_lo),y   // E
    ldy #2;  lda #$3A; sta (zp_ptr_screen_lo),y   // :
    // "IMG:" label (imagination)
    ldy #8;  lda #$09; sta (zp_ptr_screen_lo),y   // I
    ldy #9;  lda #$0D; sta (zp_ptr_screen_lo),y   // M
    ldy #10; lda #$07; sta (zp_ptr_screen_lo),y   // G
    ldy #11; lda #$3A; sta (zp_ptr_screen_lo),y   // :
    // "SEC" (sector) label
    ldy #16; lda #$13; sta (zp_ptr_screen_lo),y   // S
    ldy #17; lda #$05; sta (zp_ptr_screen_lo),y   // E
    ldy #18; lda #$03; sta (zp_ptr_screen_lo),y   // C

    // values
    ldy #3;  jsr print_re4y
    lda var_ci;    ldy #12; jsr print_byte_dec3y
    lda var_level; ldy #19; jsr print_byte_dec3y

    // gate / anchor indicator at cols 26-34: "GATE:OPEN" (green, all nodes down)
    // or "GATE:SHUT" (dim) while anchors remain.
    ldy #26; lda #$07; sta (zp_ptr_screen_lo),y   // G
    ldy #27; lda #$01; sta (zp_ptr_screen_lo),y   // A
    ldy #28; lda #$14; sta (zp_ptr_screen_lo),y   // T
    ldy #29; lda #$05; sta (zp_ptr_screen_lo),y   // E
    ldy #30; lda #$3A; sta (zp_ptr_screen_lo),y   // :
    lda var_anchors_done
    cmp var_anchors_need
    bcc !shut+
    ldy #31; lda #$0F; sta (zp_ptr_screen_lo),y   // O
    ldy #32; lda #$10; sta (zp_ptr_screen_lo),y   // P
    ldy #33; lda #$05; sta (zp_ptr_screen_lo),y   // E
    ldy #34; lda #$0E; sta (zp_ptr_screen_lo),y   // N
    ldx #GREEN
    jmp !gcolor+
!shut:
    ldy #31; lda #$13; sta (zp_ptr_screen_lo),y   // S
    ldy #32; lda #$08; sta (zp_ptr_screen_lo),y   // H
    ldy #33; lda #$15; sta (zp_ptr_screen_lo),y   // U
    ldy #34; lda #$14; sta (zp_ptr_screen_lo),y   // T
    ldx #DARK_GRAY
!gcolor:
    txa
    ldy #34
!gc:
    sta (zp_ptr_color_lo),y
    dey
    cpy #25
    bne !gc-

    // world indicator (cx / nx) at cols 23-24
    lda var_world
    bne !nx+
    ldy #23; lda #$03; sta (zp_ptr_screen_lo),y   // c
    ldy #24; lda #$18; sta (zp_ptr_screen_lo),y   // x
    rts
!nx:
    ldy #23; lda #$0e; sta (zp_ptr_screen_lo),y   // n
    ldy #24; lda #$18; sta (zp_ptr_screen_lo),y   // x
    rts

//////////////////////////////////////////////////////////////////////////////////////
// hud_tick — count down the status-message timer; clear the bar at zero
//////////////////////////////////////////////////////////////////////////////////////
hud_tick:
    lda var_msg_timer
    beq !done+
    dec var_msg_timer
    bne !done+
    jsr status_bar_clear
!done:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// msg_show_id — A = message id, X = duration (frames)
//////////////////////////////////////////////////////////////////////////////////////
msg_show_id:
    tay
    lda msg_ptr_lo,y
    sta var_msg_ptr_lo
    lda msg_ptr_hi,y
    sta var_msg_ptr_hi
    stx var_msg_timer
    jsr msg_render
    rts

//////////////////////////////////////////////////////////////////////////////////////
// msg_render — print the current message string to row 24
//////////////////////////////////////////////////////////////////////////////////////
msg_render:
    jsr status_bar_clear
    lda screen_row_lo+24
    sta zp_ptr_screen_lo
    lda screen_row_hi+24
    sta zp_ptr_screen_hi
    lda color_row_lo+24
    sta zp_ptr_color_lo
    lda color_row_hi+24
    sta zp_ptr_color_hi
    lda var_msg_ptr_lo
    sta zp_tmp_lo
    lda var_msg_ptr_hi
    sta zp_tmp_hi
    ldy #0
!p:
    lda (zp_tmp_lo),y
    beq !d+
    sta (zp_ptr_screen_lo),y
    lda #LIGHT_GRAY
    sta (zp_ptr_color_lo),y
    iny
    cpy #40
    bne !p-
!d:
    rts

//////////////////////////////////////////////////////////////////////////////////////
// status_bar_clear — blank row 24
//////////////////////////////////////////////////////////////////////////////////////
status_bar_clear:
    lda screen_row_lo+24
    sta zp_ptr_screen_lo
    lda screen_row_hi+24
    sta zp_ptr_screen_hi
    lda color_row_lo+24
    sta zp_ptr_color_lo
    lda color_row_hi+24
    sta zp_ptr_color_hi
    ldy #39
!c:
    lda #SC_SPACE
    sta (zp_ptr_screen_lo),y
    lda #BLACK
    sta (zp_ptr_color_lo),y
    dey
    bpl !c-
    rts

//////////////////////////////////////////////////////////////////////////////////////
// print_byte_dec3y — A = value (0..255) → 3 digits at (zp_ptr_screen_lo),Y
//////////////////////////////////////////////////////////////////////////////////////
print_byte_dec3y:
    ldx #0                  // hundreds
!h:
    cmp #100
    bcc !hd+
    sbc #100
    inx
    jmp !h-
!hd:
    sta var_tmp_b           // remainder (<100)
    txa
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny
    ldx #0                  // tens
    lda var_tmp_b
!t:
    cmp #10
    bcc !td+
    sbc #10
    inx
    jmp !t-
!td:
    sta var_tmp_c           // units
    txa
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny
    lda var_tmp_c
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny
    rts

//////////////////////////////////////////////////////////////////////////////////////
// print_re4y — print 16-bit Retronic Energy (var_re_lo/hi) as 4 digits at Y
//////////////////////////////////////////////////////////////////////////////////////
print_re4y:
    lda var_re_lo
    sta var_tmp_b
    lda var_re_hi
    sta var_tmp_c

    // thousands
    ldx #0
!k:
    lda var_tmp_c
    cmp #$03
    bcc !kd+
    bne !ks+
    lda var_tmp_b
    cmp #$E8
    bcc !kd+
!ks:
    lda var_tmp_b
    sec
    sbc #$E8
    sta var_tmp_b
    lda var_tmp_c
    sbc #$03
    sta var_tmp_c
    inx
    jmp !k-
!kd:
    txa
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny

    // hundreds
    ldx #0
!h:
    lda var_tmp_c
    bne !hs+
    lda var_tmp_b
    cmp #$64
    bcc !hd+
!hs:
    lda var_tmp_b
    sec
    sbc #$64
    sta var_tmp_b
    lda var_tmp_c
    sbc #$00
    sta var_tmp_c
    inx
    jmp !h-
!hd:
    txa
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny

    // tens + units (value now < 100)
    ldx #0
    lda var_tmp_b
!t:
    cmp #10
    bcc !tdone+
    sbc #10
    inx
    jmp !t-
!tdone:
    sta var_tmp_b
    txa
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny
    lda var_tmp_b
    clc
    adc #$30
    sta (zp_ptr_screen_lo),y
    iny
    rts

//////////////////////////////////////////////////////////////////////////////////////
// hint_show — A = msg id; render it to the status bar WITHOUT setting a timer
//////////////////////////////////////////////////////////////////////////////////////
hint_show:
    tay
    lda msg_ptr_lo,y
    sta var_msg_ptr_lo
    lda msg_ptr_hi,y
    sta var_msg_ptr_hi
    jsr msg_render
    rts

//////////////////////////////////////////////////////////////////////////////////////
// hover_update — show a "what am I standing on" hint at the bottom while in range of
// a usable object (or a barrier).  Suppressed while an action message is on screen.
// Only re-renders when the hinted thing changes (var_hover), so no flicker.
//////////////////////////////////////////////////////////////////////////////////////
hover_update:
    lda var_msg_timer
    beq !nomsg+
    lda #$FF                    // action message active → force refresh afterwards
    sta var_hover
    rts
!nomsg:
    jsr search_find_near        // → var_near_obj, zp_ptr_2 at the object
    lda var_near_obj
    cmp #$FF
    beq !nobj+
    ldy #6
    lda (zp_ptr_2_lo),y         // result type
    tax
    lda hint_msg,x              // hint message id for this object
    cmp var_hover
    beq !done+
    sta var_hover
    jsr hint_show
    rts
!nobj:
    // no object — hint a nearby barrier instead
    lda #0
    sta var_summon_crew         // 0 = match any crew (hint mode)
    jsr summon_find_barrier
    lda var_near_bar
    cmp #$FF
    beq !clear+
    ldx var_near_bar
    lda barrier_table+7,x       // barrier hint message
    cmp var_hover
    beq !done+
    sta var_hover
    jsr hint_show
    rts
!clear:
    lda var_hover
    cmp #$FF
    beq !done+
    lda #$FF
    sta var_hover
    jsr status_bar_clear
!done:
    rts
