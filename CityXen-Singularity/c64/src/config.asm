//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — config.asm
// Constants, sprite pointers, RAM-buffer addresses for procedurally-generated level
// data, static lookup tables, and string data.  Read-only.
//
// The world is now INFINITE: each "sector" (level) is procedurally generated into
// RAM buffers (levelgen.asm), scaling in size + difficulty with depth.  Every sector
// is a small chain of locations, each with a CityXen room and a Nexytic mirror
// reached with the Reality Inverter.  Disable the Singularity nodes (anchors), then
// take the gate down to the next, harder sector.  Every BOSS_INTERVAL sectors, Miss
// DOS herself guards the gate.
//////////////////////////////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////////////////////////////
// Timer slots
.const TIMER_CLONE = 0
.const TIMER_MISC  = 1

//////////////////////////////////////////////////////////////////////////////////////
// Sprite pointers (sprites at $3000) + VIC slots.  Player = 0, clones = 1..4.
// 4-direction walk animation: each entity = 1 idle sprite + 4 dirs x ANIM_FRAMES.
// Walk pointer = <base> + animdir*ANIM_FRAMES + frame, animdir order = down,up,left,right.
//   Clicky: idle $C0 ($3000), walk $C1..$C8 ($3040..$3200)
//   Clone : idle $C9 ($3240), walk $CA..$D1 ($3280..$3440)
// (You will draw the real frames later; sprites.asm currently duplicates placeholders.)
.const sp_clicky_idle = $C0
.const sp_clicky_walk = $C1
.const sp_clone_idle  = $C9
.const sp_clone_walk  = $CA

.const ANIM_FRAMES = 2   // walk frames per direction
.const ANIM_RATE   = 8   // game frames per animation step

.const SLOT_PLAYER = 0
.const CLONE_MAX   = 4   // simultaneous clones (VIC sprite slots 1..4)

//////////////////////////////////////////////////////////////////////////////////////
// Game states
.const GS_TITLE = 0
.const GS_PLAY  = 1
.const GS_OVER  = 2

//////////////////////////////////////////////////////////////////////////////////////
// Player movement / geometry (single 24x21 sprite)
.const PLAYER_SPEED    = 2
.const PLAYER_X_MIN    = 32
.const PLAYER_X_MAX_LO = 56     // 312 - 256
.const PLAYER_X_MAX_MSB= 1
.const PLAYER_Y_MIN    = 58
.const PLAYER_Y_MAX    = 196

.const ENTER_N_Y = 64
.const ENTER_S_Y = 188
.const ENTER_W_X = 44
.const ENTER_E_X = 40

.const FACE_DOWN  = 0
.const FACE_UP    = 1
.const FACE_LEFT  = 2
.const FACE_RIGHT = 3

//////////////////////////////////////////////////////////////////////////////////////
// Room records (8 bytes): bg_char, bg_color, wall_color, name_msg, exit_n/s/e/w
.const ROOM_REC = 8
.const NO_EXIT  = $FF
.const MAX_LOC  = 6              // max locations per sector
.const MAX_ROOM = MAX_LOC * 2    // CityXen + Nexytic room per location (12)

//////////////////////////////////////////////////////////////////////////////////////
// Object records (8 bytes): room, col, row, kind, color, flags, result, arg
.const OBJ_REC = 8
.const OBJ_MAX = 64

// Each object draws as a 3x3 character tile (see tile_char table)
.const TILE_W   = 3
.const TILE_H   = 3
.const TILE_REC = TILE_W * TILE_H    // bytes per kind in tile_char

.const OBJ_SOLID  = %00000001
.const OBJ_SEARCH = %00000010

// Result types
.const RES_NONE   = 0
.const RES_LORE   = 1            // arg = message id (random lore)
.const RES_ENERGY = 2
.const RES_IMAG   = 3
.const RES_ITEM   = 4            // gadget: +energy +imagination
.const RES_WELL   = 5
.const RES_ANCHOR = 6            // arg = required barrier flag bit
.const RES_EXIT   = 7            // sector gate (advances when nodes cleared)
.const RES_BOSS   = 8            // Miss DOS (boss sectors)
.const RES_KEY    = 9            // Inverter Key — grants the Reality Inverter
.const RES_RIFT   = 10           // Reality Rift — flip CityXen <-> Nexytic (reusable)

//////////////////////////////////////////////////////////////////////////////////////
// Object KINDS used by the generator → static char/color/result tables
.const K_WELL   = 0
.const K_CRATE  = 1
.const K_ETHER  = 2
.const K_GADGET = 3
.const K_TERM   = 4
.const K_ANCHOR = 5
.const K_EXIT   = 6
.const K_BOSS   = 7
.const K_KEY    = 8              // Inverter Key (one per sector, in a CityXen room)
.const K_RIFT   = 9             // Reality Rift (inversion point, mirrored both worlds)

//////////////////////////////////////////////////////////////////////////////////////
// Barrier records (8 bytes): room, col, row, char, color, crew, flag, msg(hint)
.const BAR_REC = 8
.const BAR_MAX = 8

.const CREW_HELMET = 1
.const CREW_EAGULL = 2
.const CREW_ROBO   = 3
.const SUMMON_COST = 8

//////////////////////////////////////////////////////////////////////////////////////
// Clone spawn records (3 bytes): room, col, row
.const CLONE_REC     = 3
.const CLONE_REC_MAX = 16

// Clone patrol (smooth, 1px/frame around a rectangle; all bounds < 256)
.const ENT_X_MIN = 48
.const ENT_X_MAX = 248
.const ENT_Y_MIN = 72
.const ENT_Y_MAX = 176
.const NEAR_X    = 28
.const NEAR_Y    = 28
.const CDIR_RIGHT = 0
.const CDIR_DOWN  = 1
.const CDIR_LEFT  = 2
.const CDIR_UP    = 3
.const CLONE_DRAIN_DELAY = 16
.const CLONE_DRAIN       = 3

//////////////////////////////////////////////////////////////////////////////////////
// Progress flags (var_flags) — barrier-cleared bits.  Anchor i requires bit (1<<i).
.const FLAG_ANCH_BASE = 1        // barrier i sets bit (FLAG_ANCH_BASE << i)

// Worlds (var_world)
.const WORLD_CITYXEN = 0
.const WORLD_NEXYTIC = 1

//////////////////////////////////////////////////////////////////////////////////////
// Item bits
.const ITEM_INVERTER = %00000010

//////////////////////////////////////////////////////////////////////////////////////
// Resource tuning
.const RE_START   = 350
.const RE_PICKUP  = 70
.const RE_GADGET  = 40
.const RE_WELL    = 250          // a well refill adds 2x this (+500), never reduces
.const CI_PICKUP  = 6
.const CI_GADGET  = 4

// Retronic Energy is also spent by acting:
.const COST_SEARCH    = 10       // per object searched
.const COST_INVERT    = 50       // Retronic Energy per reality flip (at a rift)
.const COST_SUMMON_RE = 100      // per summon (on top of the imagination cost)

.const SEARCH_COL = 2
.const SEARCH_ROW = 2

.const MSG_SHORT = 120
.const MSG_LONG  = 230

//////////////////////////////////////////////////////////////////////////////////////
// Difficulty scaling
.const BOSS_INTERVAL = 5         // every Nth sector is a Miss DOS boss
.const MAX_ANCHORS   = 5
.const CROSS_LEVEL   = 3         // sectors >= this can place cross-reality puzzles

//////////////////////////////////////////////////////////////////////////////////////
// Screen codes
.const SC_SPACE = $20
.const SC_WALL  = $A0

//////////////////////////////////////////////////////////////////////////////////////
// Collision map at $C000 (rows parallel screen: block_hi = screen_hi + $BC)
.const BLOCK_MAP       = $C000
.const BLOCK_OFFSET_HI = $BC

//////////////////////////////////////////////////////////////////////////////////////
// Generated-level RAM buffers (free RAM above the BLOCK_MAP, NOT in the PRG)
.const obj_table     = $C400     // OBJ_MAX*8 = 512  -> $C400-$C5FF
.const obj_state     = $C600     // OBJ_MAX        -> $C600-$C63F
.const room_table    = $C640     // MAX_ROOM*8 = 96 -> $C640-$C69F
.const room_mirror   = $C6A0     // MAX_ROOM       -> $C6A0-$C6AB
.const barrier_table = $C6C0     // BAR_MAX*8 = 64  -> $C6C0-$C6FF
.const clone_table   = $C700     // CLONE_REC_MAX*3 -> $C700-$C72F

//////////////////////////////////////////////////////////////////////////////////////
// Message ids
.const MSG_BLANK       = 0
.const MSG_WELL        = 1
.const MSG_CRATE       = 2
.const MSG_ETHER       = 3
.const MSG_GADGET      = 4
.const MSG_NOTHING     = 5
.const MSG_FULL        = 6
.const MSG_ANCHOR      = 7
.const MSG_ANCHOR_BLK  = 8
.const MSG_EXIT_SEALED = 9
.const MSG_EXIT_OPEN   = 10
.const MSG_OBJECTIVE   = 11
.const MSG_CLONE_ZAP   = 12
.const MSG_DORMANT     = 13
.const MSG_SUM_HELMET  = 14
.const MSG_SUM_EAGULL  = 15
.const MSG_SUM_ROBO    = 16
.const MSG_SUM_NONE    = 17
.const MSG_SUM_POOR    = 18
.const MSG_BAR_SW      = 19
.const MSG_BAR_HW      = 20
.const MSG_BAR_LANG    = 21
.const MSG_INV_DONE    = 22
.const MSG_INV_NOMIR   = 23
.const MSG_BOSS_NO     = 24
.const MSG_BOSS_WIN    = 25
.const MSG_SECTOR      = 26
.const MSG_LORE0       = 27
.const MSG_LORE1       = 28
.const MSG_LORE2       = 29
.const MSG_LORE3       = 30
// hover hints (shown at the bottom while standing on a usable object)
.const MSG_HINT_WELL   = 31
.const MSG_HINT_CRATE  = 32
.const MSG_HINT_ETHER  = 33
.const MSG_HINT_GADGET = 34
.const MSG_HINT_TERM   = 35
.const MSG_HINT_ANCHOR = 36
.const MSG_HINT_EXIT   = 37
.const MSG_HINT_BOSS   = 38
.const MSG_KEY         = 39      // picked up the Inverter Key
.const MSG_INV_NEEDKEY = 40      // a rift, but no key yet
.const MSG_HINT_KEY    = 41
.const MSG_HINT_RIFT   = 42
.const MSG_COUNT       = 43

.const NLORE = 4                 // MSG_LORE0..MSG_LORE3

//////////////////////////////////////////////////////////////////////////////////////
// STATIC LOOKUP TABLES (read-only, in the PRG)
//////////////////////////////////////////////////////////////////////////////////////
// Object kind → colour / result   (indexed by K_*)
kind_color:
    .byte CYAN, ORANGE, PURPLE, YELLOW, LIGHT_BLUE, RED, GREEN, LIGHT_RED, YELLOW, WHITE
kind_result:
    .byte RES_WELL, RES_ENERGY, RES_IMAG, RES_ITEM, RES_LORE, RES_ANCHOR, RES_EXIT, RES_BOSS, RES_KEY, RES_RIFT

//////////////////////////////////////////////////////////////////////////////////////
// Object 3x3 TILE ART (indexed by K_*).  9 SCREEN CODES per kind, row by row:
//   top-left   top-mid   top-right
//   mid-left   centre    mid-right
//   bot-left   bot-mid   bot-right
// The whole tile draws in the object's colour (kind_color).  $20 = space (lets the
// floor show through and is never made solid).  EDIT THESE to redraw any object.
// Handy screen codes:  $20 space  $A0 solid block  $51 ball
//   box: $70 corner-TL  $6E corner-TR  $6D corner-BL  $7D corner-BR
//        $40 horizontal  $5D vertical
//////////////////////////////////////////////////////////////////////////////////////
tile_char:
    // K_WELL — retronic well (water in a stone rim)
    .byte $70, $40, $6E
    .byte $5D, $51, $5D
    .byte $6D, $40, $7D
    // K_CRATE — energy crate
    .byte $70, $40, $6E
    .byte $5D, $A0, $5D
    .byte $6D, $40, $7D
    // K_ETHER — ether meme core (glowing cross)
    .byte $20, $51, $20
    .byte $51, $A0, $51
    .byte $20, $51, $20
    // K_GADGET — hackme gadget (device with antenna)
    .byte $20, $5D, $20
    .byte $70, $A0, $6E
    .byte $6D, $40, $7D
    // K_TERM — terminal (screen on a stand)
    .byte $70, $40, $6E
    .byte $5D, $A0, $5D
    .byte $20, $5D, $20
    // K_ANCHOR — singularity node (radiating core)
    .byte $5D, $51, $5D
    .byte $40, $A0, $40
    .byte $5D, $51, $5D
    // K_EXIT — sector gate (open doorway)
    .byte $70, $40, $6E
    .byte $5D, $20, $5D
    .byte $5D, $20, $5D
    // K_BOSS — miss dos (imposing block)
    .byte $A0, $A0, $A0
    .byte $A0, $A0, $A0
    .byte $A0, $A0, $A0
    // K_KEY — inverter key (bow on the left, blade + teeth to the right)
    .byte $20, $20, $20
    .byte $51, $40, $40
    .byte $20, $20, $5D
    // K_RIFT — reality rift (swirling portal)
    .byte $70, $40, $6E
    .byte $5D, $66, $5D
    .byte $6D, $40, $7D

// Result → default display message (indexed by RES_*; LORE/ANCHOR/EXIT/BOSS special)
res_msg:
    .byte MSG_NOTHING, MSG_BLANK, MSG_CRATE, MSG_ETHER, MSG_GADGET, MSG_WELL, MSG_ANCHOR, MSG_EXIT_OPEN, MSG_BOSS_NO

// Crew → barrier hint message / barrier colour (indexed by CREW_* - 1)
crew_hint_msg:
    .byte MSG_BAR_SW, MSG_BAR_HW, MSG_BAR_LANG
crew_bar_color:
    .byte GREEN, BROWN, PURPLE
// Crew → summon success message
crew_ok_msg:
    .byte MSG_SUM_HELMET, MSG_SUM_EAGULL, MSG_SUM_ROBO

// Lore message pool (indexed 0..NLORE-1)
lore_msg:
    .byte MSG_LORE0, MSG_LORE1, MSG_LORE2, MSG_LORE3

// Result type → hover-hint message (indexed by RES_*; NONE = no hint)
hint_msg:
    .byte MSG_BLANK, MSG_HINT_TERM, MSG_HINT_CRATE, MSG_HINT_ETHER, MSG_HINT_GADGET
    .byte MSG_HINT_WELL, MSG_HINT_ANCHOR, MSG_HINT_EXIT, MSG_HINT_BOSS
    .byte MSG_HINT_KEY, MSG_HINT_RIFT

// Clone patrol direction (CDIR_*) → animation direction (down,up,left,right order)
cdir_to_anim:
    .byte 3, 0, 2, 1            // RIGHT→right, DOWN→down, LEFT→left, UP→up

// Sprite bit masks (indexed by sprite number 0..7)
sprite_bit:
    .byte %00000001, %00000010, %00000100, %00001000, %00010000, %00100000, %01000000, %10000000
sprite_msb_clear:
    .byte %11111110, %11111101, %11111011, %11110111, %11101111, %11011111, %10111111, %01111111

//////////////////////////////////////////////////////////////////////////////////////
// STRING DATA — status-bar strings are SCREEN CODES.  Keep each <= 40 chars.
//////////////////////////////////////////////////////////////////////////////////////
.encoding "screencode_mixed"
m_blank:       .text "                                        "; .byte 0
m_well:        .text "retronic well: energy restored."; .byte 0
m_crate:       .text "crate cracked - retronic energy!"; .byte 0
m_ether:       .text "ether meme core - imagination rises!"; .byte 0
m_gadget:      .text "a hackme gadget! energy + imagination."; .byte 0
m_nothing:     .text "nothing here. clicky shrugs."; .byte 0
m_full:        .text "energy already maxed."; .byte 0
m_anchor:      .text "singularity node offline!"; .byte 0
m_anchor_blk:  .text "a barrier shields this node."; .byte 0
m_exit_sealed: .text "the gate is sealed - clear the nodes."; .byte 0
m_exit_open:   .text "the gate opens! descend deeper..."; .byte 0
m_objective:   .text "power down the nodes, then find the gate"; .byte 0
m_clone_zap:   .text "a clone! cylon static drains you."; .byte 0
m_dormant:     .text "energy gone. dormancy claims clicky..."; .byte 0
m_sum_helmet:  .text "helmet guy decodes the lock!"; .byte 0
m_sum_eagull:  .text "eagull revives the dead gate!"; .byte 0
m_sum_robo:    .text "roboguy 5000 reads the sigil!"; .byte 0
m_sum_none:    .text "no crew-barrier in reach to channel."; .byte 0
m_sum_poor:    .text "not enough imagination to summon."; .byte 0
m_bar_sw:      .text "locked code - summon helmet guy (1)"; .byte 0
m_bar_hw:      .text "dead iron gate - summon eagull (2)"; .byte 0
m_bar_lang:    .text "a lost sigil - summon roboguy (3)"; .byte 0
m_inv_done:    .text "reality inverts! mind the mirror."; .byte 0
m_inv_nomir:   .text "reality refuses to bend here."; .byte 0
m_boss_no:     .text "miss dos: my nodes still hold, fool!"; .byte 0
m_boss_win:    .text "miss dos falls! the sector clears."; .byte 0
m_sector:      .text "a deeper sector. it is hungrier."; .byte 0
m_lore0:       .text "term: cia file - arman of arm watches"; .byte 0
m_lore1:       .text "term: the lo8bc fled zeta centauri iii"; .byte 0
m_lore2:       .text "term: meatloaf inside. do not eat it."; .byte 0
m_lore3:       .text "term: nexytic is the mirror. balance."; .byte 0
m_hint_well:   .text "retronic energy"; .byte 0
m_hint_crate:  .text "energy crate"; .byte 0
m_hint_ether:  .text "ether meme core"; .byte 0
m_hint_gadget: .text "hackme gadget"; .byte 0
m_hint_term:   .text "terminal"; .byte 0
m_hint_anchor: .text "singularity node"; .byte 0
m_hint_exit:   .text "sector gate"; .byte 0
m_hint_boss:   .text "miss dos!"; .byte 0
m_key:         .text "the inverter key! rifts now obey you."; .byte 0
m_inv_needkey: .text "a rift hums - find the inverter key."; .byte 0
m_hint_key:    .text "inverter key"; .byte 0
m_hint_rift:   .text "reality rift"; .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Title / end-screen strings — PETSCII
.encoding "petscii_mixed"
m_title:  .text "cityxen: dual singularity"; .byte 0
m_sub:    .text "- endless sector descent -"; .byte 0
m_l1:     .text "    deactivate the anchors"; .byte 0
m_l2:     .text "miss dos's network has no bottom."; .byte 0
m_l3:     .text "    search both realities"; .byte 0
m_l4:     .text "     for great justice!"; .byte 0
m_ctrl:   .text "fire=search  1/2/3=summon crew"; .byte 0
m_start:  .text "press fire to jack in"; .byte 0
m_cred:   .text "cityxen.itch.io 2026"; .byte 0

m_over_t: .text "dormancy..."; .byte 0
m_over1:  .text "retronic energy ran dry."; .byte 0
m_over2:  .text "deepest sector reached:"; .byte 0
m_press:  .text "press fire to reboot"; .byte 0

//////////////////////////////////////////////////////////////////////////////////////
// Message pointer table (lo/hi), indexed by MSG_*
msg_ptr_lo:
    .byte <m_blank, <m_well, <m_crate, <m_ether, <m_gadget, <m_nothing, <m_full
    .byte <m_anchor, <m_anchor_blk, <m_exit_sealed, <m_exit_open, <m_objective
    .byte <m_clone_zap, <m_dormant, <m_sum_helmet, <m_sum_eagull, <m_sum_robo
    .byte <m_sum_none, <m_sum_poor, <m_bar_sw, <m_bar_hw, <m_bar_lang, <m_inv_done
    .byte <m_inv_nomir, <m_boss_no, <m_boss_win, <m_sector, <m_lore0, <m_lore1
    .byte <m_lore2, <m_lore3, <m_hint_well, <m_hint_crate, <m_hint_ether
    .byte <m_hint_gadget, <m_hint_term, <m_hint_anchor, <m_hint_exit, <m_hint_boss
    .byte <m_key, <m_inv_needkey, <m_hint_key, <m_hint_rift
msg_ptr_hi:
    .byte >m_blank, >m_well, >m_crate, >m_ether, >m_gadget, >m_nothing, >m_full
    .byte >m_anchor, >m_anchor_blk, >m_exit_sealed, >m_exit_open, >m_objective
    .byte >m_clone_zap, >m_dormant, >m_sum_helmet, >m_sum_eagull, >m_sum_robo
    .byte >m_sum_none, >m_sum_poor, >m_bar_sw, >m_bar_hw, >m_bar_lang, >m_inv_done
    .byte >m_inv_nomir, >m_boss_no, >m_boss_win, >m_sector, >m_lore0, >m_lore1
    .byte >m_lore2, >m_lore3, >m_hint_well, >m_hint_crate, >m_hint_ether
    .byte >m_hint_gadget, >m_hint_term, >m_hint_anchor, >m_hint_exit, >m_hint_boss
    .byte >m_key, >m_inv_needkey, >m_hint_key, >m_hint_rift
