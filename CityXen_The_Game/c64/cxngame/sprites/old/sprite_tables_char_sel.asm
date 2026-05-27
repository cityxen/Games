//////////////////////////////////////////////////////////////////////////
// SPRITE_TABLES
sprite_char_sel_table:
sprite_char_sel_initial_visible:
.byte %01111111 // 0
sprite_char_sel_visible:
.byte %01111111 // 1
sprite_char_sel_initial_size: // x,y  // 2-3
.byte %00000000,%00000000
sprite_char_sel_size: // x,y  // 4-5
.byte %00000000,%00000000
sprite_char_sel_initial_color_table: // 6-13
.byte LIGHT_GREY
.byte LIGHT_RED
.byte ORANGE
.byte LIGHT_RED
.byte CYAN
.byte GREEN
.byte YELLOW
.byte LIGHT_GREEN
sprite_char_sel_color_table: // 14-21
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
sprite_char_sel_initial_multicolor_colors_table: // 22-23
.byte BLACK, GRAY
sprite_char_sel_multicolor_colors_table: // 24-25
.byte BLACK, GRAY
sprite_char_sel_initial_multicolor_table: // 26
.byte %01111111
sprite_char_sel_multicolor_table: // 27
.byte %01111111
sprite_char_sel_initial_loc_table: // MSB,X,Y 
.byte $00,$fc,$34 // 28,29,30 // Helmet Guy Top
.byte $00,$fc,$48 // 31,32,33 // Helmet Guy Bottom
.byte $00,$f4,$34 // 34,35,36 // Eagle Top
.byte $00,$f4,$48 // 37,38,39 // Eagle Bottom
.byte $10,$42,$52 // 40,41,42 // Arrow
.byte $00,$3c,$34 // 43,44,45 // Clicky Top
.byte $00,$3c,$66 // 46,47,48 // Clicky Bottom
.byte $00,$3c,$38 // 49,50,51
sprite_char_sel_loc_table: // MSB,X,Y 52-75
.byte $00,$fc,$34 // 28,29,30
.byte $00,$fc,$38 // 31,32,33
.byte $04,$f4,$34 // 34,35,36
.byte $08,$f4,$48 // 37,38,39
.byte $10,$42,$52 // 40,41,42
.byte $00,$3c,$34 // 43,44,45
.byte $00,$3c,$66 // 46,47,48
.byte $00,$3c,$38 // 49,50,51
