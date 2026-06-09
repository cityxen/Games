//////////////////////////////////////////////////////////////////////////////////////
// CITYXEN: SINGULARITY — sprites.asm
// PLACEHOLDER 4-direction walk animation sprites (24x21, single colour, 64 bytes ea).
//
// Layout (pointer = address/64):
//   Clicky: idle $C0 ($3000); walk $C1..$C8 = down0,down1,up0,up1,left0,left1,right0,right1
//   Clone : idle $C9 ($3240); walk $CA..$D1 = same order
//
// For now every direction reuses two generic "step" frames (legs swing) so you can
// SEE the animation working.  Replace the per-direction calls below with real
// directional art later — the engine just needs these 18 slots filled in this order.
//////////////////////////////////////////////////////////////////////////////////////

*=$3000 "SPRITES"

// ── Clicky shared upper body (case + screen face), 14 rows ──────────────────────────
.macro ClickyTop() {
    .byte %00111111,%11111111,%11111100
    .byte %01100000,%00000000,%00000110
    .byte %01011111,%11111111,%11111010
    .byte %01010000,%00000000,%00001010
    .byte %01010011,%10000111,%00001010   // eyes
    .byte %01010011,%10000111,%00001010
    .byte %01010000,%00000000,%00001010
    .byte %01010001,%10000001,%10001010
    .byte %01010001,%11111111,%10001010   // smile
    .byte %01010000,%01111110,%00001010
    .byte %01011111,%11111111,%11111010
    .byte %01100000,%00000000,%00000110
    .byte %00111111,%11111111,%11111100
    .byte %00001111,%11111111,%11110000
}
.macro ClickyIdle() {           // legs together
    ClickyTop()
    .byte %00001100,%00000000,%00110000
    .byte %00001100,%00000000,%00110000
    .byte %00011100,%00000000,%00111000
    .byte %00111100,%00000000,%00111100   // feet
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte 0
}
.macro ClickyWalkA() {          // step 1
    ClickyTop()
    .byte %00011000,%00000000,%00011000
    .byte %00011000,%00000000,%00011000
    .byte %00111000,%00000000,%00011100
    .byte %01110000,%00000000,%00001110
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte 0
}
.macro ClickyWalkB() {          // step 2
    ClickyTop()
    .byte %00001100,%00000000,%00110000
    .byte %00000110,%00000000,%01100000
    .byte %00001110,%00000000,%01110000
    .byte %00011100,%00000000,%00111000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte 0
}

// ── Clone shared upper body (DOS box), 13 rows ──────────────────────────────────────
.macro CloneTop() {
    .byte %01111111,%11111111,%11111110
    .byte %01000000,%00000000,%00000010
    .byte %01011111,%11111111,%11111010
    .byte %01010000,%00000000,%00001010
    .byte %01010110,%00000001,%10001010   // glaring eyes
    .byte %01010110,%00000001,%10001010
    .byte %01010000,%00000000,%00001010
    .byte %01010001,%11111111,%00001010   // scowl
    .byte %01010000,%00000000,%00001010
    .byte %01011111,%11111111,%11111010
    .byte %01000000,%00000000,%00000010
    .byte %01111111,%11111111,%11111110
    .byte %00010000,%00000000,%00001000
}
.macro CloneIdle() {
    CloneTop()
    .byte %00111000,%00000000,%00011100
    .byte %00101000,%00000000,%00010100
    .byte %00101000,%00000000,%00010100
    .byte %00111000,%00000000,%00011100
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte 0
}
.macro CloneWalkA() {
    CloneTop()
    .byte %00111000,%00000000,%00011100
    .byte %00110000,%00000000,%00001100
    .byte %01110000,%00000000,%00001110
    .byte %01100000,%00000000,%00000110
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte 0
}
.macro CloneWalkB() {
    CloneTop()
    .byte %00111000,%00000000,%00011100
    .byte %00001100,%00000000,%00110000
    .byte %00001110,%00000000,%01110000
    .byte %00000110,%00000000,%01100000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte %00000000,%00000000,%00000000
    .byte 0
}

// ── Clicky: idle + 4 dirs x 2 frames ($C0..$C8) ─────────────────────────────────────
ClickyIdle()    // $C0  idle (shown when not moving)
ClickyWalkA()   // $C1  down  frame 0
ClickyWalkB()   // $C2  down  frame 1
ClickyWalkA()   // $C3  up    frame 0
ClickyWalkB()   // $C4  up    frame 1
ClickyWalkA()   // $C5  left  frame 0
ClickyWalkB()   // $C6  left  frame 1
ClickyWalkA()   // $C7  right frame 0
ClickyWalkB()   // $C8  right frame 1

// ── Clone: idle + 4 dirs x 2 frames ($C9..$D1) ──────────────────────────────────────
CloneIdle()     // $C9  idle
CloneWalkA()    // $CA  down  frame 0
CloneWalkB()    // $CB  down  frame 1
CloneWalkA()    // $CC  up    frame 0
CloneWalkB()    // $CD  up    frame 1
CloneWalkA()    // $CE  left  frame 0
CloneWalkB()    // $CF  left  frame 1
CloneWalkA()    // $D0  right frame 0
CloneWalkB()    // $D1  right frame 1
