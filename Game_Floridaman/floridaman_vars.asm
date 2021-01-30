//////////////////////////////////////////////////////////////////////////////////////
// Florida Man vars and constants
//////////////////////////////////////////////////////////////////////////////////////
// CONSTANTS
.const C_STARTING_LIVES  = $04
.const C_STARTING_LEVEL  = $01
.const C_MAX_LEVELS      = $FF
.const C_FM_X_MIN        = $10
.const C_FM_X_MAX        = $EF
.const C_FM_Y_MIN        = $40
.const C_FM_Y_MAX        = $E0
.const C_MAX_X_TILES     = 15
.const C_MAX_Y_TILES     = 11
.const C_CITYXEN_X_POS   = $6c
.const C_CITYXEN_Y_POS   = $35
.var sin_counter0  = $cd90
.var sin_counter1  = $cd91
.var sin_counter2  = $cd92
.var sin_counter3  = $cd93
.var sin_counter4  = $cd94
.var sin_counter5  = $cd95
.var sin_counter6  = $cd96
//////////////////////////////////////////////////////////////////////////////////////
// Vars
// $0313 Unused (1 byte)
// $032E-$032F Unused (2 bytes)
// $03FC-$03FF (1020-1023) Unused (4 bytes).
.var var_score      	 = $03FC // score takes up 4 bytes
// $07E8-$07F7 (2024-2039) Unused (16 bytes).

// $02A7-$02FF (679-767) Unused (89 bytes).
.var var_lives      	 = $02A7
.var var_level           = $02A8
.var var_timer      	 = $02A9
.var var_monsters   	 = $02AA
.var var_scroll_p   	 = $02AB
.var var_scroll_x   	 = $02AC
.var var_player_x   	 = $02AD
.var var_player_y   	 = $02AE
.var var_player_bullet_x = $02AF
.var var_player_bullet_y = $02B0
.var var_sprite_color_reg= $02B1
.var var_fm_x_min        = $02B2
.var var_fm_x_max        = $02B3
.var var_fm_y_min        = $02B4
.var var_fm_y_max        = $02B5
.var var_sprite_0_msb    = $02B6
.var var_sprite_1_msb    = $02B7
.var var_sprite_2_msb    = $02B8
.var var_sprite_3_msb    = $02B9
.var var_sprite_4_msb    = $02BA
.var var_sprite_5_msb    = $02BB
.var var_sprite_6_msb    = $02BC
.var var_sprite_7_msb    = $02BD

.var var_sprite_7_anim_timer = $02BE
.var var_squirrely_stop  = $02BF
.var var_squirrely_stop_timer = $02C0

.var var_filename        = $02F0 // 16 bytes for filename

.var level_list = List(C_MAX_LEVELS)
.var level_goal = List(C_MAX_LEVELS)

.eval level_list.set(1, "squirrelomma dreams")
.eval level_goal.set(1, "steal a camera and take a selfie with a squirrel")
.eval level_list.set(2, "alpha male")            // FIND AND WEAR A DOG COSTUME, THEN BITE DOGS TO ESTABLISH DOMINANCE
.eval level_list.set(3, "gator done")            // BONUS ROUND: BREAK INTO GATOR FARM
.eval level_list.set(4, "break in")              // BREAK INTO JAIL, THEN HANG WITH YOUR FRIENDS
.eval level_list.set(5, "angry birds")           // STEAL YOUR NEIGHBOR'S PEACOCK BUT DON'T UPSET THE OTHER BIRDS
.eval level_list.set(6, "swan fu")               // BONUS ROUND: PRACTICE KARATE ON SWANS AT THE LOCAL PARK
.eval level_list.set(7, "chicken tonight")       // COLLECT INGREDIENTS, COOK FRIED CHICKEN, THEN ASSAULT YOUR GIRLFRIEND WITH IT
.eval level_list.set(8, "mop head horror")       // STEAL A MOP, WEAR IT ON YOUR HEAD AND DEMAND EGGS
.eval level_list.set(9, "safari")                // BONUS ROUND: STEAL 11 DIFFERENT ANIMALS FROM THE ZOO
.eval level_list.set(10,"hot date")              // STEAL A WALMART MOBILITY SCOOTER, THEN TAKE YOUR DATE TO A SPORTS BAR
.eval level_list.set(11,"bucket list")           // GET BITTEN BY A SHARK, SNAKE AND ALLIGATOR, PUNCHED BY A MONKEY (TWICE), STRUCK BY LIGHTNING
.eval level_list.set(12,"tutu fruity")           // BONUS ROUND: BREAK INTO THE FARMER'S MARKET TO CONSUME FRUIT WHILE WEARING A TUTU
.eval level_list.set(13,"meth busters")          // STEAL CHEMICALS, COOK SOME METH AND THEN ASK A COP IF IT IS GOOD QUALITY
.eval level_list.set(14,"you stole my fart")     // GET STABBED BY YOUR GIRLFRIEND AFTER FARTING ON HER
.eval level_list.set(15,"ayy lmao")              // BONUS ROUND: ATTEMPT TO HANG WITH THE ALIENS

//////////////////////////////////////////////////////////////////////////////////////
// Some Florida Man headlines
// Florida man threatens to release army of turtles
// Florida Man calls 911 80 times to demand kool-aid, hamburgers and weed
// Florida Man throws an alligator into a wendy's drive thru window
// Dog shoots Florida Man in the leg with a 9mm handgun
// Florida Man too fat for jail
// Florida Man dances on polive vehicle to ward off vampires
// Florida Man breaks into ex's home, poops on everything
// Florida man shoots volunteer in the butt because he doesn't like sea turtles
// Florida man beats ATM, says it gave too much cash

//////////////////////////////////////////////////////////////////////////////////////
// SPRITE DEFS
.const SPRITE_FLORIDA_MAN_STANDING      = $80
.const SPRITE_FLORIDA_MAN_WALK_RIGHT_1  = $81
.const SPRITE_FLORIDA_MAN_WALK_RIGHT_2  = $82
.const SPRITE_FLORIDA_MAN_WALK_RIGHT_3  = $83
.const SPRITE_FLORIDA_MAN_WALK_RIGHT_4  = $84
.const SPRITE_FLORIDA_MAN_WALK_DOWN_1   = $85
.const SPRITE_FLORIDA_MAN_WALK_DOWN_2   = $86
.const SPRITE_FLORIDA_MAN_WALK_DOWN_3   = $87
.const SPRITE_FLORIDA_MAN_WALK_DOWN_4   = $88
.const SPRITE_FLORIDA_MAN_WALK_UP_1     = $89
.const SPRITE_FLORIDA_MAN_WALK_UP_2     = $8A
.const SPRITE_FLORIDA_MAN_WALK_UP_3     = $8B
.const SPRITE_FLORIDA_MAN_WALK_UP_4     = $8C
.const SPRITE_GATOR_1                   = $8D
.const SPRITE_GATOR_2                   = $8E
.const SPRITE_GATOR_3                   = $8F
.const SPRITE_SQUIRREL_SITTING          = $90
.const SPRITE_SQUIRREL_RUN_1            = $91
.const SPRITE_SQUIRREL_RUN_2            = $92
.const SPRITE_METH_BAG_1                = $93
.const SPRITE_METH_BAG_2                = $94
.const SPRITE_METH_BAG_3                = $95
.const SPRITE_DOLLAR_BILL               = $96
.const SPRITE_COP_STANDING              = $97
.const SPRITE_COP_WALK_RIGHT_1          = $98
.const SPRITE_COP_WALK_RIGHT_2          = $99
.const SPRITE_COP_WALK_RIGHT_3          = $9A
.const SPRITE_COP_WALK_RIGHT_4          = $9B
.const SPRITE_COP_WALK_DOWN_1           = $9C
.const SPRITE_COP_WALK_DOWN_2           = $9D
.const SPRITE_COP_WALK_DOWN_3           = $9E
.const SPRITE_COP_WALK_DOWN_4           = $9F
.const SPRITE_COP_WALK_UP_1             = $A0
.const SPRITE_COP_WALK_UP_2             = $A1
.const SPRITE_COP_WALK_UP_3             = $A2
.const SPRITE_COP_WALK_UP_4             = $A3
.const SPRITE_CHEMICAL_1                = $A4
.const SPRITE_CHEMICAL_2                = $A5
.const SPRITE_STABBY_ABBY_STAND         = $A6
.const SPRITE_STABBY_ABBY_WALK_RIGHT_1  = $A7
.const SPRITE_STABBY_ABBY_WALK_RIGHT_2  = $A8
.const SPRITE_STABBY_ABBY_WALK_RIGHT_3  = $A9
.const SPRITE_STABBY_ABBY_WALK_RIGHT_4  = $AA
.const SPRITE_STABBY_ABBY_WALK_DOWN_1   = $AB
.const SPRITE_STABBY_ABBY_WALK_DOWN_2   = $AC
.const SPRITE_STABBY_ABBY_WALK_DOWN_3   = $AD
.const SPRITE_STABBY_ABBY_WALK_DOWN_4   = $AE
.const SPRITE_STABBY_ABBY_WALK_UP_1     = $AF
.const SPRITE_STABBY_ABBY_WALK_UP_2     = $B0
.const SPRITE_STABBY_ABBY_WALK_UP_3     = $B1
.const SPRITE_STABBY_ABBY_WALK_UP_4     = $B2
.const SPRITE_FART_WAFT_1               = $B3
.const SPRITE_FART_WAFT_2               = $B4
.const SPRITE_BIRD_STANDING             = $B5
.const SPRITE_BIRD_FLY_1                = $B6
.const SPRITE_BIRD_FLY_2                = $B7
.const SPRITE_BIRD_FLY_3                = $B8

anim_table_squirrel_run:
.byte SPRITE_SQUIRREL_RUN_1,SPRITE_SQUIRREL_RUN_2,0

//////////////////////////////////////////////////////////////////////////////////////
// CHARS
.const CHAR_LIVES_INDICATOR = 28
.const CHAR_HEART           = 29
.const CHAR_KEY             = 30
.const CHAR_METH            = 31
.const CHAR_YIN_YANG        = 33
.const CHAR_UP_ARROW        = 34
.const CHAR_DOWN_ARROW      = 35

//////////////////////////////////////////////////////////////////////////////////////
// TILES
.const TILE_ATM             = 36
.const TILE_METH_LAB        = 40
.const TILE_UFO             = 124
.const TILE_CAMERA          = 184
