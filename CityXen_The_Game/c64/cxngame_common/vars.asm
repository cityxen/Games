//////////////////////////////////////////////////////////////////////////
// variable space


//////////////////////////////////////////////////////////////////////////
// Strings

main_menu_text_title:
.text "  cityxen 2024"; .byte 0
main_menu_text_new_game:
.text "new game"; .byte 0
main_menu_text_load_game:
.text "load game"; .byte 0
main_menu_text_options:
.text "options"; .byte 0
options_text_joyport:
.text "joyport"; .byte 0
options_text_music:
.text "music"; .byte 0
options_main_menu:
.text "back to main menu"; .byte 0

//////////////////////////////////////////////////////////////////////////
// Level editor Strings

main_menu_text_level_editor:
.text " (level editor)"; .byte 0
main_menu_text_edit_level:
.text "edit level"; .byte 0

//////////////////////////////////////////////////////////////////////////
// Vars

option_joyport:
.byte 1
option_music:
.byte 1
option_timer:
.byte 0,0
option_timer_joyport:
.byte 0
menu_cursor:
.byte 0
option_player_chosen:
.byte 0
var_level:
.byte 0
var_health:
.byte 0
var_sdcard_got:
.byte 0
var_camera_got:
.byte 0
var_script_got:
.byte 0
var_exit_got:
.byte 0
var_lives:
.byte 0
var_subscribers:
.byte 0
var_likes:
.byte 0
var_dislikes:
.byte 0
var_rating:
.byte 0

var_t1:
.byte 0
var_t2:
.byte 0
var_t3:
.byte 0

var_cursor_x_loc:
.byte 0
var_cursor_y_loc:
.byte 0
var_cursor_map_x:
.byte 0
var_cursor_map_y:
.byte 0
var_cursor_sel_x:
.byte 0
var_cursor_sel_y:
.byte 0
var_edit_mode: // 0=map edit, 1=select tile
.byte 0
var_edit_tile:
.byte 0

var_tile_x:
.byte 0
var_tile_y:
.byte 0
var_tile_to_draw:
.byte 0 
var_tile_color:
.byte 0 
var_tx:
.byte 0
var_ty:
.byte 0

var_level_data_size:
.byte 78 // +6656
var_level_data: // 78 bytes will define basic level 
var_sdcard_place:
.byte 0,0,0 // 0-64 (where in map matrix is it), x offset, y offset
var_camera_place:
.byte 0,0,0 // 0-64 (where in map matrix is it), x offset, y offset
var_script_place:
.byte 0,0,0 // 0-64 (where in map matrix is it), x offset, y offset
var_exit_place:
.byte 0,0,0 // 0-64 (where in map matrix is it), x offset, y offset
var_map: // (8x8 room grid)
         // x0000000 - North exit on or off
         // 0x000000 - South exit
         // 00x00000 - East exit
         // 000x0000 - West exit
         // 0000x000 - Eagull's shop
         // 00000x00 - ?
         // 000000x0 - ?
         // 0000000x - ?
//    v Start at this block each level
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0

var_map_detail: // for other room features 13x8 grid x 64 = 6656 byte
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0

screen_data_blank: // (tiles)
.byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
.byte $0A,$0A,$0A,$0A,$0F,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11
.byte $11,$11,$10,$0F,$11,$11,$11,$10,$0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A
.byte $0A,$0A,$0A,$0A,$0A,$0A,$0E,$0D,$0A,$0A,$0A,$0E,$0D,$0A,$0A,$0A
.byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E,$0D,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E,$0D
.byte $0A,$0A,$0A,$0E,$0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
.byte $0A,$0A,$0E,$0D,$0A,$0A,$0A,$0E,$0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A
.byte $0A,$0A,$0A,$0A,$0A,$0A,$0E,$0D,$0A,$0A,$0A,$0E,$0D,$0A,$0A,$0A
.byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E,$0D,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E,$0D
.byte $0A,$0A,$0A,$0E,$0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
.byte $0A,$0A,$0E,$0D,$0A,$0A,$0A,$0E,$0B,$08,$08,$08,$08,$08,$08,$08
.byte $08,$08,$08,$08,$08,$08,$0C,$0D,$0A,$0A,$0A,$0E,$17,$18,$19,$1A
.byte $1B,$1C,$1D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0B,$08,$08,$08,$0C

map_border_data: // (tiles)
.byte $0F,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$11,$10
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E
.byte $0D,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0E
.byte $0B,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$0C

map_data_door_north:
.byte $15,$13
map_data_door_south:
.byte $13,$16
map_data_door_east:
.byte $13,$14
map_data_door_west:
.byte $13,$12

