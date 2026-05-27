
//////////////////////////////////////////////////////////////////////////
// Basic Upstart
*=$0801 "basic_upstart"
.word usend
.word 2024  // line number
.byte $9e   // BASIC Token for SYS
.text toIntString(initialization) // start label to SYS to
.text ":"
.byte $80   // BASIC Token for END
.text ":"
.byte KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE
.byte KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE,KEY_DELETE
.text "CITYXEN - THE GAME"
usend: // link address
.byte 00,00
