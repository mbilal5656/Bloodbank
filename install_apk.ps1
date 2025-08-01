# PowerShell script to install APK on emulator
Write-Host "Setting up Flutter environment..." -ForegroundColor Green
$env:PATH += ";C:\flutter\bin"

Write-Host "Checking available devices..." -ForegroundColor Yellow
flutter devices

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "APK Installation Guide" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Make sure the emulator is running and authorized" -ForegroundColor White
Write-Host "2. Look for 'Allow USB debugging' dialog on emulator" -ForegroundColor White
Write-Host "3. Click 'Allow' on the emulator screen" -ForegroundColor White
Write-Host ""
Write-Host "Once authorized, the APK will be installed automatically." -ForegroundColor White
Write-Host ""

function Check-And-Install {
    Write-Host "Checking device authorization..." -ForegroundColor Yellow
    $devices = adb devices
    $authorized = $devices | Select-String "device$"
    
    if ($authorized) {
        Write-Host "Device authorized! Installing APK..." -ForegroundColor Green
        $result = adb install "build\app\outputs\flutter-apk\app-debug.apk"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "SUCCESS! APK installed successfully!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "The Blood Bank Management System app is now installed on your emulator." -ForegroundColor White
            Write-Host "You can find it in the app drawer." -ForegroundColor White
            Write-Host ""
            Write-Host "Admin Login:" -ForegroundColor Cyan
            Write-Host "Email: admin@bloodbank.com" -ForegroundColor White
            Write-Host "Password: admin123" -ForegroundColor White
            Write-Host ""
        } else {
            Write-Host "Failed to install APK. Please try again." -ForegroundColor Red
        }
    } else {
        Write-Host "Device not authorized yet. Please:" -ForegroundColor Yellow
        Write-Host "1. Open Android Studio" -ForegroundColor White
        Write-Host "2. Go to Tools -> AVD Manager" -ForegroundColor White
        Write-Host "3. Start the Pixel_9 emulator" -ForegroundColor White
        Write-Host "4. Click 'Allow' on the USB debugging dialog" -ForegroundColor White
        Write-Host ""
        Write-Host "Press any key to check again..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Check-And-Install
    }
}

Check-And-Install 