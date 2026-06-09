//////////////////////////////////////////////////////////////////////////////////////
// UNICORN KITTENS — config.asm
// Constants, sprite-pointer ids, item lookup tables, decimal-power table, and the
// PETSCII / screencode string data.  Read-only.
//
// THE GAME: fly a unicorn around the left 256 pixels of the screen catching cakes,
// candy and other goodies falling from the sky (carry up to 5), then fly them down to
// the TREATS FOR GOOD PEOPLE CENTER to deliver and score.  Rescue falling kittens for
// a rehome bonus, and dodge the BAD stuff (tools, poo, email notifications) or take
// damage.  Deliver enough to advance the level.  Crazy gimmick: hold-and-press FIRE to
// RAINBOW BARF — vaporise every bad thing on screen, fuelled by one goodie from your
// load.  The right-hand columns (the sprite-MSB zone) are the char HUD.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// PutStr — draw a 0-terminated SCREEN-CODE string at (row,col) in a colour (calls the
// put_str routine in util.asm).  Defined here so every module can use it.
//////////////////////////////////////////////////////////////////////////////////////
.macro PutStr(s, row, col, color) {
    lda #<s
    sta zp_ptr_2_lo
    lda #>s
    sta zp_ptr_2_hi
    lda #color
    sta var_tmp_c
    ldx #col
    lda #row
    jsr put_str
}

//////////////////////////////////////////////////////////////////////////////////////
// Sprite pointers (sprite art at $3000, pointer = addr/64 = $C0 + n)
.const sp_uni_down  = $C0       // +0/+1 = wing-flap frames; up/left/right follow
.const sp_uni_up    = $C2
.const sp_uni_left  = $C4
.const sp_uni_right = $C6
.const sp_cake      = $C8
.const sp_candy     = $C9
.const sp_kitten    = $CA
.const sp_tool      = $CB
.const sp_poo       = $CC
.const sp_email     = $CD
.const sp_center    = $CE
.const sp_sparkle   = $CF

.const ANIM_FRAMES  = 2         // wing-flap frames per direction
.const ANIM_RATE    = 6         // game frames per flap step

// Facing (index into uni_dir_ptr)
.const FACE_DOWN  = 0
.const FACE_UP    = 1
.const FACE_LEFT  = 2
.const FACE_RIGHT = 3

.const UNI_COLOR  = WHITE

//////////////////////////////////////////////////////////////////////////////////////
// Player geometry — kept inside the first 256 px so the sprite MSB is always 0
.const UNI_SPEED  = 2
.const UNI_X_MIN  = 24
.const UNI_X_MAX  = 224
.const UNI_Y_MIN  = 52
.const UNI_Y_MAX  = 216

//////////////////////////////////////////////////////////////////////////////////////
// Falling items — slots 0..NUM_ITEMS-1 use hardware sprites 1..NUM_ITEMS
.const NUM_ITEMS   = 6
.const ITEM_TOP    = 50         // spawn Y (just under the top border)
.const ITEM_BOTTOM = 234        // past this Y the item is missed

// Item types (index into item_sprite / item_color / item_cat)
.const IT_CAKE   = 0
.const IT_CANDY  = 1
.const IT_KITTEN = 2
.const IT_TOOL   = 3
.const IT_POO    = 4
.const IT_EMAIL  = 5
.const IT_COUNT  = 6

// Item categories
.const CAT_GOOD   = 0
.const CAT_KITTEN = 1
.const CAT_BAD    = 2

//////////////////////////////////////////////////////////////////////////////////////
// The Treats For Good People Center (hardware sprite 7, fixed near the bottom)
.const CENTER_X = 96
.const CENTER_Y = 210

//////////////////////////////////////////////////////////////////////////////////////
// Catch / delivery bounding box (sprites are 24x21; overlap when centres are close)
.const CATCH_DX = 20
.const CATCH_DY = 18

//////////////////////////////////////////////////////////////////////////////////////
// Gameplay tuning
.const MAX_LOAD       = 5
.const START_HP       = 5
.const MAX_HP         = 5
.const PTS_PER_GOODIE = 10      // score per delivered goodie
.const KITTEN_BONUS   = 25      // score per rescued kitten
.const BARF_PTS       = 5       // score per bad thing vaporised by a barf
.const KITTEN_WEIGHT  = 2       // kitten chance band (out of 16) above the bad band

.const GOAL_BASE  = 10          // deliveries to clear level 1
.const GOAL_STEP  = 5           // extra deliveries per level
.const SPAWN_BASE = 46          // frames between spawns at level 1
.const SPAWN_MIN  = 14
.const FALL_MIN   = 1

// Border-flash durations (frames) for feedback events
.const FLASH_HIT     = 10
.const FLASH_DELIVER = 18
.const FLASH_BARF    = 40

//////////////////////////////////////////////////////////////////////////////////////
// Game states
.const GS_TITLE = 0
.const GS_PLAY  = 1
.const GS_OVER  = 2

//////////////////////////////////////////////////////////////////////////////////////
// Screen codes used by the HUD
.const SC_SPACE = $20
.const SC_SLASH = $2F
.const SC_BAR   = $5D           // vertical bar
.const SC_HEART = $53

// HUD lives on the right (the sprite-MSB columns 30..39)
.const HUD_DIV  = 30
.const HUD_COL  = 31

//////////////////////////////////////////////////////////////////////////////////////
// STATIC LOOKUP TABLES
//////////////////////////////////////////////////////////////////////////////////////
// Facing -> base sprite pointer (add the flap frame 0/1)
uni_dir_ptr:
    .byte sp_uni_down, sp_uni_up, sp_uni_left, sp_uni_right

// Item type -> sprite pointer / colour / category
item_sprite:
    .byte sp_cake, sp_candy, sp_kitten, sp_tool, sp_poo, sp_email
item_color:
    .byte ORANGE, LIGHT_RED, YELLOW, GREY, BROWN, CYAN
item_cat:
    .byte CAT_GOOD, CAT_GOOD, CAT_KITTEN, CAT_BAD, CAT_BAD, CAT_BAD
// Item type -> base falling speed (px/frame).  Each item falls at its own speed; the
// per-level bonus (var_fall_base - FALL_MIN) and a 0/1 jitter are added at spawn.
//        cake candy kitten tool poo email
item_fall:
    .byte   1,   1,    1,     1,   1,   1

// Slot index -> SPRITE_ENABLE bit (item slot i drives hardware sprite i+1)
item_bit:
    .byte %00000010, %00000100, %00001000, %00010000, %00100000, %01000000

// Powers of ten for 16-bit -> 5-digit decimal (print_score5)
dec_pow_lo:
    .byte $10, $E8, $64, $0A, $01      // 10000,1000,100,10,1
dec_pow_hi:
    .byte $27, $03, $00, $00, $00

//////////////////////////////////////////////////////////////////////////////////////
// HUD label strings — SCREEN CODES (drawn straight into screen RAM by put_str)
//////////////////////////////////////////////////////////////////////////////////////
.encoding "screencode_mixed"
h_score: .text "score"; .byte 0
h_load:  .text "load"; .byte 0
h_life:  .text "life"; .byte 0
h_level: .text "level"; .byte 0
h_kitty: .text "kitty"; .byte 0
h_goal:  .text "goal"; .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Screen strings — PETSCII (printed via PrintXY / KERNAL CHROUT)
//////////////////////////////////////////////////////////////////////////////////////
.encoding "petscii_mixed"
t_title:  .text "u n i c o r n   k i t t e n s"; .byte 0
t_sub:    .text "sweet deliveries of justice!"; .byte 0
t_l1:     .text "fly your unicorn. catch the falling"; .byte 0
t_l2:     .text "cakes, candy and good stuff (hold 5)."; .byte 0
t_l3:     .text "fly them to the good people center"; .byte 0
t_l4:     .text "to deliver. rescue kittens enroute!"; .byte 0
t_l5:     .text "dodge tools, poo and email or get hurt."; .byte 0
t_gim:    .text "*gimmick* fire = rainbow barf:"; .byte 0
t_gim2:   .text "spew rainbows, nuke all bad stuff!"; .byte 0
t_start:  .text "push fire on joy 2 to fly"; .byte 0
t_cred:   .text "cityxen 2026"; .byte 0

t_clr1:   .text "level clear!"; .byte 0
t_clr2:   .text "kittens rehomed so far:"; .byte 0
t_clr3:   .text "the kitties say thank you!"; .byte 0
t_clr4:   .text "push fire for the next level"; .byte 0

t_over1:  .text "g a m e   o v e r"; .byte 0
t_over2:  .text "the unicorn needs a nap."; .byte 0
t_over3:  .text "final score:"; .byte 0
t_over4:  .text "kittens rehomed:"; .byte 0
t_over5:  .text "push fire to fly again"; .byte 0
