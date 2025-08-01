# PowerShell script to use withOpacity for compatibility
# Since the current Dart SDK version doesn't fully support withValues

Write-Host "Using withOpacity for compatibility..."

# Get all Dart files in the lib directory
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    Write-Host "Processing: $($file.FullName)"
    
    # Read file content
    $content = Get-Content $file.FullName -Raw
    
    # Replace withValues with withOpacity for compatibility
    $newContent = $content -replace '\.withValues\(alpha:\s*([^)]+)\)', '.withOpacity($1)'
    
    # Write back to file if content changed
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "Updated: $($file.FullName)" -ForegroundColor Green
    }
}

Write-Host "Completed using withOpacity for compatibility!" -ForegroundColor Green 