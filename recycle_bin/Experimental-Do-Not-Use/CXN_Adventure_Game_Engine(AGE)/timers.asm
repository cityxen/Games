
//////////////////////////////////////////////////////////////////
// IRQ STUFF

irq_timers:

	lda PLAY_MUSIC
	beq !it+
	jsr music.play
	jmp !it++
!it:
	jsr $c028 // sound fx kit
!it:

	inc IRQ_TIMER1
	inc IRQ_TIMER2
	inc IRQ_TIMER3
	inc IRQ_TIMER4
	inc IRQ_TIMER5
	inc IRQ_TIMER_JOYSTICK
	inc IRQ_TIMER_JITTER
	inc IRQ_TIMER_SOUND
	inc IRQ_TIMER_ALLOW_INPUT

	lda IRQ_TIMER1
	cmp #40 
	bne !it+
	inc TRIG_1
	lda #$00
	sta IRQ_TIMER1

!it:

	lda IRQ_TIMER2
	cmp #120 // 2 second
	bne !it+
	inc TRIG_2
	lda #$00
	sta IRQ_TIMER2

!it:

	lda IRQ_TIMER3
	cmp #180 // 3 second
	bne !it+
	inc TRIG_3
	lda #$00
	sta IRQ_TIMER3

!it:
	lda IRQ_TIMER4
	cmp #80 
	bne !it+
	inc TRIG_4
	lda #$00
	sta IRQ_TIMER4

!it:
	lda IRQ_TIMER_JITTER
	cmp IRQ_TIMER_JITTER_CMP
	bne !it+
	inc TRIG_JITTER
	lda #$00
	sta IRQ_TIMER_JITTER

!it:
	lda IRQ_TIMER_JOYSTICK
	cmp #40
	bne !it+
	lda #$01
	sta TRIG_JOYSTICK // limit joystick input by time

!it:

	lda IRQ_TIMER_ALLOW_INPUT
	cmp #30 
	bne !it+
	inc TRIG_INPUT
	lda #$00
	sta IRQ_TIMER_ALLOW_INPUT

!it:

!it:

	

	jmp $ea31


pause:
	jsr reset_timer3
!p1:
	lda TRIG_3
	beq !p1-
	jsr reset_timer3
	rts


reset_timer1:
	lda #$00
	sta IRQ_TIMER1
	sta TRIG_1
	rts

reset_timer2:
	lda #$00
	sta IRQ_TIMER2
	sta TRIG_2
	rts

reset_timer3:
	lda #$00
	sta IRQ_TIMER3
	sta TRIG_3
	rts

reset_timer4:
	lda #$00
	sta IRQ_TIMER4
	sta TRIG_4
	rts

reset_input_timer:
	lda #$00
	sta IRQ_TIMER_ALLOW_INPUT
	sta TRIG_INPUT
	sta $C6 // clear buffer
	jsr KERNAL_GETIN
	rts

reset_jitter_timer:
	lda #$00
	sta TRIG_JITTER
	sta IRQ_TIMER_JITTER
	rts