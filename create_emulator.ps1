# Create new Android emulator
Write-Host "Creating new Android emulator..." -ForegroundColor Yellow

$avdmanager = "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\avdmanager.bat"

# Create emulator with specific settings
$process = Start-Process -FilePath $avdmanager -ArgumentList "create", "avd", "-n", "bloodbank_new", "-k", "system-images;android-33;google_apis_playstore;x86_64", "--force" -NoNewWindow -PassThru -RedirectStandardInput "n`n"

Write-Host "Emulator creation process started..." -ForegroundColor Green

# Wait for process to complete
$process.WaitForExit()

if ($process.ExitCode -eq 0) {
    Write-Host "Emulator created successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to create emulator" -ForegroundColor Red
}

Write-Host "Available emulators:" -ForegroundColor Cyan
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -list-avds 