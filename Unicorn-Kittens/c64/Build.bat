@echo off
cls
echo //------------------------------------------------------
echo ---- Build Script: Building Unicorn Kittens
echo //------------------------------------------------------
rem update retro dev tools library
rem call E:\dev\cityxen\retro-dev-tools\build.bat
echo //------------------------------------------------------
call KickAss.bat src/main.asm
echo //------------------------------------------------------

del "prg_files\unikit.sym"
del "prg_files\unikit-sorted.sym"

rename "prg_files\main.sym" "unikit.sym"
sort   "prg_files\unikit.sym" > "prg_files\unikit-sorted.sym"

echo //------------------------------------------------------
