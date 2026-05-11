@echo off
cls
echo //------------------------------------------------------
echo ---- Build Script: Building WHACKADOODLE!
echo //------------------------------------------------------
rem update retro dev tools library
call E:\dev\cityxen\retro-dev-tools\build.bat 
echo //------------------------------------------------------
cd src
php update_revision.php
cd ..
echo //------------------------------------------------------
REM sidreloc -p 94 -z 80-ff -v data/input.sid data/output.sid
REM call genkickass-script.bat -t C64 -o ../prg_files -m true -s true -l "RETRO_DEV_LIB"
REM call Kickass.bat src/jread.asm
call KickAss.bat src/main.asm
echo //------------------------------------------------------
EXIT /B 0
del "prg_files\\wad.sym"
del "prg_files\\wad.sym"

rename "prg_files\\main.sym" "wad.sym"
sort   "prg_files\\wad.sym" > "prg_files\\wad-sorted.sym"

exomizer sfx basic -o prg_files\\wadx.prg prg_files\\wad.prg >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ---- EXOMIZED GOOD! RC[%ERRORLEVEL%]
) else (
    echo ---- EXOMIZED BAD! RC[%ERRORLEVEL%]
)
del "prg_files\\wad.prg"
rename "prg_files\\wadx.prg" "wad.prg"

echo F | xcopy "prg_files\\wadx.prg" "y:\\httpdocs\\c64\\wad.prg" /i /Y >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ---- COPIED TO Y DRIVE GOOD! RC[%ERRORLEVEL%]
) else (
    echo ---- COPIED TO Y DRIVE BAD! RC[%ERRORLEVEL%]
)

ftp -s:ftp.u64 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ---- FTP'd GOOD! RC[%ERRORLEVEL%]
) else (
    echo ---- FTP'd BAD! RC[%ERRORLEVEL%]
)

rem ftp -s:ftp.u2p >nul 2>&1


echo //------------------------------------------------------