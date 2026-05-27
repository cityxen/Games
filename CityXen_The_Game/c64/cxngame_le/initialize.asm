//////////////////////////////////////////////////////////////////////////
// Initialization (Level Editor)
initialization:   
    SetCharacters(custom_font)
    lda #53270
    ora 16
    sta 53270
    
    lda #BLACK
    sta $d022
    lda #YELLOW
    sta $d023

    InitializeSpritesAlt(sprite_default_table)

   