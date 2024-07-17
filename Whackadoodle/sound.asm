
//////////////////////////////////////////////////////////////////
// SOUND STUFF

sfk_sound_on:
	// jsr $c000
	rts

sfk_sound_off:
	// jsr $c010
	rts

sfk_clear:
	jsr $c1f9
	rts

play_sound_ding:
	// jsr sfk_clear
	lda #$02
	sta $02a7
	rts	
play_sound_get_ready:
	// jsr sfk_clear
	lda #$01
	sta $02a8
	rts

play_sound_wrong:
	// jsr sfk_clear
	lda #$04
	sta $02a7
	rts

play_sound_pow:
	// jsr sfk_clear
	lda #$05
	sta $02a9
	rts

play_sound_miss:
	// jsr sfk_clear
	lda #$06
	sta $02a8
	rts

play_sound_gameover:
	// jsr sfk_clear
	lda #$07
	sta $02a7
	rts
