@echo off
cls
echo //------------------------------------------------------
echo ---- Build Script: Building CityXen Singularity
echo //------------------------------------------------------
rem update retro dev tools library
rem call E:\dev\cityxen\retro-dev-tools\build.bat
echo //------------------------------------------------------
call KickAss.bat src/main.asm
echo //------------------------------------------------------

del "prg_files\singularity.sym"
del "prg_files\singularity-sorted.sym"

rename "prg_files\main.sym" "singularity.sym"
sort   "prg_files\singularity.sym" > "prg_files\singularity-sorted.sym"

rem echo F | xcopy "prg_files\singularity.prg" "y:\httpdocs\c64\singularity.prg" /i /Y >nul 2>&1
rem echo F | xcopy "prg_files\singularity.prg" "r:\c64\singularity.prg" /i /Y >nul 2>&1
rem ftp -s:ftp.u64 >nul 2>&1

echo //------------------------------------------------------
