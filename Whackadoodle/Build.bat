@echo off
call E:\dev\github\cityxen\retro-dev-tools\build.bat
echo Build Script: Building %1
call genkickass-script.bat -t C64 -o prg_files -m true -s true -l "E:\dev\github\cityxen\Commodore64_Programming\include"
call KickAss.bat whackadoodle.asm

sort prg_files/whackadoodle.sym > prg_files/wut.sym
