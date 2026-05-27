main_game_loop:
    jsr KERNAL_GETIN
    ReadKeyJMP('Q',main_menu)
    jmp main_game_loop
