# Blood Bank Windows App Icon Update Script

Write-Host "🩸 Updating Blood Bank Windows App Icon..." -ForegroundColor Red

# Create a simple blood bank icon using Flutter
Write-Host "📱 Generating blood bank icon..." -ForegroundColor Yellow

# Run the icon generator
flutter run -t generate_icon.dart --release

Write-Host "✅ Icon generation completed!" -ForegroundColor Green

# Update Windows app icon
Write-Host "🖥️ Updating Windows app icon..." -ForegroundColor Yellow

# Copy the generated icon to Windows resources
if (Test-Path "assets/icons/bloodbank_icon.png") {
    Copy-Item "assets/icons/bloodbank_icon.png" "windows/runner/resources/app_icon.ico" -Force
    Write-Host "✅ Windows app icon updated!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Icon file not found, using default icon" -ForegroundColor Yellow
}

Write-Host "🎉 Blood Bank Windows app icon update completed!" -ForegroundColor Green 