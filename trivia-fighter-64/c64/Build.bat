@echo off
echo Build Script: Building %1

rem update retro dev tools library
call E:\dev\cityxen\retro-dev-tools\build.bat 

cd src
php update_revision.php
cd ..

REM sidreloc -p 94 -z 80-ff -v data/input.sid data/output.sid
REM call genkickass-script.bat -t C64 -o ../prg_files -m true -s true -l "RETRO_DEV_LIB"
REM call Kickass.bat src/jread.asm
call KickAss.bat src/main.asm

del "prg_files\\trivia-fighters-64.sym"
del "prg_files\\trivia-fighters-64-sorted.sym"

rename "prg_files\\main.sym" "trivia-fighters-64.sym"
sort   "prg_files\\trivia-fighters-64.sym" > "prg_files\\trivia-fighters-64-sorted.sym"

ftp -s:ftp.u64 >nul 2>&1
rem ftp -s:ftp.u2p >nul 2>&1



