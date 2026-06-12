@echo off
cls
echo //------------------------------------------------------
echo ---- Build Script: Building TRIVIA FIGHTERS 64
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
call KickAss.bat src/webtrivia-saver.asm
call KickAss.bat src/main.asm
echo //------------------------------------------------------

del "prg_files\\tf64.sym"
del "prg_files\\tf64-sorted.sym"
del "prg_files\\tf64.d81"

rename "prg_files\\main.sym" "tf64.sym"
sort   "prg_files\\tf64.sym" > "prg_files\\tf64-sorted.sym"

echo F | xcopy "data\\tf64-trivia.d81" "prg_files\\tf64.d81" /i /Y >nul 2>&1
call diskimage.bat add "prg_files\\tf64.d81" "prg_files\\tf64.prg"
rem call diskimage.bat create "prg_files\\tf64.d81"
rem call diskimage.bat add "prg_files\\tf64.d81" "prg_files\\webtrivia-saver.prg"
rem call diskimage.bat add "prg_files\\tf64.d64" "prg_files\\webtrivia-saver.prg"

rem exomizer sfx basic -o prg_files\\tf64x.prg prg_files\\tf64.prg >nul 2>&1
rem if %ERRORLEVEL% EQU 0 (
rem     echo ---- EXOMIZED GOOD! RC[%ERRORLEVEL%]
rem ) else (
rem     echo ---- EXOMIZED BAD! RC[%ERRORLEVEL%]
rem )
rem del "prg_files\\tf64.prg"
rem rename "prg_files\\tf64x.prg" "tf64.prg"

echo F | xcopy "prg_files\\tf64.prg" "y:\\httpdocs\\c64\\tf64.prg" /i /Y >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ---- COPIED TO Y DRIVE GOOD! RC[%ERRORLEVEL%]
) else (
    echo ---- COPIED TO Y DRIVE BAD! RC[%ERRORLEVEL%]
)

echo F | xcopy "prg_files\\tf64.prg" "r:\\c64\\tf64.prg" /i /Y >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ---- COPIED TO R DRIVE GOOD! RC[%ERRORLEVEL%]
) else (
    echo ---- COPIED TO R DRIVE BAD! RC[%ERRORLEVEL%]
)

ftp -s:ftp.u64 >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ---- FTP'd GOOD! RC[%ERRORLEVEL%]
) else (
    echo ---- FTP'd BAD! RC[%ERRORLEVEL%]
)

rem ftp -s:ftp.u2p >nul 2>&1


echo //------------------------------------------------------