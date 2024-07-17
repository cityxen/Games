//////////////////////////////////////////////////////////////////////////////////////
// C64/128 Joystick routine

*=$C000 "JREAD"

lda $dc00 // read joystick port 2
lsr       // get switch bits
ror up    // switch_history = switch_history/2 + 128*current_switch_state
lsr       // update the other switches' history the same way
ror down
lsr
ror left
lsr
ror right
lsr
ror button
rts

up:     .byte 0
down:   .byte 0
left:   .byte 0
right:  .byte 0
button: .byte 0
