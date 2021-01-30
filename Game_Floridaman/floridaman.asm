//////////////////////////////////////////////////////////////////////////////////////
// Florida Man by Seth Parson aka Deadline
//////////////////////////////////////////////////////////////////////////////////////
//
// NOTES:
//	EACH LEVEL HAS A DIFFERENT GOAL
//		THE OBJECT IS TO COMPLETE THE LEVEL AND THEN GET CAUGHT BY POLICE AND
//		HAVE A CRAZY HEADLINE. THE MORE POINTS YOU SCORE DURING THE LEVEL
//		INCREASES THE YEARS IN PRISON YOU GET.
//
//////////////////////////////////////////////////////////////////////////////////////
.const C_ROUTINE_MEM     = $080E
.const C_LEVEL_ROUTINE   = $5000 // Load level into this area
#import "../ddl_asm_c64/Deadline_Library.asm"
#import "floridamanfont-charset.asm"
#import "floridaman_vars.asm"
.var mem_deadline_sprites = $A000
*=mem_deadline_sprites "DeadlineSprites"
#import "../ddl_asm_c64/CityXen_Sprites_Data.asm"
.var mem_floridaman_sprites = $A1C0
*=mem_floridaman_sprites "floridamansprites";
#import "floridaman_sprites.asm"
*=$CE00 "Data Tables"
#import "floridaman_data.asm"
//////////////////////////////////////////////////////////////////////////////////////
// File stuff
.file [name="prg_files/floridaman.prg", segments="Main,DDL,DefaultLevel"]
.file [name="prg_files/0.prg", segments="DefaultLevel"]
.file [name="prg_files/1.prg", segments="Level1"]
.file [name="prg_files/2.prg", segments="Level2"]
.disk [filename="floridaman.d64", name="FLORIDAMAN", id="2020!" ] {
	[name="FLORIDAMAN", type="prg",  segments="Main,DDL,DefaultLevel"],
	[name="----------------", type="rel"],
	[name="0", type="prg", segments="DefaultLevel"],
	[name="1", type="prg", segments="Level1"],
	[name="2", type="prg", segments="Level2"],
}
//////////////////////////////////////////////////////////////////////////////////////
.segment Main [allowOverlap]
*=$0801 "BASIC"
BasicUpstart(C_ROUTINE_MEM)
*=C_ROUTINE_MEM "Main ROUTINE"
program_start:
	sei
	DDL_Load_StringName("0",$50,$00)
  	jsr sub_initialize
  	jsr sub_title_screen
	jsr sub_initialize_vars
  	jmp GAME_ON

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: Setup initialize
//////////////////////////////////////////////////////////////////////////////////////	
sub_initialize:
	lda #54; sta $01
    lda #$93; jsr KERNAL_CHROUT // Clear Screen
	lda #$00; sta BORDER_COLOR; sta BACKGROUND_COLOR
	// Change the charset
	lda VIC_MEM_POINTERS;  ora #$0e; sta VIC_MEM_POINTERS
	lda VIC_CONTROL_REG_2; and #$ef; sta VIC_CONTROL_REG_2
	rts

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: Setup initialize
//////////////////////////////////////////////////////////////////////////////////////	
sub_initialize_vars:
	jsr sub_copy_floridaman_sprites

	// Fill in some default var values
 	lda #C_STARTING_LIVES; sta var_lives // starting lives
	lda #C_STARTING_LEVEL; sta var_level // starting level (add +1 for displaying on screen)

	// This routines will be set up inside the level routine that loads
	// Setup player location on screen
	lda #$80; sta var_player_x
	lda #$80; sta var_player_y
	lda #C_FM_X_MIN; sta var_fm_x_min
	lda #C_FM_X_MAX; sta var_fm_x_max
	lda #C_FM_Y_MIN; sta var_fm_y_min
	lda #C_FM_Y_MAX; sta var_fm_y_max

	// Turn off game sprites
    lda #$00; sta SPRITE_ENABLE
	rts

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: Title Screen
//////////////////////////////////////////////////////////////////////////////////////	
sub_title_screen:
    lda #$93
    jsr KERNAL_CHROUT
	jsr sub_copy_floridaman_font
	jsr sub_copy_floridaman_sprites
	jsr sub_copy_deadline_sprites
	
	PrintStrAtColor(15,7,"presents",WHITE)
	PrintStrAtColor(9,15,"press fire joyport 2",YELLOW)

	// PUT THE FLORIDA MAN TITLE ON THE SCREEN
	ldx #$00
putfloridamantitle:
	lda data_titlefloridaman,x;			sta SCREEN_RAM+12+360,x
	lda data_titlefloridamancolor,x;	sta COLOR_RAM+12+360,x
	lda data_titlefloridaman+14,x;		sta SCREEN_RAM+12+400,x
	lda data_titlefloridamancolor+14,x;	sta COLOR_RAM+12+400,x
	lda data_titlefloridaman+28,x;		sta SCREEN_RAM+12+440,x
	lda data_titlefloridamancolor+28,x; sta COLOR_RAM+12+440,x
	lda data_titlefloridaman+42,x;		sta SCREEN_RAM+12+480,x
	lda data_titlefloridamancolor+42,x; sta COLOR_RAM+12+480,x
	inx
	cpx #14
	bne putfloridamantitle
	// PUT THE CITYXEN SPRITES ON THE SCREEN
    lda #$FF
	sta SPRITE_ENABLE
	lda #$7f
	sta SPRITE_MULTICOLOR
    lda #LIGHT_GRAY; 		sta SPRITE_MULTICOLOR_0
    lda #GRAY; sta SPRITE_MULTICOLOR_1
    lda #$00;		sta SPRITE_MSB_X

    lda #DARK_GRAY
    sta SPRITE_0_COLOR
    sta SPRITE_1_COLOR
    sta SPRITE_2_COLOR
    sta SPRITE_3_COLOR
    sta SPRITE_4_COLOR
    sta SPRITE_5_COLOR
    sta SPRITE_6_COLOR

	lda #$80; sta SPRITE_0_POINTER
    lda #$81; sta SPRITE_1_POINTER
    lda #$82; sta SPRITE_2_POINTER
    lda #$83; sta SPRITE_3_POINTER
    lda #$84; sta SPRITE_4_POINTER
    lda #$85; sta SPRITE_5_POINTER
    lda #$86; sta SPRITE_6_POINTER

    lda #C_CITYXEN_X_POS; sta SPRITE_0_X
    lda #C_CITYXEN_X_POS+$11; sta SPRITE_1_X
    lda #C_CITYXEN_X_POS+$22; sta SPRITE_2_X
    lda #C_CITYXEN_X_POS+$36; sta SPRITE_3_X
    lda #C_CITYXEN_X_POS+$4a; sta SPRITE_4_X
    lda #C_CITYXEN_X_POS+$5e; sta SPRITE_5_X
    lda #C_CITYXEN_X_POS+$72; sta SPRITE_6_X

    lda #C_CITYXEN_Y_POS;
    sta SPRITE_0_Y
    sta SPRITE_1_Y
    sta SPRITE_2_Y
    sta SPRITE_3_Y
    sta SPRITE_4_Y
    sta SPRITE_5_Y
    sta SPRITE_6_Y
	
	ldx #$00
    stx sin_counter0
    ldx #$30
    stx sin_counter1
    ldx #$50
    stx sin_counter2
    ldx #$70
    stx sin_counter3
    ldx #$90
    stx sin_counter4
    ldx #$b0
    stx sin_counter5
    ldx #$d0
    stx sin_counter6
    
	// Setup Squirrel Sprite
	lda #SPRITE_SQUIRREL_SITTING
	sta SPRITE_7_POINTER 
	lda #$00; sta SPRITE_7_X
	lda #$c0; sta SPRITE_7_Y
	lda #BROWN
	sta SPRITE_7_COLOR
	lda SPRITE_EXPAND_X
	ora #128
	sta SPRITE_EXPAND_X
	lda SPRITE_EXPAND_Y
	ora #128
	sta SPRITE_EXPAND_Y

	// TITLE SCREEN LOOP WAITING FOR FIRE BUTTON TO BE PRESSED
title_loop:

	jsr sub_title_sin_cityxen

	lda VIC_RASTER_COUNTER; cmp #$02; bcs title_loop

	lda var_squirrely_stop
	cmp #$01
	bne squirrely_not_stopped
	lda #SPRITE_SQUIRREL_SITTING
	sta SPRITE_7_POINTER
	lda var_squirrely_stop_timer
	adc #$01
	sta var_squirrely_stop_timer
	bcc title_no_msb
	lda #$00
	sta var_squirrely_stop
	jmp title_no_msb

squirrely_not_stopped:
	lda SPRITE_7_X
	cmp #$97
	bne move_squirrely_continue
	lda SPRITE_MSB_X
	and #128
	cmp #128
	beq move_squirrely_continue
	inc var_squirrely_stop

move_squirrely_continue:

	lda var_sprite_7_anim_timer
	adc #$20
	sta var_sprite_7_anim_timer
	bcc over_squirrel_anim_reset
	
	lda SPRITE_7_POINTER
	cmp #SPRITE_SQUIRREL_RUN_2
	beq reset_squirrel_anim
	inc SPRITE_7_POINTER
	jmp over_squirrel_anim_reset
reset_squirrel_anim:
	lda #SPRITE_SQUIRREL_RUN_1
	sta SPRITE_7_POINTER
over_squirrel_anim_reset:

	clc
	lda SPRITE_7_X
	adc #$01
	sta SPRITE_7_X
	bcc title_no_msb
	lda var_sprite_7_msb
	bne reset_squirrely
	inc var_sprite_7_msb
	lda #$00
	sta SPRITE_7_X
	lda SPRITE_MSB_X
	ora #128
	sta SPRITE_MSB_X
	jmp title_no_msb
reset_squirrely:
	lda #$00
	sta SPRITE_7_X
	sta var_sprite_7_msb
	lda SPRITE_MSB_X
	and #127
	sta SPRITE_MSB_X
title_no_msb:
	
	// READ JOYSTICK 2, CHECK FOR FIRE BUTTON PRESS
	jsr sub_read_joystick_2
	lda var_joy_2_fire
	cmp #$1
	bne not_title_loop
	rts
not_title_loop:
	jmp title_loop


sub_title_sin_cityxen:

	lda VIC_RASTER_COUNTER
	cmp #$E5
	bcc stscout

    inc sin_counter0
    inc sin_counter1
    inc sin_counter2
    inc sin_counter3
    inc sin_counter4
    inc sin_counter5
    inc sin_counter6

    ldx sin_counter0
    lda mem_ddlsin,x
    adc #C_CITYXEN_Y_POS
    sta SPRITE_0_Y

    ldx sin_counter1
    lda mem_ddlsin,x
    adc #C_CITYXEN_Y_POS
    sta SPRITE_1_Y

    ldx sin_counter2
    lda mem_ddlsin,x
    adc #C_CITYXEN_Y_POS
    sta SPRITE_2_Y

    ldx sin_counter3
    lda mem_ddlsin,x
    adc #C_CITYXEN_Y_POS
    sta SPRITE_3_Y

    ldx sin_counter4
    lda mem_ddlsin,x
    adc #C_CITYXEN_Y_POS
    sta SPRITE_4_Y

    ldx sin_counter5
    lda mem_ddlsin,x
    adc #C_CITYXEN_Y_POS
    sta SPRITE_5_Y

    ldx sin_counter6
    lda mem_ddlsin,x
    adc #C_CITYXEN_Y_POS
    sta SPRITE_6_Y
stscout:
	rts
mem_ddlsin:
.byte $0d,$0d,$0d,$0d,$0e,$0e,$0e,$0f,$0f,$0f,$0f,$10,$10,$10,$11,$11
.byte $11,$11,$12,$12,$12,$12,$13,$13,$13,$13,$14,$14,$14,$14,$15,$15
.byte $15,$15,$15,$16,$16,$16,$16,$16,$17,$17,$17,$17,$17,$17,$17,$17
.byte $18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18
.byte $18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18
.byte $18,$17,$17,$17,$17,$17,$17,$17,$16,$16,$16,$16,$16,$16,$15,$15
.byte $15,$15,$14,$14,$14,$14,$14,$13,$13,$13,$13,$12,$12,$12,$12,$11
.byte $11,$11,$10,$10,$10,$10,$0f,$0f,$0f,$0e,$0e,$0e,$0e,$0d,$0d,$0d
.byte $0c,$0c,$0c,$0b,$0b,$0b,$0b,$0a,$0a,$0a,$09,$09,$09,$09,$08,$08
.byte $08,$07,$07,$07,$07,$06,$06,$06,$06,$05,$05,$05,$05,$05,$04,$04
.byte $04,$04,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
.byte $02,$02,$02,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$04,$04,$04
.byte $04,$04,$05,$05,$05,$05,$06,$06,$06,$06,$07,$07,$07,$07,$08,$08
.byte $08,$08,$09,$09,$09,$0a,$0a,$0a,$0a,$0b,$0b,$0b,$0c,$0c,$0c,$0c

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: GAME ON
//////////////////////////////////////////////////////////////////////////////////////
GAME_ON:
    lda #$93; jsr KERNAL_CHROUT
	jsr sub_load_level
	jmp C_LEVEL_ROUTINE

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: Load Level
//////////////////////////////////////////////////////////////////////////////////////
sub_load_level:
	lda #$93; jsr KERNAL_CHROUT
	PrintStrAtColor(5,5,"loading level:",WHITE)
// SET FILENAME
	ldx #$00
	lda #$00
set_filename_loop1:
	sta var_filename,x
	inx
	cpx #$0F
	bne set_filename_loop1
	lda var_level
	clc
	adc #$30
	sta var_filename
	PrintAtColor(19,5,var_filename,RED)
	PrintStrAtColor(5,7,"filename:",WHITE)
	PrintAtColor(14,7,var_filename,RED)
	DDL_Load_MemName(var_filename,$50,$00)
	PrintAtRainbow(5,9,level_message) // show the loaded level message
	// READ JOYSTICK 2, CHECK FOR FIRE BUTTON PRESS
	PrintStrAtColor(5,11,"press fire to start",YELLOW)
load_level_temp_check_fire:
	jsr sub_read_joystick_2
	lda var_joy_2_fire
	beq load_level_temp_check_fire
	rts

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: Move Player
//////////////////////////////////////////////////////////////////////////////////////
sub_move_player:
	lda #$01
	cmp VIC_RASTER_COUNTER
	bcs ok_move
	rts
ok_move:
	lda var_joy_2_x
	beq move_y
	cmp #$ff
	beq left
right:
	inc var_player_x
	jmp move_y
left:
	dec var_player_x
move_y:
	lda var_joy_2_y
	beq check_boundry
	cmp #$ff
	beq up
down:
 	inc var_player_y
 	jmp check_boundry
up:
	dec var_player_y
check_boundry:
	lda var_player_x
	cmp var_fm_x_max
	bne ckbnx2
	dec var_player_x
	jmp ckbny
ckbnx2:
	cmp var_fm_x_min
	bne ckbny
	inc var_player_x
ckbny:
	lda var_player_y
	cmp var_fm_y_max
	bne ckbny2
	dec var_player_y
	jmp xitckbn
ckbny2:
	cmp var_fm_y_min
	bne xitckbn
	inc var_player_y
xitckbn:
	lda var_player_x
	sta SPRITE_0_X
	lda var_player_y
	sta SPRITE_0_Y
	rts

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: Update HUD
//////////////////////////////////////////////////////////////////////////////////////
sub_update_hud:
	lda #$20
	cmp VIC_RASTER_COUNTER
	beq do_hud
	rts
do_hud:
	PrintStrAtColor(30,0,"lives:",WHITE)
	PrintDecAtColor(37,0,var_lives,WHITE)

	// DEBUG STUFF
	PrintStrAtColor(30,21,"debuginfo:",RED)
	PrintDecAtColor(30,22,var_player_x,WHITE)
	PrintDecAtColor(30,23,var_player_y,WHITE)
	PrintDecAtColor(30,24,var_joy_2_fire,WHITE)

    rts	

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: Copy Florida Man FONT into VIC mem
//////////////////////////////////////////////////////////////////////////////////////
sub_copy_floridaman_font:
	// copy the Florida Man font to the showing area from $4000 to $3800
	ldx #$00
copy_fmf_loopz1:
	lda $4000,x; sta $3800,x
	lda $4100,x; sta $3900,x	
	lda $4200,x; sta $3A00,x
	lda $4300,x; sta $3B00,x
	lda $4400,x; sta $3C00,x
	lda $4500,x; sta $3D00,x
	lda $4600,x; sta $3E00,x
	lda $4700,x; sta $3F00,x
	inx
	bne copy_fmf_loopz1
	rts

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: Copy Deadline Sprites into VIC mem
//////////////////////////////////////////////////////////////////////////////////////
sub_copy_deadline_sprites:
	// copy the deadline sprites
	ldx #$00
copyloopz1:
	lda mem_deadline_sprites,x; sta $2000,x
	inx
	bne copyloopz1
copyloopz2:
	lda mem_deadline_sprites+$100,x; sta $2100,x
	inx
	cpx #$C1
	bne copyloopz2
	rts

//////////////////////////////////////////////////////////////////////////////////////
// Subroutine: Copy Florida Man Sprites into VIC mem
//////////////////////////////////////////////////////////////////////////////////////
sub_copy_floridaman_sprites: // copy the floridaman sprites to the showing area from $A1C0-$B7C1 to $2000 
	ldx #$00
copy_flm_loopz1:
	lda mem_floridaman_sprites,x; sta $2000,x
	lda mem_floridaman_sprites+$100,x; sta $2100,x
	lda mem_floridaman_sprites+$200,x; sta $2200,x
	lda mem_floridaman_sprites+$300,x; sta $2300,x
	lda mem_floridaman_sprites+$400,x; sta $2400,x
	lda mem_floridaman_sprites+$500,x; sta $2500,x
	lda mem_floridaman_sprites+$600,x; sta $2600,x
	lda mem_floridaman_sprites+$700,x; sta $2700,x	
	lda mem_floridaman_sprites+$800,x; sta $2800,x
	lda mem_floridaman_sprites+$900,x; sta $2900,x
	lda mem_floridaman_sprites+$A00,x; sta $2A00,x
	lda mem_floridaman_sprites+$B00,x; sta $2B00,x
	lda mem_floridaman_sprites+$C00,x; sta $2C00,x
	lda mem_floridaman_sprites+$D00,x; sta $2D00,x
	lda mem_floridaman_sprites+$E00,x; sta $2E00,x
	lda mem_floridaman_sprites+$F00,x; sta $2F00,x
	lda mem_floridaman_sprites+$1000,x; sta $3000,x
	lda mem_floridaman_sprites+$1100,x; sta $3100,x
	lda mem_floridaman_sprites+$1200,x; sta $3200,x
	lda mem_floridaman_sprites+$1300,x; sta $3300,x
	lda mem_floridaman_sprites+$1400,x; sta $3400,x
	lda mem_floridaman_sprites+$1500,x; sta $3500,x
	inx
	bne copy_flm_loopz2
	rts
copy_flm_loopz2:
	jmp copy_flm_loopz1

#import "floridaman_levels.asm"
