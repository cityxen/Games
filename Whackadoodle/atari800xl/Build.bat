@echo off
cd /d "%~dp0"

echo [1/3] Assembling...
call KickAss.bat src\main.asm
if errorlevel 1 goto :error
sort prg_files\main.sym > prg_files\main-sorted.sym

echo [2/3] Building Atari XEX...
powershell -ExecutionPolicy Bypass -File tools\make_xex.ps1
if errorlevel 1 goto :error

echo [3/3] Done.
echo.
echo   prg_files\whackadoodle_a8.xex  ^<-- load in Altirra or copy to real disk
echo.
echo   In Altirra: File ^> Boot Image ^> select whackadoodle_a8.xex
goto :end

:error
echo.
echo BUILD FAILED
exit /b 1
:end
