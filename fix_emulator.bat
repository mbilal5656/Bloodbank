@echo off
echo 🔧 Android Emulator Crash Fix
echo =============================
echo.
echo This will fix the emulator crash issue.
echo.
pause

powershell -ExecutionPolicy Bypass -File "fix_emulator.ps1"

echo.
echo Press any key to exit...
pause >nul 