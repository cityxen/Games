//////////////////////////////////////////////////////////////////////////////////////
//
// TRIVIA FIGHTERS 64 for C64
//
//                            by Deadline / CityXen 2026
// 
// Dependencies:
// The include folder from: https://github.com/cityxen/retro-dev-tools/include/commodore64
// must be in kickassembler path in the KickAss.cfg file:
//   -libdir "PATHTO:\dev\cityxen\retro-dev-tools\include\commodore64"
//
// CityXen Videos: https://youtube.com/@cityxen
// CityXen Games: https://cityxen.itch.io
//
//////////////////////////////////////////////////////////////////////////////////////

#importonce

//////////////////////////////////////////////////////////////
// Initialize

initialize:
    lda #$00
    sta ml_detected
    sta ml_enabled // meatloaf off by default, F1 on main screen enables it
    jsr ldsk_init // trivia load drive = drive the game loaded from,
                  // must read $ba before ml_detect_meatloaf clobbers it
    jsr ml_detect_meatloaf

    jsr trivia_load_count // from local disk (meatloaf is off)

	lda #$01 // score increment count subtract or add
    sta score_math_o
    FixSFXKit()
    jsr sfx_sound_on

    InitTimers(10,20,240,240,10,5,5)
    
    jsr random_init_sid

    jmp main_loop_start
