@echo off
echo 🔧 Removing NDK references...

REM Remove NDK from Android SDK
echo Removing NDK from Android SDK...
rmdir /s /q "C:\Users\Fiber\AppData\Local\Android\sdk\ndk" 2>nul

REM Clean Flutter
echo Cleaning Flutter...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

echo ✅ NDK removal complete!
echo Try running: flutter run
echo Or use web: flutter run -d web-server 