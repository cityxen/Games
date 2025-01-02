//////////////////////////////////////////////////////////////////
// CITYXEN COMMODORE 64 LIBRARY
// 
// https://github.com/cityxen/Commodore64_Programming
//
// https://linktr.ee/cityxen
//
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

#importonce

MLHS_ENABLE: .byte 1

MLHS_INIT: // initialize some things
    jsr MLHS_CALC_GET_URL_LEN
    StrCpyL(user_name_empty,user_name,15)
    StrScreenCodeToPetscii(user_name,15)
    rts

MLHS_API_SCORE_MSG:
.encoding "petscii_mixed"
.byte $93,05
.text "        -=*( whackadoodle! )*=-"
.byte $0d
.byte $0d
.text "         last score:"
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
.text "            TOP 10 HIGH SCORES"
.byte $00

MLHS_NL:
.byte $0D,$11,$1D,$1D,$1D,$1D,$1D,$1D,$1D
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
.text "0000000099"
.byte 0
MLHS1b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0
MLHS2a:
.text "0000000089"
.byte 0
MLHS2b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0
MLHS3a:
.text "0000000078"
.byte 0
MLHS3b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0
MLHS4a:
.text "0000000067"
.byte 0
MLHS4b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0
MLHS5a:
.text "0000000056"
.byte 0
MLHS5b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0
MLHS6a:
.text "0000000045"
.byte 0
MLHS6b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0
MLHS7a:
.text "0000000034"
.byte 0
MLHS7b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0
MLHS8a:
.text "0000000023"
.byte 0
MLHS8b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0
MLHS9a:
.text "0000000012"
.byte 0
MLHS9b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0
MLHS10a:
.text "0000000011"
.byte 0
MLHS10b:
.text "CITYXEN"
.byte 0,0,0,0,0,0,0,0,0,0

MLHS_API_URL_RETURN_CODE:
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

///////////////////////////////////////
// URL TABLES

MLHS_API_URL_ADD_SCORE: // text table used for meatloaf file name
.encoding "screencode_mixed"
.text "ML:%WAD" // add real URL here
.text "?S="  	// 9
MLHS_API_URL_AS_SCORE:
.text "SSSSSSSSSS" // fill with score_str
.text "&N=" 	// 35
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

    lda #$30
    ldx #$00
!:
    sta MLHS_API_URL_AS_SCORE,x // fill name and contact with spaces
    inx
    cpx #10
    bne !-

    rts

MLHS_API_SET_SCORE:

    jsr MLHS_API_URL_CLEAR // reset url
    StrCpyL(score_str,MLHS_API_URL_AS_SCORE,10) // fill in user name and contact in the url
    StrCpyL(user_name,MLHS_API_URL_AS_NAME,15)

MLHS_API_LOAD_ADD: // Load routine for Meatloaf URLS

    lda SPRITE_ENABLE
    pha
    lda #$00
    sta SPRITE_ENABLE

    lda #$01
    ldx MLHS_API_DRIVE_NUMBER
    ldy #$00
    jsr KERNAL_SETLFS

    lda #MLHS_API_URL_ADD_SCORE_LENGTH // url length
    ldx #<MLHS_API_URL_ADD_SCORE
    ldy #>MLHS_API_URL_ADD_SCORE
    jsr KERNAL_SETNAM

    lda #00 // Set Load Address
    ldx #<MLHS_API_TOP_10_TABLE
    ldy #>MLHS_API_TOP_10_TABLE
    jsr KERNAL_LOAD
    pla
    sta SPRITE_ENABLE
    rts

MLHS_API_GET_SCORE:
    // reset url
    jsr MLHS_API_URL_CLEAR

MLHS_API_LOAD_GET: // Load routine for Meatloaf URLS

    lda SPRITE_ENABLE
    pha
    lda #$00
    sta SPRITE_ENABLE

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
    pla
    sta SPRITE_ENABLE
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
    PrintChr($20)
    Print(user_name)
    PrintChr($20)
    PrintNoLeadingZeros(score_str)

	Print(MLHS_API_HISCORE_MSG)
    
	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS1a)
    PrintChr($20)
	Print(MLHS1b)

	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS2a)
    PrintChr($20)
	Print(MLHS2b)

	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS3a)
    PrintChr($20)
	Print(MLHS3b)

	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS4a)
    PrintChr($20)
	Print(MLHS4b)

	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS5a)
    PrintChr($20)
	Print(MLHS5b)

	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS6a)
    PrintChr($20)
	Print(MLHS6b)

	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS7a)
    PrintChr($20)
	Print(MLHS7b)

	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS8a)
    PrintChr($20)
	Print(MLHS8b)

	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS9a)
    PrintChr($20)
	Print(MLHS9b)

	Print(MLHS_NL)
	PrintLeadingZerosAsSpaces(MLHS10a)
    PrintChr($20)
	Print(MLHS10b)

	rts


MLHS_NAME_ENTRY:
    lda #$00
    sta SPRITE_ENABLE
	lda #$02
	sta $d020
	sta $d021
	lda #$93
	jsr $ffd2
	StrCpyL(user_name_empty,user_name,15)
	Print(MLHS_API_ENTER_MSG)
    DrawScore(28,7)
	InputText2(user_name,15,15,9,1)
    StrScreenCodeToPetscii(user_name,15)
    jsr MLHS_API_SET_SCORE
	rts
