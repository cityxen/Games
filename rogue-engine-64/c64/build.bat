echo Build Script: Building %1
call KickAss.bat main.asm
sort prg_files\main.sym > prg_files\main-sorted.sym
