
//////////////////////////////////////////////////////////////////
// IRQ STUFF

irq_timers:

	lda play_music
	beq !it+
	jsr music.play
	jmp !it++
!it:
	jsr $c028 // sound fx kit
!it:

	inc irq_timer1
	inc irq_timer2
	inc irq_timer3
	inc irq_timer4
	inc irq_timer5
	inc irq_timer_joystick
	inc irq_timer_jitter
	inc irq_timer_sound
	inc irq_timer_allow_input

	lda irq_timer1
	cmp #40 
	bne !it+
	inc trig_1
	lda #$00
	sta irq_timer1

!it:

	lda irq_timer2
	cmp #120 // 2 second
	bne !it+
	inc trig_2
	lda #$00
	sta irq_timer2

!it:

	lda irq_timer3
	cmp #180 // 3 second
	bne !it+
	inc trig_3
	lda #$00
	sta irq_timer3

!it:
	lda irq_timer4
	cmp #80 
	bne !it+
	inc trig_4
	lda #$00
	sta irq_timer4

!it:
	lda irq_timer_jitter
	cmp irq_timer_jitter_cmp
	bne !it+
	inc trig_jitter
	lda #$00
	sta irq_timer_jitter

!it:
	lda irq_timer_joystick
	cmp #40
	bne !it+
	lda #$01
	sta trig_joystick // limit joystick input by time

!it:

	lda irq_timer_allow_input
	cmp #30 
	bne !it+
	inc trig_input
	lda #$00
	sta irq_timer_allow_input

!it:

!it:

	

	jmp $ea31


pause:
	jsr reset_timer3
!p1:
	lda trig_3
	beq !p1-
	jsr reset_timer3
	rts


reset_timer1:
	lda #$00
	sta irq_timer1
	sta trig_1
	rts

reset_timer2:
	lda #$00
	sta irq_timer2
	sta trig_2
	rts

reset_timer3:
	lda #$00
	sta irq_timer3
	sta trig_3
	rts

reset_timer4:
	lda #$00
	sta irq_timer4
	sta trig_4
	rts

reset_input_timer:
	lda #$00
	sta irq_timer_allow_input
	sta trig_input
	sta $C6 // clear buffer
	jsr KERNAL_GETIN
	rts

reset_jitter_timer:
	lda #$00
	sta trig_jitter
	sta irq_timer_jitter
	rts