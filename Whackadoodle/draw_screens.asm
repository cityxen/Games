
//////////////////////////////////////////////////////////////////
// Draw main screen

draw_main_screen:
	DrawPetMateScreen(was1)
	jsr debug_stuff
	jsr init_sprites_ms
	rts

//////////////////////////////////////////////////////////////////
// Draw Instruct Screen

draw_instruct:
	DrawPetMateScreen(instruct)
	jsr debug_stuff
	jsr init_sprites_iiy
 	rts 

//////////////////////////////////////////////////////////////////
// Draw Play Screen

draw_hiscores:

	jsr init_sprites_ms
	lda #$05
	sta $d020
	sta $d021
	lda #$05
	jsr $ffd2
	lda #$93
	jsr $ffd2

	ldx #$00
!:
	lda hiscore_msg,x
	cmp #$ff
	beq !+
	jsr $ffd2
	inx
	jmp !-
!:

	lda #<MLHS_API_TOP_10_TABLE
	sta $14
	lda #>MLHS_API_TOP_10_TABLE
	sta $15

	lda #<$04a6
	sta $03
	lda #>$04a6
	sta $04

	ldx #$00
	stx cscr

dhs_a:
	
	ldy #$00
	sty count
	lda ($fd),y // get 4 byte score
	cmp #$ff
	bne !+
	rts
!:	
	lda ($14),y
	sta whack_score_lo  // we only need lower 2 bytes for whackadoodle
	jsr inc_zpa	
	lda ($14),y
	sta whack_score_hi
	jsr inc_zpa
	lda ($14),y
	jsr inc_zpa
	lda ($14),y 		// end 4 byte score
	jsr inc_zpa
	
			
	pha
	txa
	pha
	tya
	pha

	jsr update_score

	pla
	tay
	pla
	tax
	pla
	
	ldy #$05
    lda whack_score_1
	sta ($03),y
	dey
    lda whack_score_2
	sta ($03),y
	dey
    lda whack_score_3
	sta ($03),y
	dey
    lda whack_score_4
	sta ($03),y
	dey
    lda whack_score_5
	sta ($03),y
	dey
    lda whack_score_6
	sta ($03),y
	dey
	ldy #$00
	jsr inc_scr
	jsr inc_scr
	jsr inc_scr
	jsr inc_scr
	jsr inc_scr
	jsr inc_scr
	jsr inc_scr

!:
	lda ($14),y // get name here
	sta ($03),y
	jsr inc_zpa
	jsr inc_scr
	
	inc count
	lda count
	cmp #16
	bne !-
	

	clc
	lda $03
	adc #57
	sta $03
	bcc !+
	inc $04
!:

	inc cscr
	lda cscr
	cmp #10
	beq !+
	ldx #$00
	ldy #$00

	jmp dhs_a
!:
	rts
count:
.byte 0
cscr:
.byte 0
hs_table:
.byte $05,$93
.byte $ff

inc_scr:
	inc $03
	bne !+
	inc $04
!:
	
	rts

inc_zpa:
	lda ($14),y
	cmp #$ff
	beq !+
	inc $14
	bne !++
	inc $15
	jmp !++
!:
	lda #<MLHS_API_TOP_10_TABLE
	sta $14
	lda #>MLHS_API_TOP_10_TABLE
	sta $15
!:

	rts




//////////////////////////////////////////////////////////////////
// Draw Play Screen

draw_play_screen:
	DrawPetMateScreen(play)
 	rts

//////////////////////////////////////////////////////////////////
// Draw game over

draw_gameover:
	DrawPetMateScreen(scr_gameover)
	jsr debug_stuff
	jsr init_sprites_ms
	jsr draw_score_game_over
	rts

//////////////////////////////////////////////////////////////////
// Draw QR

draw_qr:
	DrawPetMateScreen(qrcode)
	jsr init_sprites_ms
 	rts 	

//////////////////////////////////////////////////////////////////
// Update Play Screen

update_play_screen:
 	rts 