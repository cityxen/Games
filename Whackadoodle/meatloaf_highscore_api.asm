///////////////////////////////////////
// Kickassembler plugin for
// using Meatloaf HiScore API
// By Deadline / CityXen
// And Jaime / Idolpx / Meatloaf
// 2024
//
// Uses CityXen C64 lib:
// Constants.asm
// score.il.asm
// print.il.asm
// input.il.asm
// https://github.com/cityxen/Commodore64_Programming

MLHS_ENABLE: .byte 1

MLHS_INIT: // initialize some things
    jsr MLHS_CALC_GET_URL_LEN
    rts

MLHS_API_SCORE_MSG:
.encoding "petscii_mixed"
.byte $93,05
.text "             last score:"
.byte 0

MLHS_API_ENTER_MSG:
.encoding "petscii_mixed"
.byte $93,05
.byte KEY_CURSOR_DOWN,KEY_CURSOR_DOWN,KEY_CURSOR_DOWN
.byte KEY_CURSOR_DOWN,KEY_CURSOR_DOWN
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.text "game over!"
.byte $0d,$0d
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.text "submit your score: "
.byte $0d,$0d
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.byte KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT,KEY_CURSOR_RIGHT
.text "name: "
.byte $0d,$0d
.byte $0d,$0d
.text "web enabled hiscore powered by meatloaf"
.byte $0d,$0d
.text "          https://meatloaf.cc/"
.byte 0

MLHS_API_HISCORE_MSG:
.encoding "screencode_mixed"
.byte $0d
.byte $0d
.text "          TOP 10 HIGH SCORES"
.byte $00

MLHS_NL:
.byte $0D,$11,$1D,$1D,$1D,$1D,$1D,$1D,$1D
.byte $00

MLHS_NAME_NL:
.byte $0D,KEY_CURSOR_UP
.byte $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
.byte $1D,$1D,$1D,$1D,$1D,$1D,$1D
.byte $00

MLHS_API_DRIVE_NUMBER:
.byte 8

MLHS_API_USER_CONTACT:
.text "NNNNNNNNNNNNNNNN"
.byte 0
MLHS_API_USER_NAME:
.text "NNNNNNNNNNNNNNNN"
.byte 0

///////////////////////////////////////
// DATA AREA FOR TOP 10 SCORES

MLHS_API_TOP_10_TABLE:
.encoding "screencode_mixed"
MLHS1a:
.text "1100000010"
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
.text "SSSSSSSSSS" // fill with score_str
.text "&n=" 	// 35
MLHS_API_URL_AS_NAME:
.text "NNNNNNNNNNNNNNNNN"
.byte 0			// 52
MLHS_API_URL_ADD_SCORE_LENGTH:
.byte 0

///////////////////////////////////////

MLHS_API_URL_GET_SCORE:
.encoding "screencode_mixed"
.text "ML:%WAD" // change your URL here
.text "?a="
MLHS_API_URL_GS_NUM: // top 10 designation
.text "10"
MLHS_API_URL_GET_SCORE_LENGTH:
.byte 0

///////////////////////////////////////

MLHS_CALC_GET_URL_LEN: // calculate URL lengths and put in the proper place
    lda #(MLHS_API_URL_GET_SCORE_LENGTH-MLHS_API_URL_GET_SCORE)
    sta MLHS_API_URL_GET_SCORE_LENGTH
    lda #(MLHS_API_URL_ADD_SCORE_LENGTH-MLHS_API_URL_ADD_SCORE)
    sta MLHS_API_URL_ADD_SCORE_LENGTH
    rts

///////////////////////////////////////
// END URL TABLES
///////////////////////////////////////

MLHS_API_URL_CLEAR: // clear user datas in url
    lda #$20
    ldx #$00
!:
    sta MLHS_API_URL_AS_NAME,x // fill name and contact with spaces
    inx
    cpx #16
    bne !-
    ldx #$00
!:
    sta MLHS_API_URL_AS_SCORE,x // fill name and contact with spaces
    inx
    cpx #10
    bne !-

    rts

MLHS_API_SET_SCORE:

    jsr MLHS_API_URL_CLEAR // reset url
    // fill in user name and contact in the url
    StrCpy(score_str,MLHS_API_URL_AS_SCORE,10)
    StrCpy(user_name,MLHS_API_URL_AS_NAME,16)

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

MLHS_DRAW:
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

    Print(MLHS_API_SCORE_MSG)
    DrawScore(24,0)

	Print(MLHS_API_HISCORE_MSG)
    
	Print(MLHS_NL)
	PrintNSZ(MLHS1a)
    
    Print(MLHS_NAME_NL)
	Print(MLHS1b)

	Print(MLHS_NL)
	PrintNSZ(MLHS2a)

    Print(MLHS_NAME_NL)
	Print(MLHS2b)

	Print(MLHS_NL)
	PrintNSZ(MLHS3a)

    Print(MLHS_NAME_NL)
	Print(MLHS3b)

	Print(MLHS_NL)
	PrintNSZ(MLHS4a)

    Print(MLHS_NAME_NL)
	Print(MLHS4b)

	Print(MLHS_NL)
	PrintNSZ(MLHS5a)

    Print(MLHS_NAME_NL)
	Print(MLHS5b)

	Print(MLHS_NL)
	PrintNSZ(MLHS6a)

    Print(MLHS_NAME_NL)
	Print(MLHS6b)

	Print(MLHS_NL)
	PrintNSZ(MLHS7a)

    Print(MLHS_NAME_NL)
	Print(MLHS7b)

	Print(MLHS_NL)
	PrintNSZ(MLHS8a)

    Print(MLHS_NAME_NL)
	Print(MLHS8b)

	Print(MLHS_NL)
	PrintNSZ(MLHS9a)

    Print(MLHS_NAME_NL)
	Print(MLHS9b)

	Print(MLHS_NL)
	PrintNSZ(MLHS10a)

    Print(MLHS_NAME_NL)
	Print(MLHS10b)

	rts


MLHS_NAME_ENTRY:
	lda #$02
	sta $d020
	sta $d021
	lda #$93
	jsr $ffd2
	StrCpy(user_name_empty,user_name,15)
	Print(MLHS_API_ENTER_MSG)
    DrawScore(28,7)
	InputText2(user_name,15,15,9,1)
	rts
