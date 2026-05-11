echo Build Script: Building %1
sidreloc -p 50 -z 80-ff -v input.sid output.sid
call KickAss main.asm
