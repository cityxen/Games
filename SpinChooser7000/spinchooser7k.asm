//////////////////////////////////////////////////////////////////////////////////////
// SPIN CHOOSER 7K for C64
//////////////////////////////////////////////////////////////////////////////////////
#import "../Commodore64_Programming/include/Constants.asm"
#import "../Commodore64_Programming/include/Macros.asm"
#import "../Commodore64_Programming/include/DrawPetMateScreen.asm"

// Local Constants

.const FLASH_TIMER_SPEED_CONST = $40

.const BUTTON_RED    = $FB
.const BUTTON_GREEN  = $FE
.const BUTTON_YELLOW = $FD
.const BUTTON_BLUE   = $F7
.const BUTTON_WHITE  = $EF

.const BUTTON_LIGHT_RED    = %11110111
.const BUTTON_LIGHT_GREEN  = %11111110
.const BUTTON_LIGHT_YELLOW = %11111101
.const BUTTON_LIGHT_BLUE   = %11111011
.const BUTTON_LIGHT_WHITE  = %11011111
.const BUTTON_LIGHT_ALL    = %00000000
.const BUTTON_LIGHT_NONE   = %11111111

.const TECH = 01
.const WHEEL_SLICE_TECH1   = 125 // 3
.const WHEEL_SLICE_TECH2   = 119 // 6
.const WHEEL_SLICE_TECH3   = 124 // 11 
.const WHEEL_SLICE_TECH4   = 118 // 14

.const MUSIC = 02
.const WHEEL_SLICE_MUSIC1  = 121 // 1
.const WHEEL_SLICE_MUSIC2  = 115 // 4
.const WHEEL_SLICE_MUSIC3  = 120 // 9
.const WHEEL_SLICE_MUSIC4  = 114 // 12

.const MOVIES = 03
.const WHEEL_SLICE_MOVIE1  = 117 // 2
.const WHEEL_SLICE_MOVIE2  = 116 // 10

.const GAMES = 04
.const WHEEL_SLICE_GAMES1  = 123 // 5
.const WHEEL_SLICE_GAMES2  = 112 // 8
.const WHEEL_SLICE_GAMES3  = 122 // 13
.const WHEEL_SLICE_GAMES4  = 113 // 16

.const CITYXEN = 05
.const WHEEL_SLICE_CXN     = 127 // 7
.const WHEEL_SLICE_RESPIN  = 126 // 15

.segment Sprites [allowOverlap]
*=$2000 "POINTER"
// #import "pointer.asm"
.segment Screens [allowOverlap]
*=$3000 "SCREENS"
#import "petmate/screens.asm"
//////////////////////////////////////////////////////////////////////////////////////
// File stuff
.file [name="sc7k.prg", segments="Main,Sprites,Screens"]
.disk [filename="sc7k.d64", name="CITYXEN SC7K", id="2023!" ] {
	[name="SC7K", type="prg",  segments="Main,Sprites,Screens"],
    [name="--------------------",type="del"],
}
//////////////////////////////////////////////////////////////////////////////////////
.segment Main [allowOverlap]
* = $0801 "BASIC"
.word usend // link address
.word 2023  // line num
.byte $9e   // sys
.text toIntString(init)
.byte $3a,99,67,73,84,89,88,69,78,99
usend:
.byte 0
.word 0  // empty link signals the end of the program
* = $0830 "vars init"


//////////////////////////////////////////////////////////////////
// Initialization
init:

// Set up sid to produce random values
lda #$FF  // maximum frequency value
sta $D40E // voice 3 frequency low byte
sta $D40F // voice 3 frequency high byte
lda #$80  // noise waveform, gate bit off
sta $D412 // voice 3 control register

// reset user port values to output and zero
lda #$ff
sta USER_PORT_DATA_DIR
lda #BUTTON_LIGHT_NONE
sta flash_value
lda #FLASH_TIMER_SPEED_CONST
sta flash_timer_speed
lda #BUTTON_LIGHT_NONE
sta USER_PORT_DATA
jsr draw_main_screen
// TODO: set up sound

//////////////////////////////////////////////////////////////////
// Main loop
main:

///////////////////////////////////
// enter button selection mode by hitting F1
jsr KERNAL_GETIN
cmp #KEY_F1
bne !ml+
jsr select_buttons
jsr draw_main_screen
jmp main

!ml:

///////////////////////////////////
// determine if wheel is spinning or not
lda pointer_current
cmp #pointer_old
beq main // wheel not spinning

///////////////////////////////////
// If FIRE (J2) then play sound
lda JOYSTICK_PORT_2
and #%00010000
bne !ml+
jsr play_peghit
jmp main

!ml:
lda JOYSTICK_PORT_2 // read joystick port 2
sta pointer_current

cmp #WHEEL_SLICE_CXN
bne !ml+
PokeString($0642,wheel_text_cxn)
lda #CITYXEN
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_MOVIE1
bne !ml+
PokeString($0642,wheel_text_movies)
lda #MOVIES
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_MOVIE2
bne !ml+
PokeString($0642,wheel_text_movies)
lda #MOVIES
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_MUSIC1
bne !ml+
PokeString($0642,wheel_text_music)
lda #MUSIC
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_MUSIC2
bne !ml+
PokeString($0642,wheel_text_music)
lda #MUSIC
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_MUSIC3
bne !ml+
PokeString($0642,wheel_text_music)
lda #MUSIC
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_MUSIC4
bne !ml+
PokeString($0642,wheel_text_music)
lda #MUSIC
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_GAMES1
bne !ml+
PokeString($0642,wheel_text_games)
lda #GAMES
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_GAMES2
bne !ml+
PokeString($0642,wheel_text_games)
lda #GAMES
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_GAMES3
bne !ml+
PokeString($0642,wheel_text_games)
lda #GAMES
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_GAMES4
bne !ml+
PokeString($0642,wheel_text_games)
lda #GAMES
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_TECH1
bne !ml+
PokeString($0642,wheel_text_tech)
lda #TECH
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_TECH2
bne !ml+
PokeString($0642,wheel_text_tech)
lda #TECH
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_TECH3
bne !ml+
PokeString($0642,wheel_text_tech)
lda #TECH
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_TECH4
bne !ml+
PokeString($0642,wheel_text_tech)
lda #TECH
sta category
jmp main_loop_exit

!ml:
cmp #WHEEL_SLICE_RESPIN
bne !ml+
PokeString($0642,wheel_text_respin)
jmp main_loop_exit

!ml:
jsr draw_main_screen

main_loop_exit:
lda pointer_current
cmp pointer_old
bne !ml+

// do timer check here to see if it is spinning or not

!ml:
lda pointer_current
sta pointer_old

// increment flash timer for buttons
inc flash_timer
bne !sbl+
inc flash_timer2
lda flash_timer2
cmp flash_timer_speed
bne !sbl+
// check flash timer for flash increment
lda #$00
sta flash_timer
sta flash_timer2
inc flash_value_count
lda flash_value_count
and #$01
tax
bne !ml+
lda #BUTTON_LIGHT_WHITE
sta USER_PORT_DATA
jmp !ml++
!ml:
lda #BUTTON_LIGHT_NONE
sta USER_PORT_DATA
!ml:
!sbl:


lda JOYSTICK_PORT_1
cmp #BUTTON_WHITE
bne !chk_buttons+
jsr select_buttons
jsr give_question_code
jmp init

!chk_buttons:



jmp main

//////////////////////////////////////////////////////////////////
// FLASH THE BUTTONS, CHECK FOR BUTTON SELECTION
select_buttons:
DrawPetMateScreen(screen_002)

jsr delay

select_buttons_loop:

// increment flash timer for buttons
inc flash_timer
bne !sbl+
inc flash_timer2
lda flash_timer2
cmp flash_timer_speed
bne !sbl+
// check flash timer for flash increment
lda #$00
sta flash_timer
sta flash_timer2
inc flash_value_count
lda flash_value_count
and #$01
tax
lda flash_value_1,x
sta USER_PORT_DATA

!sbl:
// check joystick port 1 values
lda JOYSTICK_PORT_1
cmp #$ff

beq select_buttons_loop
cmp #BUTTON_BLUE
bne !chk_buttons+
sta last_honkin
lda #$02
sta decade
lda #BUTTON_LIGHT_BLUE
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:
cmp #BUTTON_RED
bne !chk_buttons+
sta last_honkin
lda #$03
sta decade
lda #BUTTON_LIGHT_RED
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:
cmp #BUTTON_GREEN
bne !chk_buttons+
sta last_honkin
lda #$00
sta decade
lda #BUTTON_LIGHT_GREEN
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:
cmp #BUTTON_YELLOW
bne !chk_buttons+
sta last_honkin
lda #$01
sta decade
lda #BUTTON_LIGHT_YELLOW
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:
cmp #BUTTON_WHITE
bne !chk_buttons+
sta last_honkin
lda #BUTTON_LIGHT_WHITE
sta USER_PORT_DATA
jmp exit_select_button

!chk_buttons:

exit_select_button:

jsr delay

rts

//////////////////////////////////////////////////////////////////
// peghit sound

play_peghit:
rts

//////////////////////////////////////////////////////////////////
// Draw main screen

draw_main_screen:
DrawPetMateScreen(screen_001)
rts
//////////////////////////////////////////////////////////////////
// Delay
delay:
lda #$00
sta flash_timer
sta flash_timer2
more_delay:
// increment flash timer for buttons
inc flash_timer
bne !sbl+
inc flash_timer2
lda flash_timer2
cmp flash_timer_speed
bne !sbl+
// check flash timer for flash increment
lda #$00
sta flash_timer
sta flash_timer2
jmp !delay_out+
!sbl:
jmp more_delay

!delay_out:
rts

//////////////////////////////////////////////////////////////////
// Give Question Code
give_question_code:
DrawPetMateScreen(screen_003)
jsr delay


lda $d41b // get random number
and #%00000111

bne !gqc+
adc #01
!gqc:

//pha
//PrintHex(1,1)
//pla

tax
dex
lda question_table,x
sta 1024+(40*19)+21
// 22 / 19



give_question_code_loop:


lda category
cmp #GAMES
bne !gqc+
ldx decade
lda page_table_games,x
sta 1024+(40*19)+20
jmp out_cat_loop
!gqc:
cmp #MUSIC
bne !gqc+
ldx decade
lda page_table_music,x
sta 1024+(40*19)+20
jmp out_cat_loop
!gqc:
cmp #MOVIES
bne !gqc+
ldx decade
lda page_table_movies,x
sta 1024+(40*19)+20
jmp out_cat_loop
!gqc:
cmp #TECH
bne !gqc+
ldx decade
lda page_table_tech,x
sta 1024+(40*19)+20
jmp out_cat_loop
!gqc:
cmp #CITYXEN
bne !gqc+
ldx decade
lda page_table_cityxen,x
sta 1024+(40*19)+20

!gqc:
out_cat_loop:

// increment flash timer for buttons
inc flash_timer
bne !sbl+
inc flash_timer2
lda flash_timer2
cmp flash_timer_speed
bne !sbl+
// check flash timer for flash increment
lda #$00
sta flash_timer
sta flash_timer2
inc flash_value_count
lda flash_value_count
and #$01
tax
bne !ml+
lda #BUTTON_LIGHT_WHITE
sta USER_PORT_DATA
jmp !ml++
!ml:
lda #BUTTON_LIGHT_NONE
sta USER_PORT_DATA
!ml:
!sbl:

lda JOYSTICK_PORT_1
cmp #BUTTON_WHITE
bne !chk_buttons+
jmp give_question_code_exit
!chk_buttons:

jmp give_question_code_loop
give_question_code_exit:
jsr delay
rts

//////////////////////////////////////////////////////////////////
// VARS

pointer_current:        .byte 0
pointer_old:            .byte 0
wheel_spinning:         .byte 0
wheel_spinning_timeout: .byte 0
up:                     .byte 0
down:                   .byte 0
left:                   .byte 0
right:                  .byte 0
button:                 .byte 0
up2:                    .byte 0
down2:                  .byte 0
left2:                  .byte 0
right2:                 .byte 0
button2:                .byte 0
flash_timer:            .byte 0
flash_timer2:           .byte 0
flash_timer3:           .byte 0
flash_timer_speed:      .byte FLASH_TIMER_SPEED_CONST
flash_value:            .byte 0
flash_value_count:      .byte 0
flash_value_1:          .byte %010101010
flash_value_2:          .byte %101010101
last_honkin:            .byte 0
category:               .byte 0
decade:                 .byte 0

page_table_games:
.text "abcd"
.byte 0
page_table_movies:
.text "efgh"
.byte 0
page_table_music:
.text "ijkl"
.byte 0
page_table_tech:
.text "mnop"
.byte 0
page_table_cityxen:
.text "qrst"
.byte 0
// UVWXYZ"
question_table:
.text "1234566"
.byte 0

wheel_text_tech:
.text " tech    "
.byte 0
wheel_text_music:
.text " music   "
.byte 0
wheel_text_movies:
.text " movies   "
.byte 0
wheel_text_games:
.text " games    "
.byte 0
wheel_text_cxn:
.text " cityxen  "
.byte 0
wheel_text_respin:
.text " respin   "
.byte 0

#import "../Commodore64_Programming/include/PrintSubRoutines.asm"