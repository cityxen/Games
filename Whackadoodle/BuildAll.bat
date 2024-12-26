@echo off
echo Build Script: Building %1
call Build.bat
call BuildCart.bat
call Copy.bat

