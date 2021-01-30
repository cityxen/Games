//////////////////////////////////////////////////////////////////////////
// variable space
main_menu_gfx_title_line_1:
.byte $40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4a,$4b,$4c,$20,$20,$00
main_menu_gfx_title_line_2:
.byte $60,$61,$62,$63,$64,$65,$66,$67,$68,$69,$20,$6a,$6b,$6c,$4c,$00
main_menu_text_title:
.text "  cityxen 2021"; .byte 0
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
option_joyport:
.byte 1
option_music:
.byte 1
option_timer:
.byte 0,0
option_timer_joyport:
.byte 0
main_menu_cursor:
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