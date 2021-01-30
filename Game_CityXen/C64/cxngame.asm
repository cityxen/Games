//////////////////////////////////////////////////////////////////////////
// CityXen: The Game
// Author: Deadline
// CityXen 2020
//////////////////////////////////////////////////////////////////////////
.segment Main [allowOverlap]
//////////////////////////////////////////////////////////////////////////
// File stuff and importing files
.file [name="cxngame.prg", segments="Main"]
.disk [filename="cxngame.d64", name="CITYXEN GAME", id="2020!" ] {
	[name="CXNGAME", type="prg",  segments="Main"],
}

.var var_space          = $0845 // - $0970
.var var_space_sprites  = $0a00 // - $0b29
.var irq_prgs           = $0c00 // - $0c9a

// Available $0d00-$0fff
.var tile_definitions   = $0d00 // sets up 2x2 tile defs 

.var level_data         = $1000 // - ??? 

// Up to $27ff available
.var sprite_data        = $2800 // - $37ff
.var custom_font        = $3800 // - $3fff
.var main_game          = $4000 // - $8fff
.var music              = LoadSid("music/deadline1.sid")

*=var_space "var_space"
#import "../../Commodore64_Programming/include/Constants.asm"
#import "../../Commodore64_Programming/include/Macros.asm"
#import "../../Commodore64_Programming/include/SpriteManagement.asm"
#import "../../Commodore64_Programming/include/PrintSubRoutines.asm"
#import "../../Commodore64_Programming/include/Music.asm"

#import "cxngame_vars.asm"
#import "cxngame_tiledefs.asm"
#import "cxngame_irqs.asm"

*=sprite_data "sprite_data"
#import "sprites/sprites.asm"
*=var_space_sprites "var_space_sprites"
#import "sprites/sprite_anim_tables.asm"
#import "sprites/sprite_tables.asm"
#import "sprites/sprite_tables_char_sel.asm"

*=custom_font "custom_font"
#import "charset/chars1-charset.asm"

//////////////////////////////////////////////////////////////////////////
// Load MUSIC

*=music.location "Music"
.fill music.size, music.getData(i)
.print ""
.print "SID Data"
.print "--------"
.print "location=$"+toHexString(music.location)
.print "init=$"+toHexString(music.init)
.print "play=$"+toHexString(music.play)
.print "songs="+music.songs
.print "startSong="+music.startSong
.print "size=$"+toHexString(music.size)
.print "name="+music.name
.print "author="+music.author
.print "copyright="+music.copyright
.print ""
.print "Additional tech data"
.print "--------------------"
.print "header="+music.header
.print "header version="+music.version
.print "flags="+toBinaryString(music.flags)
.print "speed="+toBinaryString(music.speed)
.print "startpage="+music.startpage
.print "pagelength="+music.pagelength

//////////////////////////////////////////////////////////////////////////
// Basic Upstart
*=$0801 "basic_upstart"
 :BasicUpstart($0842)
*=$080a "cityxen_words"
.byte $3a,20,20,20,20,20,20,20,20,20,20,20
.byte 32,117,96,32,109,32,110
.byte 13,45,125,73,84,89,118,69,78,45,32
.text "THE GAME"
.byte 32,50,48,50,48,13,32,106,96,32,110,32,109,13,00,00,00
*=$0842 "entry"
    jmp main_game

*=main_game "main_game"
//////////////////////////////////////////////////////////////////////////
// Initialization
initialization:
    // turn off BASIC ROM area for use of RAM at $a000-$bfff (8192 bytes)
    lda ZP_IO_REGISTER
    ora #$01
    sta ZP_IO_REGISTER

    // disable RUN-STOP+RESTORE
    // lda #$fc
    // sta KERNAL_STOP_VECTOR
    
    // Other initialization
    InitializeMusic(option_music)

    // set up main menu irq to change character modes

    
    SetCharacters(custom_font)

main_menu:
    InitializeSpritesAlt(sprite_default_table)
    AssignSpriteAnim(0,sprite_anim_helmet_right)
    SetSpriteColor(0,LIGHT_GRAY)
    AssignSpriteAnim(1,sprite_anim_legs_right)
    AssignSpriteAnim(2,sprite_anim_clicky_head)
    SetSpriteColor(2,GREEN)
    AssignSpriteAnim(3,sprite_anim_clicky_bottom_left)
    SetSpriteColor(3,LIGHT_GRAY)
    AssignSpriteAnim(4,sprite_arrow_thing)      
    jsr draw_main_menu
    jsr debug_line
    MoveSprite(4,$70,$7c)
    lda #$00
    sta main_menu_cursor
    
main_menu_loop:
    jsr KERNAL_GETIN
    ReadKeyJMP('N',new_game)
    ReadKeyJMP('L',load_game)
    ReadKeyJSR('O',options)
    ReadKeyJSR(KEY_CURSOR_DOWN,main_menu_move_cursor_down)
    ReadKeyJSR(KEY_CURSOR_UP,main_menu_move_cursor_up)
    ReadKeyJMP(KEY_RETURN,main_menu_do_cursor)
    jsr update_sprites
    clc
    lda option_timer_joyport
    cmp #JOYPORT_TIMER
    bcc !mml+
    lda #$00
    sta option_timer_joyport
    ReadJoyJSR(option_joyport,"DOWN",main_menu_move_cursor_down)
    ReadJoyJSR(option_joyport,"UP",main_menu_move_cursor_up)
    ReadJoyJMP(option_joyport,"FIRE",main_menu_do_cursor)
!mml:
    jmp main_menu_loop

draw_main_menu:
    lda #%00011111
    sta sprite_visible
    lda #$1f
    sta sprites_animated
    ClearScreenColors(PURPLE,WHITE)
    ldx #$00
!dmsloop:
    lda main_menu_gfx_title_line_1,x
    beq !dmsloop+
    sta SCREEN_RAM+92,x
    lda #LIGHT_GRAY
    sta COLOR_RAM+92,x
    lda main_menu_gfx_title_line_2,x
    sta SCREEN_RAM+92+40,x
    lda #LIGHT_GRAY
    sta COLOR_RAM+92+40,x
    inx
    bne !dmsloop-
!dmsloop:
    PokeStringColor(1024+211,main_menu_text_title,BLACK)
    PokeStringColor(1024+120+295,main_menu_text_new_game,WHITE)
    PokeStringColor(1024+120+120+295,main_menu_text_load_game,WHITE)
    PokeStringColor(1024+120+120+120+295,main_menu_text_options,WHITE)
    rts

main_menu_do_cursor:
    lda main_menu_cursor
    cmp #$00
    bne !next+
    jmp new_game
!next:
    cmp #$01
    bne !next+
    jmp load_game
!next:
    cmp #$02
    bne !next+
    jsr options
!next:
    jmp main_menu

main_menu_move_cursor_up:
    dec main_menu_cursor
    lda main_menu_cursor
    cmp #$01
    bne !nextl+
    MoveSprite(4,$70,$94)
!nextl:
    cmp #$ff
    bne !nextl+
    MoveSprite(4,$70,$ac)
    lda #$02
    sta main_menu_cursor
!nextl:
    cmp #$00
    bne !nextl+
    MoveSprite(4,$70,$7c)
!nextl:
    //jsr debug_line
    rts
    
main_menu_move_cursor_down:
    inc main_menu_cursor
    lda main_menu_cursor
    cmp #$01
    bne !nextl+
    MoveSprite(4,$70,$94)
!nextl:
    cmp #$02
    bne !nextl+
    MoveSprite(4,$70,$ac)
!nextl:
    cmp #$03
    bne !nextl+
    lda #$00
    sta main_menu_cursor
    MoveSprite(4,$70,$7c)
!nextl:
    //jsr debug_line
    rts

options:
    jsr draw_options
    //jsr debug_line
    MoveSprite(4,$70,$7c)
    lda #$00
    sta main_menu_cursor
    
options_loop:

    clc
    lda option_joyport
    adc #$01
    ldx #23
    ldy #10
    jsr print_hex // PrintHexColor(23,10,WHITE)
    lda option_music
    ldx #21
    ldy #13
    jsr print_hex // PrintHexColor(21,13,WHITE)

    jsr KERNAL_GETIN
    ReadKeyJMP('B',options_xit)
    ReadKeyJSR('J',options_joyport)
    ReadKeyJSR('M',options_music)
    ReadKeyJSR(KEY_CURSOR_DOWN,options_move_cursor_down)
    ReadKeyJSR(KEY_CURSOR_UP,options_move_cursor_up)
    ReadKeyJMP(KEY_RETURN,options_do_cursor)
    
    jsr update_sprites

 clc
    lda option_timer_joyport
    cmp #JOYPORT_TIMER
    bcc !oml+
    lda #$00
    sta option_timer_joyport
    ReadJoyJSR(option_joyport,"DOWN",options_move_cursor_down)
    ReadJoyJSR(option_joyport,"UP",options_move_cursor_up)
    ReadJoyJMP(option_joyport,"FIRE",options_do_cursor)
    
!oml:    
    jmp options_loop

draw_options:
    ClearScreenColors(LIGHT_BLUE,WHITE)
    PokeStringColor(1024+172,main_menu_text_options,WHITE)
    PokeStringColor(1024+120+295,options_text_joyport,WHITE)
    PokeStringColor(1024+120+120+295,options_text_music,WHITE)
    PokeStringColor(1024+120+120+120+295,options_main_menu,WHITE)
    rts

options_do_cursor:
    lda main_menu_cursor
    cmp #$00
    bne !next+
    jsr options_joyport
    //jsr debug_line
    jmp options_loop
!next:
    cmp #$01
    bne !next+
    jsr options_music
    //jsr debug_line
    jmp options_loop
!next:
    cmp #$02
    bne !next+
    
!next:
    jmp main_menu


options_move_cursor_up:
    dec main_menu_cursor
    lda main_menu_cursor
    cmp #$01
    bne !nextl+
    MoveSprite(4,$70,$94)
!nextl:
    cmp #$ff
    bne !nextl+
    MoveSprite(4,$70,$ac)
    lda #$02
    sta main_menu_cursor
!nextl:
    cmp #$00
    bne !nextl+
    MoveSprite(4,$70,$7c)
!nextl:
    //jsr debug_line
    rts
    
options_move_cursor_down:
    inc main_menu_cursor
    lda main_menu_cursor
    cmp #$01
    bne !nextl+
    MoveSprite(4,$70,$94)
!nextl:
    cmp #$02
    bne !nextl+
    MoveSprite(4,$70,$ac)
!nextl:
    cmp #$03
    bne !nextl+
    lda #$00
    sta main_menu_cursor
    MoveSprite(4,$70,$7c)
!nextl:
    //jsr debug_line
    rts

options_xit:
    jsr draw_main_menu
    rts
options_joyport:
    inc option_joyport
    lda option_joyport
    cmp #$02
    bne op_jp_2
    lda #$00
    sta option_joyport
op_jp_2:
    //jsr debug_line
    rts
options_music:
    inc option_music
    lda option_music
    cmp #$02
    bne op_ms_2
    lda #$00
    sta option_music
op_ms_2:
    //jsr debug_line
    rts

debug_line:
    clc
    lda option_joyport

    ldx #0
    ldy #24
    jsr print_hex // PrintHexColor(0,24,GREEN)

    lda option_music
    ldx #3
    ldy #24
    jsr print_hex

    lda main_menu_cursor
    ldx #6
    ldy #24
    jsr print_hex //PrintHexColor(6,24,BROWN)

    lda option_timer+1
    ldx #9
    ldy #24
    jsr print_hex // PrintHexColor(9,24,RED)

    rts

new_game:

    InitializeSpritesAlt(sprite_char_sel_table)

    AssignSpriteAnim(0,sprite_anim_helmet_still_left)
    SetSpriteColor(0,LIGHT_GRAY)
    AssignSpriteAnim(1,sprite_anim_legs_still_left)

    AssignSpriteAnim(2,sprite_anim_eagle_still_left)
    SetSpriteColor(2,ORANGE)
    AssignSpriteAnim(3,sprite_anim_legs_still_left)

    AssignSpriteAnim(4,sprite_arrow_thing)

    AssignSpriteAnim(5,sprite_anim_clicky_head_still)
    SetSpriteColor(5,GREEN)
    AssignSpriteAnim(6,sprite_anim_clicky_bottom_still_left)
    SetSpriteColor(6,LIGHT_GRAY)

    MoveSprite(0,160,70)
    MoveSprite(1,160,91)
    MoveSprite(2,160,120)
    MoveSprite(3,160,141)
    MoveSprite(4,120,80)
    MoveSprite(5,160,170)
    MoveSprite(6,160,191)

    ClearScreenColors(BLUE,YELLOW)

    PokeStringColor(1035,new_game_choose_char_text,YELLOW)
    PokeStringColor(1205,player_name_helmet_guy,YELLOW)
    PokeStringColor(1445,player_name_eagull,YELLOW)
    PokeStringColor(1685,player_name_clicky,YELLOW)
    
    jsr new_game_choose_char_set_anims

    // Draw "File" at the bottom with description of each character's abilities
    jsr new_game_choose_char_file_update // jsr change "File" description at bottom

new_game_choose_char:

    jsr KERNAL_GETIN
    ReadKeyJMP('Q',main_menu)
    ReadKeyJSR(KEY_CURSOR_DOWN,new_game_choose_char_down)
    ReadKeyJSR(KEY_CURSOR_UP,new_game_choose_char_up)
    ReadKeyJMP(KEY_RETURN,new_game_init)
    jsr update_sprites

 clc
    lda option_timer_joyport
    cmp #JOYPORT_TIMER
    bcc !ngml+
    lda #$00
    sta option_timer_joyport
    ReadJoyJSR(option_joyport,"DOWN",new_game_choose_char_down)
    ReadJoyJSR(option_joyport,"UP",new_game_choose_char_up)
    ReadJoyJMP(option_joyport,"FIRE",new_game_init)    
!ngml:

    jmp new_game_choose_char

new_game_choose_char_up:
    dec option_player_chosen
    lda option_player_chosen
    cmp #$ff
    bne !next+
    lda #$02
    sta option_player_chosen
!next:
    jsr new_game_choose_char_set_anims
    jsr new_game_choose_char_file_update // jsr change "File" description at bottom
    rts
new_game_choose_char_down:
    inc option_player_chosen
    lda option_player_chosen
    cmp #$03
    bne !next+
    lda #$00
    sta option_player_chosen
!next:
    jsr new_game_choose_char_set_anims
    jsr new_game_choose_char_file_update // jsr change "File" description at bottom
    rts

new_game_choose_char_file_update:
    rts

new_game_choose_char_set_anims:
    AssignSpriteAnim(0,sprite_anim_helmet_still_left)
    AssignSpriteAnim(1,sprite_anim_legs_still_left)
    AssignSpriteAnim(2,sprite_anim_eagle_still_left)
    AssignSpriteAnim(3,sprite_anim_legs_still_left)
    AssignSpriteAnim(5,sprite_anim_clicky_head_still)
    AssignSpriteAnim(6,sprite_anim_clicky_bottom_still_left)
    lda option_player_chosen
    cmp #$00
    bne !next+
    AssignSpriteAnim(0,sprite_anim_helmet_left)
    AssignSpriteAnim(1,sprite_anim_legs_left)
    MoveSprite(4,120,80)
!next:
    cmp #$01
    bne !next+
    AssignSpriteAnim(2,sprite_anim_eagle_left)
    AssignSpriteAnim(3,sprite_anim_legs_left)
    MoveSprite(4,120,130)
!next:
    cmp #$02
    bne !next+
    AssignSpriteAnim(5,sprite_anim_clicky_head)
    AssignSpriteAnim(6,sprite_anim_clicky_bottom_left)
    MoveSprite(4,120,180)
!next:
    rts

new_game_choose_char_text:
.text "choose your player"; .byte 0
player_name_helmet_guy:
.text "helmet guy"; .byte 0
player_name_eagull:
.text "eagull"; .byte 0
player_name_clicky:
.text "clicky"; .byte 0

new_game_choose_char_file_update_text:
new_game_choose_char_file_update_text_helmet_guy:
.text "helmet guy: ai hunter  "
.text "ability : telekinisis  " // "telekinetically" alter electronics
.text "weakness: "
.byte 0
new_game_choose_char_file_update_text_eagull:
.text "eagull: mad scientist  "
.text "ability : revamp       " // physically alter electronics
.text "weakness: "
.byte 0
new_game_choose_char_file_update_text_clicky:
.text "clicky: ai overlord    "
.text "ability : persiflage   " // subjugate electronics
.text "weakness: "
.byte 0

load_game:
    inc $d021
    jmp main_menu_loop

update_sprites:
    UpdateSprites()
    rts

level_init:
    lda #100
    sta var_health
    lda #$00
    sta var_sdcard_got
    sta var_camera_got
    sta var_script_got
    sta var_exit_got
    rts

new_game_init:
    // initialization stuff
    lda #$01
    sta var_level
    lda #$03
    sta var_lives
    lda #$00
    sta var_subscribers
    sta var_likes
    sta var_dislikes
    sta var_rating
    jsr level_init
    jsr load_level

main_game_loop:

    jsr KERNAL_GETIN
    ReadKeyJMP('Q',main_menu)

    jsr update_sprites
    jmp main_game_loop

load_level:
    lda #var_level
    ldx #$00
    ldy #$00
!ll:
    tya
    sta SCREEN_RAM,x
    sta SCREEN_RAM+256,x
    sta SCREEN_RAM+512,x
    sta SCREEN_RAM+768,x
    inx
    iny
    cpx #$00
    bne !ll-
    rts

splash_level:
    ClearScreenColors(BLUE,YELLOW)

    rts

splash_end_level:

    rts

splash_end_game:

    rts
