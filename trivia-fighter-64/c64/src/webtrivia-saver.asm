//////////////////////////////////////////////////////////////////
// Web Trivia Saver
// Author: deadline
//
// Standalone tool: fetches the total trivia count from the server,
// then loads web trivia records 1-total from Meatloaf (drive 8)
// via the hotload endpoint with &id=N appended to the URL
// (unpadded), and saves each record to drive 9 as N.trivia
//
// Build: KickAss.bat src/webtrivia-saver.asm

#import "Constants.asm"
#import "Macros.asm"

.const WTS_LOAD_DRIVE = 8
.const WTS_SAVE_DRIVE = 9

.const zp_save_ptr_lo = $fb
.const zp_save_ptr_hi = $fc
.const zp_print_ptr_lo = $fd
.const zp_print_ptr_hi = $fe

CityXenUpstart(start)
start:
    jmp wts_start
#import "sys.il.asm"
#import "print.il.asm"

wts_start:
    PrintLowerCase()
    jsr wts_load_count // get total trivia count from server
    lda wts_total
    ora wts_total+1
    beq wts_done // no count loaded, nothing to do
    jsr wts_save_total // save count to disk as total.trivia

wts_loop:
    jsr wts_next_number // build next trivia number into URL + filename

    jsr wts_load
    bcs wts_skip // load failed, skip save
    jsr wts_print_record
    jsr wts_save

wts_next:
    inc wts_count // 16-bit increment
    bne !+
    inc wts_count+1
!:  lda wts_count // loop until count == total
    cmp wts_total
    bne wts_loop
    lda wts_count+1
    cmp wts_total+1
    bne wts_loop

wts_done:
    ldx #$00 // print done message
!:  lda wts_done_msg,x
    beq !+
    jsr KERNAL_CHROUT
    inx
    bne !-
!:  rts

wts_skip:
    lda #$3f // print '?' for failed load
    jsr KERNAL_CHROUT
    jmp wts_next

///////////////////////////////////////
// Advance to next trivia number and patch URL + filename
// with unpadded ASCII digits, setting both lengths

wts_next_number:
    ldx #$02 // increment 3-digit ASCII counter
!:  inc wts_num,x
    lda wts_num,x
    cmp #$3a // past '9'?
    bne !+
    lda #$30 // '0', carry into next digit
    sta wts_num,x
    dex
    bpl !-
!:
    ldx #$00 // find first significant digit
!:  lda wts_num,x
    cmp #$30
    bne !+
    inx
    cpx #$02 // ones digit always significant
    bne !-
!:
    ldy #$00 // copy digits into URL tail and filename
!:  lda wts_num,x
    sta wts_url_num,y
    sta wts_filename,y
    inx
    iny
    cpx #$03
    bne !-

    tya // url length = prefix + digit count
    clc
    adc #(wts_url_num-wts_url)
    sta wts_url_len

    ldx #$00 // append ".TRIVIA" to filename
!:  lda wts_trivia_ext,x
    sta wts_filename,y
    iny
    inx
    cpx #(wts_trivia_ext_end-wts_trivia_ext)
    bne !-
    sty wts_filename_len
    rts

///////////////////////////////////////
// Print number, question, correct, ans1-4, then a blank line

wts_print_record:
    ldx #$00 // print number (digits up to '.')
!:  lda wts_filename,x
    cmp #$2e // '.'
    beq !+
    jsr KERNAL_CHROUT
    inx
    bne !-
!:  lda #$0d
    jsr KERNAL_CHROUT

    Print(MLHL_DATA_QUESTION)
	PrintLF()

    lda MLHL_DATA_CORRECT // ASCII digit '1'..'4'
    jsr KERNAL_CHROUT
    PrintLF()

    Print(MLHL_DATA_ANS1)
	PrintLF()
    Print(MLHL_DATA_ANS2)
	PrintLF()
    Print(MLHL_DATA_ANS3)
	PrintLF()
    Print(MLHL_DATA_ANS4)
	PrintLF()

    lda #$0d // blank line between records
    jmp KERNAL_CHROUT

///////////////////////////////////////
// Load total trivia count from drive 8 (Meatloaf)
// into wts_total (2 bytes, lo/hi)

wts_load_count:
    lda #(wts_url_count_end-wts_url_count) // url length
    ldx #<wts_url_count
    ldy #>wts_url_count
    jsr KERNAL_SETNAM

    lda #$01
    ldx #WTS_LOAD_DRIVE
    ldy #$00
    jsr KERNAL_SETLFS

    lda #00 // Set Load Address
    ldx #<wts_total
    ldy #>wts_total
    jsr KERNAL_LOAD
    rts

///////////////////////////////////////
// Load one web trivia record from drive 8 (Meatloaf)

wts_load:
    lda wts_url_len // url length
    ldx #<wts_url
    ldy #>wts_url
    jsr KERNAL_SETNAM

    lda #$01
    ldx #WTS_LOAD_DRIVE
    ldy #$00
    jsr KERNAL_SETLFS

    lda #00 // Set Load Address
    ldx #<MLHL_DATA_TABLE
    ldy #>MLHL_DATA_TABLE
    jsr KERNAL_LOAD
    rts

///////////////////////////////////////
// Save total trivia count (2 bytes) to drive 9 as total.trivia

wts_save_total:
    lda #(wts_total_fname_end-wts_total_fname) // filename length
    ldx #<wts_total_fname
    ldy #>wts_total_fname
    jsr KERNAL_SETNAM

    lda #$01
    ldx #WTS_SAVE_DRIVE
    ldy #$01
    jsr KERNAL_SETLFS

    lda #<wts_total // Set Start Address
    sta zp_save_ptr_lo
    lda #>wts_total
    sta zp_save_ptr_hi
    ldx #<(wts_total+2) // Set End Address
    ldy #>(wts_total+2)
    lda #zp_save_ptr_lo
    jsr KERNAL_SAVE
    rts

///////////////////////////////////////
// Save loaded record to drive 9 as N.trivia

wts_save:
    lda wts_filename_len // filename length
    ldx #<wts_filename
    ldy #>wts_filename
    jsr KERNAL_SETNAM

    lda #$01
    ldx #WTS_SAVE_DRIVE
    ldy #$01
    jsr KERNAL_SETLFS

    lda #<MLHL_DATA_TABLE // Set Start Address
    sta zp_save_ptr_lo
    lda #>MLHL_DATA_TABLE
    sta zp_save_ptr_hi
    ldx #<MLHL_DATA_TABLE_END // Set End Address (whole table)
    ldy #>MLHL_DATA_TABLE_END
    lda #zp_save_ptr_lo
    jsr KERNAL_SAVE
    rts

///////////////////////////////////////
// URL CONFIG

wts_url:
.encoding "screencode_mixed"
.text "HTTPS://CITYXEN.BIZ/HOTLOAD/?EP=TF64RQ&ID="
wts_url_num:
.fill 3, $30 // digits patched here, 1-3 chars used
wts_url_len:
.byte 0

wts_url_count:
.encoding "screencode_mixed"
.text "HTTPS://CITYXEN.BIZ/HOTLOAD/?EP=TF64TC"
wts_url_count_end:

wts_trivia_ext:
.text ".TRIVIA"
wts_trivia_ext_end:

wts_total_fname:
.text "TOTAL.TRIVIA"
wts_total_fname_end:

wts_filename:
.fill 10, 0 // up to 3 digits + ".TRIVIA"
wts_filename_len:
.byte 0

wts_num: // ASCII counter "000".."999"
.text "000"

wts_done_msg:
.encoding "petscii_mixed"
.byte $0d
.text "done."
.byte $0d,0

///////////////////////////////////////

wts_count: // records processed (16-bit)
.byte 0,0

wts_total: // total trivia count from server (16-bit)
.byte 0,0

///////////////////////////////////////
// DATA TABLE
MLHL_DATA_TABLE:
.encoding "screencode_upper"
MLHL_DATA_QUESTION:
.text "this question means nothing was loaded!"
.byte 0
.text "012345678901234567890"
.byte 0
MLHL_DATA_CORRECT:
.byte 0
MLHL_DATA_ANS1:
.text "0123456789012"
.byte 0,0,0,0
MLHL_DATA_ANS2:
.text "0123456789012"
.byte 0,0,0,0
MLHL_DATA_ANS3:
.text "0123456789012"
.byte 0,0,0,0
MLHL_DATA_ANS4:
.text "0123456789012"
.byte 0,0,0,0
MLHL_DATA_TABLE_END:
