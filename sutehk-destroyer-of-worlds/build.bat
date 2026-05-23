echo Build Script: Building %1
rem sidreloc -p 50 -z 80-ff -v input.sid output.sid
call genkickass-script.bat -t C64 -o prg_files -m true -s true -l "E:\dev\cityxen\Commodore64_Programming\include"
call KickAss.bat main.asm
rem exomizer sfx basic -o prg_files\\main-x.prg prg_files\\main.prg 
rem move prg_files\\main-x.prg prg_files\\sutehk.prg
sort prg_files\\main.sym > prg_files\\main-sorted.sym
