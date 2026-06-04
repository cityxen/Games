@echo off
cd /d "%~dp0"

echo [1/4] Assembling...
call KickAss.bat src\main.asm
if errorlevel 1 goto :error
sort prg_files\main.sym > prg_files\main-sorted.sym

echo [2/4] Stripping KickAss header and generating STARTUP...
call kick2apple.bat .\prg_files\wad_a2.prg .\prg_files\wad_a2.bin --startup .\prg_files\startup.bin --brun WADA2
if errorlevel 1 goto :error

echo [3/4] Building disk image...
copy /b data\DOS3.3_EMPTY.po prg_files\wad_a2.po >nul
call diskimage.bat add --name HELLO --type a prg_files\wad_a2.po prg_files\startup.bin
if errorlevel 1 goto :error
call diskimage.bat add --name WADA2 --type b --addr 0x6000 prg_files\wad_a2.po prg_files\wad_a2.bin
if errorlevel 1 goto :error

echo [4/4] Done.
echo.
echo   prg_files\wad_a2.po  ^<-- boot this in AppleWin or copy to a real disk
echo.
echo   In AppleWin: File ^> Open Hard Disk or Disk 1 ^> select wad_a2.po, then reboot.
echo   The HELLO greeting runs automatically and BRUNs WADA2 at $6000.
goto :end

:error
echo.
echo BUILD FAILED
exit /b 1
:end
