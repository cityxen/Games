//////////////////////////////////////////////////////////////////////////////////////
// TRIVIA FIGHTERS 64 for C64
// By Deadline / CityXen 2026
// CityXen Games: https://cityxen.itch.io
//////////////////////////////////////
#importonce

//////////////////////////////////////////////////////////////
// Initialize

initialize:
    lda #$00
    sta ml_detected
    sta ml_enabled
    jsr ml_detect_meatloaf
    lda ml_detected   
    sta ml_enabled

    beq !+

    jsr MLHL_LOAD_COUNT

!:

	lda #$01 // score increment count subtract or add
    sta score_math_o
    FixSFXKit()
    jsr sfx_sound_on

                 
                         // 10 load timer
                            // 10 input timer timer 5 for input
    InitTimers(10,50,240,240,10,5)
    

    jmp main_loop_start
