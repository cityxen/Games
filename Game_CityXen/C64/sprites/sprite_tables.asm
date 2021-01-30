//////////////////////////////////////////////////////////////////////////
// SPRITE_TABLES
sprite_default_table:
sprite_initial_visible:
.byte %01111111 // 0
sprite_visible:
.byte %01111111 // 1
sprite_initial_size: // x,y  // 2-3
.byte %00000000,%00000000
sprite_size: // x,y  // 4-5
.byte %00000000,%00000000
sprite_initial_color_table: // 6-13
.byte ORANGE
.byte LIGHT_RED
.byte LIGHT_GREY
.byte LIGHT_RED
.byte CYAN
.byte GREEN
.byte YELLOW
.byte LIGHT_GREEN
sprite_color_table: // 14-21
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
.byte BLACK
sprite_initial_multicolor_colors_table: // 22-23
.byte BLACK, GRAY
sprite_multicolor_colors_table: // 24-25
.byte BLACK, GRAY
sprite_initial_multicolor_table: // 26
.byte %00111111
sprite_multicolor_table: // 27
.byte %00111111
sprite_initial_loc_table: // MSB,X,Y 
.byte $00,$3c,$64 // 28,29,30 // Helmet Guy Top Left
.byte $00,$3c,$78 // 31,32,33 // Helmet Guy Bot Left
.byte $04,$14,$64 // 34,35,36 // Helmet Guy Top Right
.byte $08,$14,$78 // 37,38,39 // Helmet Guy Bot Right
.byte $10,$42,$52 // 40,41,42 // Arrow
.byte $00,$3c,$34 // 43,44,45
.byte $00,$3c,$66 // 46,47,48
.byte $00,$3c,$38 // 49,50,51
sprite_loc_table: // MSB,X,Y 52-75
.byte $00,$3c,$64 // 28,29,30
.byte $00,$3c,$78 // 31,32,33
.byte $04,$14,$64 // 34,35,36
.byte $08,$14,$78 // 37,38,39
.byte $10,$42,$52 // 40,41,42
.byte $00,$3c,$34 // 43,44,45
.byte $00,$3c,$66 // 46,47,48
.byte $00,$3c,$38 // 49,50,51
