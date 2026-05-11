@echo off
echo Build Script: Building %1
exomizer sfx basic -o prg_files\\wad-cxn-e.prg prg_files\\wad-cxn.prg 
call KickAss.bat wad.cloader.asm
