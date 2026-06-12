//////////////////////////////////////////////////////////////////////////////////////
//
// TRIVIA FIGHTERS 64 for C64
//
//                            by Deadline / CityXen 2026
// 
// Dependencies:
// The include folder from: https://github.com/cityxen/retro-dev-tools/include/commodore64
// must be in kickassembler path in the KickAss.cfg file:
//   -libdir "PATHTO:\dev\cityxen\retro-dev-tools\include\commodore64"
//
// CityXen Videos: https://youtube.com/@cityxen
// CityXen Games: https://cityxen.itch.io
//
//////////////////////////////////////////////////////////////////////////////////////
//
// Loads trivia from the files written by webtrivia-saver.asm:
// TOTAL.TRIVIA (2-byte count) and N.TRIVIA (one record, unpadded
// number). This is the default load source; the meatloaf web
// loader in meatloaf_api.asm is used only when ml_enabled is on.
// 
//////////////////////////////////////////////////////////////////////////////////////

#importonce

///////////////////////////////////////
// Dispatchers — call these instead of MLHL_LOAD / MLHL_LOAD_COUNT

trivia_load: // load one trivia record from current source
    lda ml_enabled
    beq !+
    jmp MLHL_LOAD
!:  jmp LDSK_LOAD

trivia_load_count: // load total trivia count from current source
    lda ml_enabled
    beq !+
    jmp MLHL_LOAD_COUNT
!:  jmp LDSK_LOAD_COUNT

///////////////////////////////////////
// FILE CONFIG

ldsk_drive_number:
.byte 8

ldsk_drive_text:
.encoding "petscii_mixed"
.text "trivia drive (f3):"
.byte 0

LDSK_LOADING_TEXT:
.encoding "petscii_mixed"
.text "Local Disk >>> Loading..."
.byte 0

///////////////////////////////////////
// Set load drive from $BA (KERNAL last device accessed),
// i.e. the drive the game was loaded from

ldsk_init:
    lda $ba
    cmp #$08 // not a disk device (tape/keyboard): default to 8
    bcs !+
    lda #$08
!:  sta ldsk_drive_number

    lda $d012 // seed LFSR from raster line + jiffy clock
    eor $a2
    sta ldsk_rand
    lda $a1
    sta ldsk_rand+1
    lda ldsk_rand // LFSR must not start at zero
    ora ldsk_rand+1
    bne !+
    lda #$a5
    sta ldsk_rand
!:  rts

///////////////////////////////////////
// Print current load drive number (with trailing space
// so 11 -> 8 doesn't leave a stale digit)

ldsk_print_drive:
    lda ldsk_drive_number
    sta numLo
    lda #$00
    sta numHi
    jsr print_decimal
    PrintChr($20)
    rts

LDSK_FILENAME_TOTAL:
.encoding "screencode_mixed"
.text "TOTAL.TRIVIA"
LDSK_FILENAME_TOTAL_END:

ldsk_ext:
.text ".TRIVIA"
ldsk_ext_end:

LDSK_FILENAME: // built at runtime: 1-3 digits + ".TRIVIA"
.fill 10, 0
LDSK_FILENAME_LEN:
.byte 0

ldsk_num: // chosen trivia number (binary, 1..total)
.byte 0,0
ldsk_digits: // ASCII digits of ldsk_num
.byte 0,0,0
ldsk_rand: // 16-bit LFSR state (SID voice 3 is unusable for
.byte $a5, $37 // random here - the music rewrites it constantly)
ldsk_retries: // the first IEC access after game start can return
.byte 0 // DEVICE NOT PRESENT once; the failed attempt resets
        // the bus, so a retry recovers

///////////////////////////////////////
// Load total trivia count from TOTAL.TRIVIA into ml_total_trivia

LDSK_LOAD_COUNT:

    lda SPRITE_ENABLE // disable sprites
    pha
    lda #$00
    sta SPRITE_ENABLE

    lda #$01
    sta ml_hotload_active

    lda #$03
    sta ldsk_retries
!retry:
    lda #(LDSK_FILENAME_TOTAL_END-LDSK_FILENAME_TOTAL) // filename length
    ldx #<LDSK_FILENAME_TOTAL
    ldy #>LDSK_FILENAME_TOTAL
    jsr KERNAL_SETNAM

    lda #$01
    ldx ldsk_drive_number
    ldy #$00
    jsr KERNAL_SETLFS

    lda #00 // Set Load Address
    ldx #<ml_total_trivia
    ldy #>ml_total_trivia
    jsr KERNAL_LOAD
    bcc !+
    dec ldsk_retries
    bne !retry-
!:
    lda #$00
    sta ml_hotload_active

    pla
    sta SPRITE_ENABLE // restore Sprite status

    rts

///////////////////////////////////////
// Load a random trivia record from N.TRIVIA

LDSK_LOAD:

    lda SPRITE_ENABLE // disable sprites
    pha
    lda #$00
    sta SPRITE_ENABLE

    lda #$01
    sta ml_hotload_active

    jsr ldsk_pick_random
    jsr ldsk_build_filename

    lda #$03
    sta ldsk_retries
!retry:
    lda LDSK_FILENAME_LEN // filename length
    ldx #<LDSK_FILENAME
    ldy #>LDSK_FILENAME
    jsr KERNAL_SETNAM

    lda #$01
    ldx ldsk_drive_number
    ldy #$00
    jsr KERNAL_SETLFS

    lda #00 // Set Load Address
    ldx #<MLHL_DATA_TABLE
    ldy #>MLHL_DATA_TABLE
    jsr KERNAL_LOAD
    bcc !+
    dec ldsk_retries
    bne !retry-
!:
    lda #$00
    sta ml_hotload_active

    pla
    sta SPRITE_ENABLE // restore Sprite status

    rts

///////////////////////////////////////
// Pick random ldsk_num in 1..ml_total_trivia

ldsk_pick_random:
    lda ml_total_trivia // no count loaded: fall back to record 1
    ora ml_total_trivia+1
    bne !+
    lda #$01
    sta ldsk_num
    lda #$00
    sta ldsk_num+1
    rts
!:
    jsr ldsk_rand_step
    lda ldsk_rand
    eor $d012 // mix in raster + jiffies so human timing
    eor $a2 // between rounds adds entropy
    sta ldsk_num
    jsr ldsk_rand_step
    lda ldsk_rand
    and #$03 // keep 0-1023, covers max 999 records
    sta ldsk_num+1
!loop: // modulo total by repeated subtraction
    lda ldsk_num+1
    cmp ml_total_trivia+1
    bcc !done+
    bne !sub+
    lda ldsk_num
    cmp ml_total_trivia
    bcc !done+
!sub:
    sec
    lda ldsk_num
    sbc ml_total_trivia
    sta ldsk_num
    lda ldsk_num+1
    sbc ml_total_trivia+1
    sta ldsk_num+1
    jmp !loop-
!done:
    inc ldsk_num // 0..total-1 -> 1..total
    bne !+
    inc ldsk_num+1
!:  rts

///////////////////////////////////////
// 16-bit xorshift LFSR step

ldsk_rand_step:
    lda ldsk_rand+1
    lsr
    lda ldsk_rand
    ror
    eor ldsk_rand+1
    sta ldsk_rand+1
    ror
    eor ldsk_rand
    sta ldsk_rand
    eor ldsk_rand+1
    sta ldsk_rand+1
    rts

///////////////////////////////////////
// Build LDSK_FILENAME ("N.TRIVIA", unpadded) from ldsk_num
// (destroys ldsk_num)

ldsk_build_filename:
    ldx #$30 // hundreds digit
!:  lda ldsk_num+1
    bne !sub+ // >= 256, definitely >= 100
    lda ldsk_num
    cmp #100
    bcc !hdone+
!sub:
    sec
    lda ldsk_num
    sbc #100
    sta ldsk_num
    lda ldsk_num+1
    sbc #$00
    sta ldsk_num+1
    inx
    jmp !-
!hdone:
    stx ldsk_digits

    ldx #$30 // tens digit
    lda ldsk_num
!:  cmp #10
    bcc !tdone+
    sec
    sbc #10
    inx
    jmp !-
!tdone:
    stx ldsk_digits+1
    ora #$30 // ones digit
    sta ldsk_digits+2

    ldx #$00 // find first significant digit
!:  lda ldsk_digits,x
    cmp #$30
    bne !+
    inx
    cpx #$02 // ones digit always significant
    bne !-
!:
    ldy #$00 // copy digits into filename
!:  lda ldsk_digits,x
    sta LDSK_FILENAME,y
    inx
    iny
    cpx #$03
    bne !-

    ldx #$00 // append ".TRIVIA"
!:  lda ldsk_ext,x
    sta LDSK_FILENAME,y
    iny
    inx
    cpx #(ldsk_ext_end-ldsk_ext)
    bne !-
    sty LDSK_FILENAME_LEN
    rts
