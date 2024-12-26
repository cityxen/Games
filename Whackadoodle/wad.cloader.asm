// CityXen - CART PRG Loader
// ported to Kick Assembler and modified
// by Jaime Idolpx (20241212)

            .file [name="%o.bin", type="bin", segments="loader"]

            .segment loader [min=$8000, max=$9fff, fill]  // Make 8K BIN file
            * = $8000 "main"
            .const cart_bank     = $57             // $0057-$005B Arithmetic register #3 (5 bytes).
            .const prg_size_low  = $58
            .const prg_size_high = $59
            .const prg_data_low  = $5A
            .const prg_data_high = $5B
            .const prg_dest_low  = $2D             // $002D-$002E Pointer to beginning of variable area. (End of program plus 1.)
            .const prg_dest_high = $2E
            .const screen_dest   = $0400
            .const tag_dest      = $07C0

            .word loader_start  // COLD START CART LOADER
            .word loader_start  // WARM START CART LOADER
            .encoding "petscii_mixed"
            .text "CBM80"

loader_start:
            sei
            stx $d016           // VIC control
            jsr $fda3           // Kernal Init I/O
            jsr $fd50           // Kernal Init Memory Pointers
            lda #$a0
            sta $0284           // Pointer to end of BASIC area after memory test. $a0
            jsr $fd15           // Kernal Restore I/O vectors
            jsr $ff5b           // Kernal Init Video
            cli
            jsr $e453           // initialise the BASIC vectors
            jsr $e3bf           // initialise the BASIC RAM locations
            jsr $e422           // print the start up message and initialise the memory pointers
            ldx #$fb
            txs

// Set PRG size, load address, data pointer in zero page
init:
            lda #$00
            sta cart_bank
            lda prg_size
            sta prg_size_low
            lda prg_size + 1
            sta prg_size_high
            lda prg_data
            sta prg_dest_low
            lda prg_data + 1
            sta prg_dest_high
            lda #<(prg_data + 2)    // Skip load address
            sta prg_data_low
            lda #>prg_data
            sta prg_data_high
            ldx #$00

// Copy tag to screen
!loop:
            lda tag,x
            beq break
            sta tag_dest,x
            inx
            bne !loop-
break:      ldx #$00

// Copy loader to screen and run!
!loop:
            lda screen_loader,x
            sta screen_dest,x
            inx
            bne !loop-
            jmp screen_dest

// Screen Loader
screen_loader:
            sei
            ldx #$00

prg_load_block:
            lda (prg_data_low,x)
            sta (prg_dest_low,x)
            sta $d020
            inc prg_data_low
            bne prg_next_dest

prg_next_block:
            inc prg_data_high
            lda prg_data_high
            cmp #$a0
            bne prg_next_dest
            lda #$80
            sta prg_data_high

prg_next_dest:
            inc prg_dest_low
            bne prg_next_src
            inc prg_dest_high

prg_next_src:
            dec prg_size_low
            bne prg_load_block
            dec prg_size_high
            lda prg_size_high
            cmp #$ff
            bne prg_load_block

start_prg:
            jsr $a663          // RESET BASIC
            cli
            jmp $a7ae          // RUN!
            rts

// TAG & PRG Data
tag:        .encoding "screencode_upper"
            .text @"CITYXEN!\$00"
prg_size:
            .var data = LoadBinary("prg_files/wad-cxn-e.prg")   // program must be exomized and less than 8000 bytes
            .word data.getSize()-2              // program size (minus start address)
prg_data:
            .fill data.getSize(), data.get(i)   // and PRG data

