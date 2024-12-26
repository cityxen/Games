//////////////////////////////////////////////////////////////////
// Initialize

initialize:
    FixSFXKit($c000)
    InitTimers(60,120,180,50,100)
    jmp main_loop_start
