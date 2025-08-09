# PowerShell script to fix remaining Flutter issues in Blood Bank app

Write-Host "🩸 Blood Bank App - Fixing Remaining Issues" -ForegroundColor Red
Write-Host "=============================================" -ForegroundColor Yellow

# Function to replace withValues(alpha:) with withOpacity()
function Fix-WithValuesInFile {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        $originalContent = $content
        
        # Replace withValues(alpha: with withOpacity(
        $content = $content -replace '\.withValues\(alpha:\s*([^)]+)\)', '.withOpacity($1)'
        
        if ($content -ne $originalContent) {
            Set-Content -Path $FilePath -Value $content -NoNewline
            Write-Host "✅ Fixed: $FilePath" -ForegroundColor Green
            return $true
        } else {
            Write-Host "ℹ️  No changes needed: $FilePath" -ForegroundColor Gray
            return $false
        }
    } else {
        Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
        return $false
    }
}

# List of files to fix
$filesToFix = @(
    "lib/splash_screen.dart",
    "lib/signup_page.dart", 
    "lib/settings_page.dart",
    "lib/receiver_page.dart",
    "lib/profile_page.dart",
    "lib/notification_management_page.dart",
    "lib/forgot_password_page.dart",
    "lib/fix_emulator_issues.dart",
    "lib/contact_page.dart",
    "lib/blood_inventory_page.dart"
)

Write-Host "`n🔧 Fixing withValues(alpha:) issues..." -ForegroundColor Cyan
$fixedCount = 0

foreach ($file in $filesToFix) {
    if (Fix-WithValuesInFile -FilePath $file) {
        $fixedCount++
    }
}

Write-Host "`n📊 Summary: Fixed $fixedCount out of $($filesToFix.Count) files" -ForegroundColor Yellow

# Check Java version and provide guidance
Write-Host "`n☕ Checking Java environment..." -ForegroundColor Cyan

try {
    $javaVersion = java -version 2>&1 | Select-String "version" | ForEach-Object { $_.ToString() }
    Write-Host "Current Java version: $javaVersion" -ForegroundColor White
    
    if ($javaVersion -match '"1\.[0-6]\.') {
        Write-Host "⚠️  WARNING: Java version is too old for Gradle 8.11" -ForegroundColor Yellow
        Write-Host "   Please install Java 17 or higher" -ForegroundColor Yellow
    } elseif ($javaVersion -match '"1[0-6]\.') {
        Write-Host "⚠️  WARNING: Java version is too old for Gradle 8.11" -ForegroundColor Yellow
        Write-Host "   Please install Java 17 or higher" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Java version appears compatible" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Java not found in PATH" -ForegroundColor Red
    Write-Host "   Please install Java 17+ and add to PATH" -ForegroundColor Yellow
}

# Check JAVA_HOME
Write-Host "`n🏠 Checking JAVA_HOME..." -ForegroundColor Cyan
$javaHome = $env:JAVA_HOME
if ($javaHome) {
    Write-Host "JAVA_HOME: $javaHome" -ForegroundColor White
    if (Test-Path "$javaHome/bin/java.exe") {
        Write-Host "✅ JAVA_HOME points to valid Java installation" -ForegroundColor Green
    } else {
        Write-Host "❌ JAVA_HOME points to invalid location" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️  JAVA_HOME not set" -ForegroundColor Yellow
    Write-Host "   Consider setting JAVA_HOME to Java 17+ installation" -ForegroundColor Yellow
}

# Provide next steps
Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. If Java version is < 17, install Java 17+" -ForegroundColor White
Write-Host "2. Set JAVA_HOME environment variable" -ForegroundColor White
Write-Host "3. Run: flutter clean && flutter pub get" -ForegroundColor White
Write-Host "4. Run: flutter build apk" -ForegroundColor White
Write-Host "5. Check for any remaining compilation errors" -ForegroundColor White

Write-Host "`n🎉 Script completed!" -ForegroundColor Green