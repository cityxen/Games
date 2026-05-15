//////////////////////////////////////////////////////////////////
// Meatloaf Hotload Code
// Author: deadline
// Endpoint: TF64RQ
#importonce

///////////////////////////////////////
// URL CONFIG

MLHL_URL:
.encoding "screencode_mixed"
.text "HTTPS://CITYXEN.BIZ/HOTLOAD/?EP=TF64RQ&XXX=XXX"
.byte 0
MLHL_URL_LEN:
.byte (MLHL_URL_LEN-MLHL_URL)

MLHL_URL_COUNT:
.encoding "screencode_mixed"
.text "HTTPS://CITYXEN.BIZ/HOTLOAD/?EP=TF64TC"
.byte 0
MLHL_URL_LEN_COUNT:
.byte (MLHL_URL_LEN_COUNT-MLHL_URL_COUNT)

///////////////////////////////////////

MLHL_HOTLOAD_MSG:
.encoding "petscii_mixed"
.byte $9f
.byte $0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$0d,$1d,$1d,$1d,$1d,$9e
.text "meatloaf.cc > cityxen.biz/hotload"
.byte 0

MLHL_HOTLOAD_LOADING_TEXT:
.encoding "petscii_mixed"
.text "Meatloaf >>> Hotloading..."
.byte 0

///////////////////////////////////////
// Load routine

MLHL_LOAD_COUNT:

    lda SPRITE_ENABLE // disable sprites
    pha
    lda #$00
    sta SPRITE_ENABLE 

    // TODO: disable any other conflicting routines here

    lda MLHL_URL_LEN_COUNT // url length
    ldx #<MLHL_URL_COUNT
    ldy #>MLHL_URL_COUNT
    jsr KERNAL_SETNAM

    lda #$01
    ldx ml_drive_number
    ldy #$00
    jsr KERNAL_SETLFS
    
    lda #00 // Set Load Address
    ldx #<ml_total_trivia
    ldy #>ml_total_trivia
    jsr KERNAL_LOAD
    
    // re-enable disabled routines

    pla
    sta SPRITE_ENABLE // restore Sprite status

    rts

MLHL_LOAD:

    lda SPRITE_ENABLE // disable sprites
    pha
    lda #$00
    sta SPRITE_ENABLE 

    // TODO: disable any other conflicting routines here

    lda MLHL_URL_LEN // url length
    ldx #<MLHL_URL
    ldy #>MLHL_URL
    jsr KERNAL_SETNAM

    lda #$01
    ldx ml_drive_number
    ldy #$00
    jsr KERNAL_SETLFS

    lda #00 // Set Load Address
    ldx #<MLHL_DATA_TABLE
    ldy #>MLHL_DATA_TABLE
    jsr KERNAL_LOAD

    // re-enable disabled routines

    pla
    sta SPRITE_ENABLE // restore Sprite status

    rts
MLHL_LOAD_MSG:
.encoding "petscii_mixed"
.text "loading"
.byte 0
///////////////////////////////////////
// DATA TABLE
MLHL_DATA_TABLE:
.encoding "screencode_upper"
MLHL_DATA_QUESTION:
.text "0123456789012345678901234567890123456789012345678901234567890"
.byte 0
MLHL_DATA_CORRECT:
.byte 0
MLHL_DATA_ANS1:
.text "0123456789012345"
.byte 0
MLHL_DATA_ANS2:
.text "0123456789012345"
.byte 0
MLHL_DATA_ANS3:
.text "0123456789012345"
.byte 0
MLHL_DATA_ANS4:
.text "0123456789012345"
.byte 0

