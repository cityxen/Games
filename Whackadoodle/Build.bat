@echo off

petcat -w2 -o wadbasic.prg whackbasic.bas


echo Build Script: Building %1
call genkickass-script.bat -t C64 -o prg_files -m true -s true -l "RETRO_DEV_LIB"
call KickAss.bat whackadoodle.asm

# xcopy prg_files\\wad-cxn.prg prg_files\\wad-cxn-w.prg /Y

exomizer sfx basic -o prg_files\\wad-cxn-e.prg prg_files\\wad-cxn-w.prg 
xcopy prg_files\\wad-cxn-e.prg prg_files\\wad-cxn.prg /Y
xcopy prg_files\\wad-cxn-e.prg x:\\www\\tech.cityxen.net\\html\\m64\\games\\wad-cxn.prg /Y
xcopy prg_files\\wad.d64 x:\\www\\tech.cityxen.net\\html\\m64\\games\\wad.d64 /Y


#ftp -s:ftp.u64
ftp -s:ftp.u2