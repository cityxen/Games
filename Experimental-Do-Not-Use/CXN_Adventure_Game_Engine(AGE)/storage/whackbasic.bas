
;whackbasic.prg ==0801==
    1 if a=0 then a=1:load"wd",8,1
    4 sys 13504
    5 print "{clr}{wht}"
    6 poke 53280,0:poke53281,0
   80 print "thanks for playing our game"
   90 print "enter your name and contact info"
   95 print "to be eligible to win your own "
   96 print "meatloaf for the c64. leave contact "
   97 print "empty if you do not wish, other wise "
   98 print "we will only use this to announce the "
   99 print "winner after the show. "
  100 print "name";:input n$
  200 print "contact info / email / phone #"
  210 input c$
  211 x=peek(17453)
  212 y=peek(17454)
  214 s$=str$(y*256+x)
  215 print "{clr}{wht}"
  216 poke 53280,0:poke53281,0
  220 print "name   : ";?n$
  240 print "contact: ";?c$
  250 print:print"is this correct? (Y/N)"
  255 k$=""
  260 get k$
  280 if k$ != "y" then goto 260
  600 print "{clr}{wht}"
  601 print "once again, thank you for playing "
  604 print "whackadoodle! by cityxen (2024)  "
  605 print "and submitting your entry to win a "
  610 print "meatloaf drive for the c64. "
  620 print "the meatloaf is what made this "
  630 print "possible. visit the meatloaf table "
  635 print "over in the vcfse area of sfge! "
  640 open 2,8,2,"ml:%wad&n="+n$"&c="+c$+"&s="+s$:close 2
  910 print:print"press any key to continue"
  920 getkey k$
  930 if k$="" then 920
  950 print "{clr}{wht}"
 1050 goto 4
 9999 open 2,8,2,"ml:%wad&reset=1":close 2