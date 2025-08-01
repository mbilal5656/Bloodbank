# Fix Android Emulator Crash Script
# This script helps resolve the -1073740940 heap corruption error

Write-Host "Android Emulator Crash Fix Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Step 1: Stop any running emulators
Write-Host "`nStep 1: Stopping running emulators..." -ForegroundColor Yellow
try {
    $emulatorProcesses = Get-Process -Name "emulator*" -ErrorAction SilentlyContinue
    if ($emulatorProcesses) {
        $emulatorProcesses | Stop-Process -Force
        Write-Host "Stopped running emulators" -ForegroundColor Green
    } else {
        Write-Host "No running emulators found" -ForegroundColor Blue
    }
} catch {
    Write-Host "Warning: Could not stop emulator processes" -ForegroundColor Yellow
}

# Step 2: Delete the corrupted emulator
Write-Host "`nStep 2: Deleting corrupted emulator..." -ForegroundColor Yellow
$avdPath = "$env:USERPROFILE\.android\avd\bloodbank_emulator.avd"
$iniPath = "$env:USERPROFILE\.android\avd\bloodbank_emulator.ini"

if (Test-Path $avdPath) {
    Remove-Item -Path $avdPath -Recurse -Force
    Write-Host "Deleted corrupted AVD folder" -ForegroundColor Green
} else {
    Write-Host "AVD folder not found" -ForegroundColor Blue
}

if (Test-Path $iniPath) {
    Remove-Item -Path $iniPath -Force
    Write-Host "Deleted corrupted AVD ini file" -ForegroundColor Green
} else {
    Write-Host "AVD ini file not found" -ForegroundColor Blue
}

# Step 3: Clear Flutter cache
Write-Host "`nStep 3: Clearing Flutter cache..." -ForegroundColor Yellow
try {
    & "C:\flutter\bin\flutter.bat" clean
    Write-Host "Flutter cache cleared" -ForegroundColor Green
} catch {
    Write-Host "Failed to clear Flutter cache" -ForegroundColor Red
}

# Step 4: Create new emulator
Write-Host "`nStep 4: Creating new emulator..." -ForegroundColor Yellow
try {
    # Create new AVD with better settings
    $avdmanager = "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\avdmanager.bat"
    if (Test-Path $avdmanager) {
        & $avdmanager create avd -n "bloodbank_emulator_new" -k "system-images;android-33;google_apis;x86_64" --force
        Write-Host "New emulator created successfully" -ForegroundColor Green
        Write-Host "New emulator name: bloodbank_emulator_new" -ForegroundColor Cyan
    } else {
        Write-Host "AVD Manager not found. Please create emulator manually in Android Studio" -ForegroundColor Red
    }
} catch {
    Write-Host "Failed to create new emulator" -ForegroundColor Red
    Write-Host "Please create a new emulator manually in Android Studio" -ForegroundColor Yellow
}

# Step 5: Update GPU settings
Write-Host "`nStep 5: Recommended GPU settings..." -ForegroundColor Yellow
Write-Host "For better stability, use these emulator settings:" -ForegroundColor Cyan
Write-Host "   - Graphics: Software - GLES 2.0" -ForegroundColor White
Write-Host "   - Hardware acceleration: Disabled" -ForegroundColor White
Write-Host "   - Memory: 2048 MB" -ForegroundColor White
Write-Host "   - VM Heap: 256 MB" -ForegroundColor White

# Step 6: Alternative solutions
Write-Host "`nStep 6: Alternative solutions if problem persists:" -ForegroundColor Yellow
Write-Host "1. Update GPU drivers" -ForegroundColor White
Write-Host "2. Disable Windows Hypervisor Platform" -ForegroundColor White
Write-Host "3. Use a physical device instead of emulator" -ForegroundColor White
Write-Host "4. Try different Android API level (API 30 or 31)" -ForegroundColor White

Write-Host "`nScript completed!" -ForegroundColor Green
Write-Host "Try running your app now with the new emulator" -ForegroundColor Cyan 