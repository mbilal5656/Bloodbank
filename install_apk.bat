@echo off
echo Setting up Flutter environment...
set PATH=%PATH%;C:\flutter\bin

echo Checking available devices...
flutter devices

echo.
echo ========================================
echo APK Installation Guide
echo ========================================
echo.
echo 1. Make sure the emulator is running and authorized
echo 2. Look for "Allow USB debugging" dialog on emulator
echo 3. Click "Allow" on the emulator screen
echo.
echo Once authorized, the APK will be installed automatically.
echo.

:check_device
echo Checking device authorization...
adb devices | findstr "device" > nul
if %errorlevel% equ 0 (
    echo Device authorized! Installing APK...
    adb install "build\app\outputs\flutter-apk\app-debug.apk"
    if %errorlevel% equ 0 (
        echo.
        echo ========================================
        echo SUCCESS! APK installed successfully!
        echo ========================================
        echo.
        echo The Blood Bank Management System app is now installed on your emulator.
        echo You can find it in the app drawer.
        echo.
        echo Admin Login:
        echo Email: admin@bloodbank.com
        echo Password: admin123
        echo.
    ) else (
        echo Failed to install APK. Please try again.
    )
) else (
    echo Device not authorized yet. Please:
    echo 1. Open Android Studio
    echo 2. Go to Tools -^> AVD Manager
    echo 3. Start the Pixel_9 emulator
    echo 4. Click "Allow" on the USB debugging dialog
    echo.
    echo Press any key to check again...
    pause > nul
    goto check_device
)

pause 