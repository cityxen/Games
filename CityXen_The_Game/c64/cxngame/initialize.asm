//////////////////////////////////////////////////////////////////////////
// Initialization
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

    AssignSpriteAnim(0,sprite_anim_helmet_left)
    SetSpriteColor(0,LIGHT_GRAY)
    AssignSpriteAnim(1,sprite_anim_legs_right)

    AssignSpriteAnim(2,sprite_yin_yang)
    SetSpriteColor(2,WHITE)

    AssignSpriteAnim(4,sprite_arrow_thing)

    AssignSpriteAnim(5,sprite_anim_clicky_head_still)
    SetSpriteColor(5,GREEN)
    AssignSpriteAnim(6,sprite_anim_clicky_bottom_still_left)
    SetSpriteColor(6,LIGHT_GRAY)

    MoveSprite(0,255,70)
    MoveSprite(1,255,91)
    MoveSprite(2,290,50)
    MoveSprite(3,160,141)
    MoveSprite(4,120,80)
    MoveSprite(5,160,170)
    MoveSprite(6,160,191)