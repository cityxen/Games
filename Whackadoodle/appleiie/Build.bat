@echo off
cd /d "%~dp0"

echo [1/4] Assembling...
call KickAss.bat src\main.asm
if errorlevel 1 goto :error
sort prg_files\main.sym > prg_files\main-sorted.sym

echo [2/4] Stripping KickAss header and generating STARTUP...
powershell -ExecutionPolicy Bypass -File tools\make_binary.ps1
if errorlevel 1 goto :error

echo [3/4] Building disk image...
if not exist tools\ac.jar (
    echo.
    echo ERROR: tools\ac.jar not found.
    echo Download AppleCommander from:
    echo   https://github.com/AppleCommander/AppleCommander/releases
    echo Place ac.jar in the tools\ folder, then rebuild.
    goto :error
)

copy /b DOS3.3_EMPTY.po prg_files\wad_a2.po >nul
java -jar tools\ac.jar -p prg_files\wad_a2.po STARTUP bas 0x0801 < prg_files\startup.bin
if errorlevel 1 goto :error
java -jar tools\ac.jar -p prg_files\wad_a2.po WADA2 bin 0x0800 < prg_files\wad_a2.bin
if errorlevel 1 goto :error

echo [4/4] Done.
echo.
echo   prg_files\wad_a2.po  ^<-- boot this in AppleWin or copy to a real disk
echo.
echo   In AppleWin: File ^> Open Hard Disk or Disk 1 ^> select wad_a2.po, then reboot.
echo   The STARTUP program runs automatically and BRUNs WAD_A2 at $0800.
goto :end

:error
echo.
echo BUILD FAILED
exit /b 1
:end
