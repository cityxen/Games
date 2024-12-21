///////////////////////////////////////
// Kickassembler plugin for
// using Meatloaf HiScore API
// By Deadline / CityXen
// And Jaime / Idolpx / Meatloaf
// 2024

meatloaf_hiscore_support: .byte 1

MLHS_API_HISCORE_MSG:
.encoding "screencode_mixed"
.text "   TOP 10 WHACKADOODLE HI SCORES"
.byte $ff

MLHS_API_HISCORE_NL_MSG:
.byte $0D,$11,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
.byte $ff

MLHS_API_SCORE: // 4 Bytes
.byte 0
.byte 0
.byte whack_score_lo
.byte whack_score_hi

MLHS_API_DRIVE_NUMBER:
.byte 8

MLHS_API_USER_CONTACT:
.text "NNNNNNNNNNNNNNNN"
.byte 0
MLHS_API_USER_NAME:
.text "NNNNNNNNNNNNNNNN"
.byte 0
MLHS_API_USER_SCORE:
.byte 0,0,0,0

///////////////////////////////////////
// DATA AREA FOR TOP 10 SCORES
.const zp_MLT    = $02
.const zp_MLT_lo = $02
.const zp_MLT_hi = $03
//     012345678901234567890123456789012
//               1         2         3 
MLHS_API_TOP_10_TABLE:
.encoding "screencode_mixed"
.byte 0,0,10,0 // lo byte, hi byte score
.text "UNRANKED SCORE1 "
.byte 0,0,9,0 // lo byte, hi byte score
.text "UNRANKED SCORE2 "
.byte 0,0,8,0 // lo byte, hi byte score
.text "UNRANKED SCORE3 "
.byte 0,0,7,0 // lo byte, hi byte score
.text "UNRANKED SCORE4 "
.byte 0,0,6,0 // lo byte, hi byte score
.text "UNRANKED SCORE5 "
.byte 0,0,5,0 // lo byte, hi byte score
.text "UNRANKED SCORE6 "
.byte 0,0,4,0 // lo byte, hi byte score
.text "UNRANKED SCORE7 "
.byte 0,0,3,0 // lo byte, hi byte score
.text "UNRANKED SCORE8 "
.byte 0,0,2,0 // lo byte, hi byte score
.text "UNRANKED SCORE9 "
.byte 0,0,1,0 // lo byte, hi byte score
.text "UNRANKED SCORE10"
.byte $ff

MLHS_API_URL_RETURN_CODE:
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

///////////////////////////////////////
// URL TABLES
MLHS_API_URL_ADD_SCORE: // text table used for meatloaf file name
.encoding "screencode_mixed"
.text "ML:%WAD" // add real URL here
///////0123456789012345678901234567890
///////          1         2         3
// parameters
.text "?s="  // 9
MLHS_API_URL_AS_SCORE:
.text "SSSS" // 4 byte score // 13
.text "&c=" // 16
MLHS_API_URL_AS_CONTACT:
.text "NNNNNNNNNNNNNNNNN" // 32
.text "&n=" // 35
MLHS_API_URL_AS_NAME:
.text "NNNNNNNNNNNNNNNNN" // 48
//     012345678901234567890123456789012
.text "&x=" // 51
MLHS_API_URL_AS_TOKEN: // 16 byte security token (this is not the name of the game)
.text "XXXXXXXXXXXXXXXXX" // 67
.text "&end" // 4 byte end header // 71
.byte 0
MLHS_API_URL_ADD_SCORE_LENGTH:
.byte 71
///////////////////////////////////////
///////////////////////////////////////
MLHS_API_URL_GET_SCORE:  // get all scores unless n=NUM, then it will return NUM results
                // in our case we want 10
.encoding "screencode_mixed"
.text "ML:%WAD" // add real URL here
.byte 0
.text "?a=" // 33
MLHS_API_URL_GS_NUM: // top 10 designation
.text "10" // 35
.text "&x=" // set game identifier // 38
//MLHS_API_URL_GS_TOKEN: // 16 byte security token (this is not the name of the game)
//.text "XXXXXXXXXXXXXXXXX" // 54
//.text "&end" // 4 byte end header // 58
MLHS_API_URL_GET_SCORE_LENGTH:
.byte 7

// add another url to check if current score is the new high score

///////////////////////////////////////
// END URL TABLES
///////////////////////////////////////

MLHS_API_URL_CLEAR: // clear user datas in url
    lda #$20
    ldx #$00
!:
    sta MLHS_API_URL_AS_NAME,x // fill name and contact with spaces
    sta MLHS_API_URL_AS_CONTACT,x // (add score url)
    inx
    cpx #33
    bne !-
    rts

MLHS_API_SET_SCORE:
    jsr MLHS_API_URL_CLEAR // reset url
    // fill in user name and contact in the url
    ldx #$00
!:
    lda MLHS_API_USER_NAME,x
    sta MLHS_API_URL_AS_NAME,x
    lda MLHS_API_USER_CONTACT,x
    sta MLHS_API_URL_AS_CONTACT,x
    inx
    cpx #33
    bne !-
    // fill in the score into the url
    lda #$00
    sta MLHS_API_URL_AS_SCORE
    lda #$00
    sta MLHS_API_URL_AS_SCORE+1
    lda MLHS_API_SCORE+2
    sta MLHS_API_URL_AS_SCORE+2
    lda MLHS_API_SCORE+3
    sta MLHS_API_URL_AS_SCORE+3
MLHS_API_LOAD_ADD: // Load routine for Meatloaf URLS
    lda #$0f
    ldx MLHS_API_DRIVE_NUMBER
    ldy #$ff
    jsr KERNAL_SETLFS
    lda #MLHS_API_URL_ADD_SCORE_LENGTH // url length
    ldx #<MLHS_API_URL_ADD_SCORE
    ldy #>MLHS_API_URL_ADD_SCORE
    jsr KERNAL_SETNAM
    ldx #01 // Set Load Address
    ldy #<MLHS_API_URL_RETURN_CODE
    lda #>MLHS_API_URL_RETURN_CODE
    jsr KERNAL_LOAD
    rts

MLHS_API_GET_SCORE:
    // reset url
    jsr MLHS_API_URL_CLEAR
MLHS_API_LOAD_GET: // Load routine for Meatloaf URLS

    lda #$01
    ldx MLHS_API_DRIVE_NUMBER
    ldy #$00
    jsr KERNAL_SETLFS

    lda MLHS_API_URL_GET_SCORE_LENGTH // url length
    ldx #<MLHS_API_URL_GET_SCORE
    ldy #>MLHS_API_URL_GET_SCORE
    jsr KERNAL_SETNAM

    lda #00 // Set Load Address
    ldx #<MLHS_API_TOP_10_TABLE
    ldy #>MLHS_API_TOP_10_TABLE
    jsr KERNAL_LOAD
    rts
    


//////////////////////////////////////////////////////////////////
// Draw Hi Scores Screen (Meatloaf)

draw_meatloaf_hiscores:
	jsr wait_vbl

	lda #$00 // clear sprites
	sta SPRITE_ENABLE

	lda #$05
	sta $d020
	sta $d021
	lda #$05
	jsr $ffd2
	lda #$93	
	jsr $ffd2

	ldx #$00
!:
	lda MLHS_API_HISCORE_MSG,x
	cmp #$ff
	beq !+
	jsr $ffd2
	inx
	jmp !-
!:

	NL()

	lda #<MLHS_API_TOP_10_TABLE
	sta zp_MLT_lo
	lda #>MLHS_API_TOP_10_TABLE
	sta zp_MLT_hi

	lda #$00
	sta mlhs_cursor
	sta mlhs_count

dmhs_start:

	inc mlhs_cursor
	inc mlhs_cursor
	ldy mlhs_cursor
	lda (zp_MLT),y
	sta zp_tmp_lo
	inc mlhs_cursor
	ldy mlhs_cursor
	lda (zp_MLT),y
	sta zp_tmp_hi

	DrawScoreML()
	
	lda #$20
	jsr $ffd2

	lda #$00
	sta mlhs_cursor2	
!:
	inc mlhs_cursor
	ldy mlhs_cursor
	lda (zp_MLT),y
	jsr $ffd2
	inc mlhs_cursor2
	lda mlhs_cursor2
	cmp #16
	bne !-
	NL()

	inc mlhs_cursor
	inc mlhs_count
	lda mlhs_count
	cmp #10
	beq !+
	jmp dmhs_start
!:
	rts

mlhs_cursor:  .byte 0
mlhs_cursor2: .byte 0
mlhs_count: .byte 0

.macro NL() {
	ldx #$00
!:
	lda MLHS_API_HISCORE_NL_MSG,x
	cmp #$ff
	beq !+
	jsr $ffd2
	inx
	jmp !-
!:
}

.macro DrawScoreML() {
	sty mlhs_cursor
	lda zp_tmp_hi
	ldx zp_tmp_lo
	jsr $bdcd
	ldy mlhs_cursor
}
