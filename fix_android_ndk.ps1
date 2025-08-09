# Fix Android NDK Issues
Write-Host "🔧 Fixing Android NDK Issues..." -ForegroundColor Green

# Remove NDK completely from Android configuration
$buildGradlePath = "android\app\build.gradle.kts"

if (Test-Path $buildGradlePath) {
    $content = Get-Content $buildGradlePath -Raw
    
    # Remove any NDK references
    $content = $content -replace "ndkVersion.*", ""
    $content = $content -replace "//.*NDK.*", ""
    
    # Add explicit NDK disable
    $content = $content -replace "android \{", "android {`n    // NDK disabled for compatibility"
    
    Set-Content $buildGradlePath $content
    Write-Host "✅ Removed NDK references from build.gradle.kts" -ForegroundColor Green
}

# Update gradle.properties
$gradlePropsPath = "android\gradle.properties"
if (Test-Path $gradlePropsPath) {
    $props = Get-Content $gradlePropsPath
    $props += "android.bundle.enableUncompressedNativeLibs=false"
    $props += "android.enableR8.fullMode=false"
    Set-Content $gradlePropsPath $props
    Write-Host "✅ Updated gradle.properties" -ForegroundColor Green
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Run: flutter clean" -ForegroundColor White
Write-Host "2. Run: flutter pub get" -ForegroundColor White
Write-Host "3. Run: flutter run" -ForegroundColor White
Write-Host "`n🌐 Or use web version: flutter run -d web-server" -ForegroundColor Cyan 