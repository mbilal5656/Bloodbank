# PowerShell script to fix unused imports and variables
Write-Host "Fixing unused imports and variables..."

# Fix notification_helper.dart
$notificationHelperFile = "lib/notification_helper.dart"
if (Test-Path $notificationHelperFile) {
    Write-Host "Processing: $notificationHelperFile"
    $content = Get-Content $notificationHelperFile -Raw
    
    # Remove unused import
    $content = $content -replace "import 'package:timezone/timezone.dart';`n", ""
    
    # Remove unused field _notificationTimer
    $content = $content -replace "Timer\? _notificationTimer;`n", ""
    
    # Remove unused variable payload
    $content = $content -replace "final String payload = notificationDetails\.payload ?? '';`n", ""
    
    # Remove unused variable unreadCount
    $content = $content -replace "final int unreadCount = await _getUnreadNotificationCount\(\);`n", ""
    
    Set-Content $notificationHelperFile $content -NoNewline
    Write-Host "Fixed: $notificationHelperFile"
}

# Fix settings_page_enhanced.dart
$settingsEnhancedFile = "lib/settings_page_enhanced.dart"
if (Test-Path $settingsEnhancedFile) {
    Write-Host "Processing: $settingsEnhancedFile"
    $content = Get-Content $settingsEnhancedFile -Raw
    
    # Remove unused field _language
    $content = $content -replace "String _language = 'en';`n", ""
    
    Set-Content $settingsEnhancedFile $content -NoNewline
    Write-Host "Fixed: $settingsEnhancedFile"
}

# Remove print statements from icon files
$iconFiles = @(
    "create_icon.dart",
    "create_simple_icon.dart",
    "fix_icon.dart"
)

foreach ($file in $iconFiles) {
    if (Test-Path $file) {
        Write-Host "Processing: $file"
        $content = Get-Content $file -Raw
        
        # Remove print statements
        $content = $content -replace "print\([^)]+\);`n", ""
        
        Set-Content $file $content -NoNewline
        Write-Host "Fixed: $file"
    }
}

Write-Host "Completed fixing unused imports and variables!"
