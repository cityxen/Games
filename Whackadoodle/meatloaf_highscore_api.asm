///////////////////////////////////////
// Kickassembler plugin for
// using Meatloaf HiScore API
// By Deadline / CityXen
// And Jaime / Idolpx / Meatloaf
// 2024

meatloaf_hiscore_support: .byte 1

MLHS_API_HISCORE_MSG:
.encoding "screencode_mixed"
.text "           TOP 10 HIGH SCORES"
.byte $00

MLHS_NL:
.byte $0D,$11,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
.byte $00

MLHS_API_DRIVE_NUMBER:
.byte 11

MLHS_API_USER_CONTACT:
.text "NNNNNNNNNNNNNNNN"
.byte 0
MLHS_API_USER_NAME:
.text "NNNNNNNNNNNNNNNN"
.byte 0

///////////////////////////////////////
// DATA AREA FOR TOP 10 SCORES

MLHS_API_TOP_10_TABLE:
.byte 0
.encoding "screencode_mixed"
MLHS1a:
.text "0000000010"
.byte 0
MLHS1b:
.text "UNRANKED SCORE 1"
.byte 0
MLHS2a:
.text "0000000009"
.byte 0
MLHS2b:
.text "UNRANKED SCORE 2"
.byte 0
MLHS3a:
.text "0000000008"
.byte 0
MLHS3b:
.text "UNRANKED SCORE 3"
.byte 0
MLHS4a:
.text "0000000007"
.byte 0
MLHS4b:
.text "UNRANKED SCORE 4"
.byte 0
MLHS5a:
.text "0000000006"
.byte 0
MLHS5b:
.text "UNRANKED SCORE 5"
.byte 0
MLHS6a:
.text "0000000005"
.byte 0
MLHS6b:
.text "UNRANKED SCORE 6"
.byte 0
MLHS7a:
.text "0000000004"
.byte 0
MLHS7b:
.text "UNRANKED SCORE 7"
.byte 0
MLHS8a:
.text "0000000003"
.byte 0
MLHS8b:
.text "UNRANKED SCORE 8"
.byte 0
MLHS9a:
.text "0000000002"
.byte 0
MLHS9b:
.text "UNRANKED SCORE 9"
.byte 0
MLHS10a:
.text "0000000001"
.byte 0
MLHS10b:
.text "UNRANKED SCORE A"
.byte 0

MLHS_API_URL_RETURN_CODE:
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

///////////////////////////////////////
// URL TABLES
MLHS_API_URL_ADD_SCORE: // text table used for meatloaf file name
.encoding "screencode_mixed"
.text "ML:%WAD" // add real URL here
.text "?s="  	// 9
MLHS_API_URL_AS_SCORE:
.text "SSSS" 	// 4 byte score // 13
.text "&c=" 	// 16
MLHS_API_URL_AS_CONTACT:
.text "NNNNNNNNNNNNNNNNN" // 32
.text "&n=" 	// 35
MLHS_API_URL_AS_NAME:
.text "NNNNNNNNNNNNNNNNN"
.byte 0			// 52
MLHS_API_URL_ADD_SCORE_LENGTH:
.byte 52
///////////////////////////////////////
///////////////////////////////////////
MLHS_API_URL_GET_SCORE:  // get all scores unless n=NUM, then it will return NUM results
                // in our case we want 10
.encoding "screencode_mixed"
.text "ML:%WAD" // add real URL here
.text "?a="
MLHS_API_URL_GS_NUM: // top 10 designation
.text "10"
MLHS_API_URL_GET_SCORE_LENGTH:
.byte 13

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

    // lda MLHS_API_SCORE+2
    sta MLHS_API_URL_AS_SCORE+2
    // lda MLHS_API_SCORE+3
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
    lda #00 // Set Load Address
    ldx #<MLHS_API_TOP_10_TABLE
    ldy #>MLHS_API_TOP_10_TABLE

    //ldx #01 // Set Load Address
    //ldy #<MLHS_API_URL_RETURN_CODE
    //lda #>MLHS_API_URL_RETURN_CODE
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

	PrintSTZ(MLHS_API_HISCORE_MSG)
    PrintSTZ(MLHS_NL)
    
	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS1a)
    PrintSPC()    
	PrintSTZ(MLHS1b)

	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS2a)
    PrintSPC()
	PrintSTZ(MLHS2b)

	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS3a)
    PrintSPC()
	PrintSTZ(MLHS3b)

	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS4a)
    PrintSPC()
	PrintSTZ(MLHS4b)

	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS5a)
    PrintSPC()
	PrintSTZ(MLHS5b)

	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS6a)
    PrintSPC()
	PrintSTZ(MLHS6b)

	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS7a)
    PrintSPC()
	PrintSTZ(MLHS7b)

	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS8a)
    PrintSPC()
	PrintSTZ(MLHS8b)

	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS9a)
    PrintSPC()
	PrintSTZ(MLHS9b)

	PrintSTZ(MLHS_NL)
	PrintNZ(MLHS10a)
    PrintSPC()
	PrintSTZ(MLHS10b)

	rts
