//////////////////////////////////////////////////////////////
// WHACKADOODLE for C64 by Deadline / CityXen 2024
//
// Cartridge code & Meatloaf support by Jaime Idolpx
//
// Fairground tune by Saul Cross
//
// Thanks to Logg & the Atlanta Historical Computing Society 
// (AHCS) for support and play testing
//
//////////////////////////////////////////////////////////////
// You will need the following repo in order to compile this
// https://github.com/cityxen/Commodore64_Programming
// use -l "path-to-lib" in KickAss command line 
//////////////////////////////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////
// Initialize

initialize:
	lda #$01 // score increment count subtract or add
	sta score_math_o
    FixSFXKit($c000)
    InitTimers(60,120,240,80,30)
    jmp main_loop_start
