@echo off
echo Build Script: Building %1
call genkickass-script.bat -t C64 -o prg_files -m true -s true -l "RETRO_DEV_LIB"
call KickAss.bat spinchooser7k.asm

#ftp -s:ftp.u64
ftp -s:ftp.u2



