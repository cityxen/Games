//////////////////////////////////////////////////////////////////////////
// SPRITE_ANIM_TABLES

sprites_default_animated:
sprites_animated_initial:
.byte %11111111
sprites_animated:
.byte %11111111
sprite_anim_assigned_table:
sprite_0_anim_assigned:
.byte 0,0
sprite_1_anim_assigned:
.byte 0,0
sprite_2_anim_assigned:
.byte 0,0
sprite_3_anim_assigned:
.byte 0,0
sprite_4_anim_assigned:
.byte 0,0
sprite_5_anim_assigned:
.byte 0,0
sprite_6_anim_assigned:
.byte 0,0
sprite_7_anim_assigned:
.byte 0,0

//////////////////////////////////////////////////////////////////////////
// Animation vars

sprite_initial_anim_index_table:
.byte 0,0,0,0,0,0,0,0
sprite_anim_index_table:
.byte 0,0,0,0,0,0,0,0
sprite_initial_anim_speed_table:
.byte $65,$65,$65,$65,$33,$45,$45,$05
sprite_anim_speed_table:
sprite_anim_speed:
.byte $65,$65,$65,$65,$33,$45,$45,$05
sprite_anim_timer_vars:
sprite_0_anim_timer_var:
.byte 0
sprite_1_anim_timer_var:
.byte 0
sprite_2_anim_timer_var:
.byte 0
sprite_3_anim_timer_var:
.byte 0
sprite_4_anim_timer_var:
.byte 0
sprite_5_anim_timer_var:
.byte 0
sprite_6_anim_timer_var:
.byte 0
sprite_7_anim_timer_var:
.byte 0

//////////////////////////////////////////////////////////////////////////
// Default Animations
sprite_anim_table:
sprite_anim_legs_right:
.byte $a9,$aa,$ab,$ac,$00
sprite_anim_legs_still_right:
.byte $a9,$00
sprite_anim_legs_left:
.byte $b1,$b2,$b3,$b4,$00
sprite_anim_legs_still_left:
.byte $b1,$00
sprite_anim_ai_spinner:
.byte $b8,$bc,$00
sprite_anim_script_spinner:
.byte $b9,$bc,$00
sprite_anim_sdcard_spinner:
.byte $ba,$bc,$00
sprite_anim_camera_spinner:
.byte $bb,$bc,$00
sprite_anim_helmet_right:
.byte $a0,$a1,$00
sprite_anim_helmet_still_right:
.byte $a0,$00
sprite_anim_helmet_left:
.byte $a2,$a3,$00
sprite_anim_helmet_still_left:
.byte $a2,$00
sprite_anim_eagle_right:
.byte $c8,$c9,$00
sprite_anim_eagle_still_right:
.byte $c8,$00
sprite_anim_eagle_left:
.byte $ca,$cb,$00
sprite_anim_eagle_still_left:
.byte $ca,$00
sprite_anim_eagle_front:
.byte $cc,$00
sprite_anim_eagle_back:
.byte $cd,$00
sprite_anim_clicky_head:
.byte $d0,$d1,$d2,$d3,$00
sprite_anim_clicky_head_still:
.byte $d0,$00
sprite_anim_clicky_bottom_right:
.byte $d8,$d9,$da,$00
sprite_anim_clicky_bottom_still_right:
.byte $d8,$00
sprite_anim_clicky_bottom_left:
.byte $db,$dc,$dd,$00
sprite_anim_clicky_bottom_still_left:
.byte $db,$00
sprite_anim_clicky_bottom_front:
.byte $de,$00
sprite_anim_clicky_bottom_back:
.byte $df,$00
sprite_arrow_thing:
.byte $bf,$be,$bd,$be,$bf,$00
sprite_yin_yang:
.byte $c0,$c1,$c2,$c3,$c4,$c5,$c6,$c7,$00

