
; Generated by SpritePad C64 - Subchrist Software, 2003 - 2023.
; Assemble with 64TASS or similar.


; Colour values...

COLR_VIC_SCREEN = 9
COLR_VIC_SPRITE_MC1 = 0
COLR_VIC_SPRITE_MC2 = 1


; Quantities and dimensions...

SPRITE_COUNT = 19


; Data block sizes (in bytes)...

SZ_SPRITESET_DATA = 1216
SZ_SPRITESET_ATTRIB_DATA = 19


; Data block addresses (dummy values)...

addr_spriteset_data = $1000
addr_spriteset_attrib_data = $1000




; * INSERT EXAMPLE PROGRAM HERE! * (or just include this file in your project).




; SpriteSet Data...
; 19 images, 64 bytes per image, total size is 1216 ($4C0) bytes.

* = addr_spriteset_data
spriteset_data

sprite_image_0
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$F8,$00,$07,$F8,$00,$0F
.byte $F8,$00,$1F,$F8,$00,$1F,$83,$F8,$3E,$03,$F0,$3E,$03,$E0,$3C,$03
.byte $C0,$3C,$00,$00,$3E,$03,$C0,$3E,$03,$E0,$1F,$83,$F0,$1F,$FB,$F8
.byte $0F,$F8,$00,$07,$F8,$00,$01,$F8,$00,$00,$00,$00,$00,$00,$00,$01

sprite_image_1
.byte $00,$00,$00,$00,$00,$00,$00,$F8,$00,$03,$FE,$00,$07,$FF,$00,$0F
.byte $CF,$80,$1F,$CE,$C0,$1F,$FE,$40,$3F,$FC,$60,$3F,$FC,$20,$3F,$E0
.byte $20,$3C,$00,$20,$38,$00,$20,$30,$00,$60,$10,$30,$40,$18,$30,$C0
.byte $0C,$01,$80,$06,$03,$00,$03,$FE,$00,$00,$F8,$00,$00,$00,$00,$01

sprite_image_2
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$83,$C0,$0F,$C7,$E0,$1F
.byte $C7,$F0,$3F,$EF,$F8,$3F,$FF,$F8,$3F,$FF,$F8,$3F,$FF,$F8,$1F,$FF
.byte $F0,$1F,$FF,$F0,$0F,$FF,$E0,$07,$FF,$C0,$03,$FF,$80,$01,$FF,$00
.byte $00,$FE,$00,$00,$7C,$00,$00,$38,$00,$00,$10,$00,$00,$00,$00,$01

sprite_image_3
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$10,$00,$00
.byte $38,$00,$00,$38,$00,$00,$38,$00,$00,$7C,$3C,$1F,$FF,$F0,$3F,$FF
.byte $C0,$03,$FF,$80,$00,$FF,$00,$00,$FF,$00,$00,$FF,$00,$01,$FF,$80
.byte $01,$E7,$80,$03,$C1,$C0,$07,$00,$70,$00,$00,$00,$00,$00,$00,$01

sprite_image_4
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$06,$00,$C0,$0F,$01,$E0,$0F
.byte $83,$F0,$1F,$C7,$F8,$1F,$C3,$F8,$1F,$99,$F8,$0F,$BD,$F0,$00,$3C
.byte $00,$00,$18,$00,$00,$00,$00,$00,$3C,$00,$00,$7E,$00,$00,$7E,$00
.byte $00,$FF,$00,$00,$FF,$00,$00,$7E,$00,$00,$00,$00,$00,$00,$00,$01

sprite_image_5
.byte $00,$00,$00,$00,$FE,$00,$03,$FF,$C0,$03,$FF,$C0,$07,$FF,$E0,$07
.byte $FF,$E0,$06,$18,$60,$06,$18,$60,$06,$3C,$60,$07,$F7,$C0,$03,$67
.byte $C0,$02,$C3,$C0,$01,$6B,$C0,$00,$BF,$80,$00,$7F,$80,$00,$AA,$00
.byte $00,$55,$00,$00,$3E,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00,$01

sprite_image_6
.byte $00,$00,$00,$70,$E1,$F8,$71,$E3,$0C,$79,$E3,$00,$7B,$E1,$F0,$6F
.byte $60,$1C,$66,$63,$1C,$62,$63,$1C,$60,$61,$F8,$00,$00,$00,$FE,$7E
.byte $FC,$FD,$FF,$FF,$E1,$87,$C7,$C0,$C1,$80,$E0,$C1,$F0,$E0,$C0,$FE
.byte $E0,$C0,$DE,$E1,$D0,$87,$E1,$B9,$C7,$EF,$7D,$FF,$FF,$3E,$FC,$01

sprite_image_7
.byte $00,$00,$00,$00,$38,$00,$00,$38,$00,$03,$FF,$80,$07,$FF,$C0,$07
.byte $38,$C0,$06,$38,$00,$06,$38,$00,$07,$38,$00,$07,$FF,$80,$03,$FF
.byte $C0,$00,$39,$C0,$00,$38,$C0,$00,$38,$C0,$06,$39,$C0,$07,$FF,$C0
.byte $03,$FF,$80,$00,$38,$00,$00,$38,$00,$00,$00,$00,$00,$00,$00,$01

sprite_image_8
.byte $00,$00,$00,$00,$00,$00,$00,$10,$00,$00,$38,$00,$00,$7C,$00,$00
.byte $FE,$00,$01,$FF,$00,$03,$FF,$80,$07,$FF,$C0,$00,$7C,$00,$00,$7C
.byte $00,$00,$7C,$00,$00,$7C,$00,$00,$7C,$00,$00,$7C,$00,$00,$7C,$00
.byte $00,$7C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01

sprite_image_9
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$06,$00,$00
.byte $07,$00,$00,$07,$80,$07,$FF,$C0,$07,$FF,$E0,$07,$FF,$F0,$07,$FF
.byte $E0,$07,$FF,$C0,$00,$07,$80,$00,$07,$00,$00,$06,$00,$00,$04,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01

sprite_image_10
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$00,$3E,$00,$00
.byte $3E,$00,$00,$3E,$00,$00,$3E,$00,$00,$3E,$00,$00,$3E,$00,$00,$3E
.byte $00,$03,$FF,$E0,$01,$FF,$C0,$00,$FF,$80,$00,$7F,$00,$00,$3E,$00
.byte $00,$1C,$00,$00,$08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01

sprite_image_11
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00,$00
.byte $60,$00,$00,$E0,$00,$01,$E0,$00,$03,$FF,$E0,$07,$FF,$E0,$0F,$FF
.byte $E0,$07,$FF,$E0,$03,$FF,$E0,$01,$E0,$00,$00,$E0,$00,$00,$60,$00
.byte $00,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01

sprite_image_12
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.byte $3C,$00,$00,$FF,$00,$01,$FF,$80,$03,$FF,$C0,$03,$FF,$C0,$07,$FF
.byte $E0,$07,$FF,$E0,$07,$FF,$E0,$03,$FF,$C0,$03,$FF,$C0,$01,$FF,$80
.byte $00,$FF,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02

sprite_image_13
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$01
.byte $83,$07,$01,$C3,$87,$01,$C7,$80,$03,$EF,$83,$03,$EF,$C7,$03,$FF
.byte $C7,$03,$F9,$C7,$03,$D9,$C7,$03,$D9,$C7,$03,$C1,$E7,$03,$C1,$E7
.byte $03,$81,$E6,$01,$80,$C6,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

sprite_image_14
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$07,$00,$03,$1F
.byte $C7,$C7,$1F,$C7,$C7,$1C,$8F,$E7,$18,$0C,$06,$1C,$0C,$0E,$0E,$0E
.byte $0E,$07,$0F,$0C,$07,$87,$8C,$03,$87,$88,$33,$B3,$80,$3F,$B3,$88
.byte $3F,$3F,$1C,$00,$3E,$1C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

sprite_image_15
.byte $01,$21,$00,$09,$B7,$60,$0D,$BF,$E4,$0F,$FF,$FD,$7F,$FF,$FF,$3F
.byte $FF,$FE,$3F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE,$7F,$FF,$FF,$7F,$FF
.byte $FF,$FF,$FF,$FE,$7F,$FF,$FE,$7F,$FF,$FE,$3F,$FF,$FF,$7F,$FF,$FF
.byte $7F,$FF,$FC,$FF,$FF,$F8,$FF,$F7,$F8,$37,$66,$EC,$06,$24,$E0,$0A

sprite_image_16
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3E,$00,$03,$FF,$07,$07
.byte $87,$8F,$07,$C3,$8F,$07,$C7,$9E,$07,$DF,$38,$03,$FE,$38,$03,$F8
.byte $30,$01,$E0,$70,$01,$E0,$70,$01,$E0,$70,$00,$E0,$78,$00,$F0,$3F
.byte $00,$F0,$3F,$00,$60,$1F,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00

sprite_image_17
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$C0,$37,$F1,$E0,$77,$F9
.byte $E0,$77,$F8,$F0,$77,$FC,$F0,$F7,$FC,$F2,$F6,$3E,$76,$F6,$3E,$7E
.byte $F6,$1E,$7E,$EE,$0E,$7F,$EC,$1E,$7F,$EC,$FE,$77,$C0,$FE,$67,$C8
.byte $FC,$67,$D8,$F8,$63,$98,$E0,$00,$00,$00,$00,$00,$00,$00,$00,$00

sprite_image_18
.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$3C,$00,$00
.byte $3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$07,$FF,$E0,$07,$FF
.byte $E0,$07,$FF,$E0,$07,$FF,$E0,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00
.byte $00,$3C,$00,$00,$3C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$08



; SpriteSet Attribute Data...
; 19 attributes, 1 per image, 8 bits each, total size is 19 ($13) bytes.
; nb. Upper nybbles = MYXV, lower nybbles = colour (0-15).

* = addr_spriteset_attrib_data
spriteset_attrib_data

.byte $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$02,$00,$00,$0A
.byte $00,$00,$08


