# PowerShell script to fix withOpacity deprecation warnings
Write-Host "Fixing withOpacity deprecation warnings..."

$files = @(
    "lib/home_page.dart",
    "lib/login_page.dart",
    "lib/signup_page.dart",
    "lib/forgot_password_page.dart",
    "lib/admin_page.dart",
    "lib/donor_page.dart",
    "lib/receiver_page.dart",
    "lib/profile_page.dart",
    "lib/settings_page.dart",
    "lib/settings_page_enhanced.dart",
    "lib/contact_page.dart",
    "lib/blood_inventory_page.dart",
    "lib/notification_management_page.dart",
    "lib/splash_screen.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Processing: $file"
        
        # Read the file content
        $content = Get-Content $file -Raw
        
        # Replace withOpacity with withValues
        $content = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
        
        # Write back to file
        Set-Content $file $content -NoNewline
        
        Write-Host "Fixed: $file"
    } else {
        Write-Host "File not found: $file"
    }
}

Write-Host "Completed fixing withOpacity deprecation warnings!"
