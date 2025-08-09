# PowerShell script to fix BuildContext usage across async gaps
Write-Host "Fixing BuildContext usage across async gaps..."

$files = @(
    "lib/signup_page.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "Processing: $file"
        $content = Get-Content $file -Raw
        
        # Fix BuildContext usage by adding context.mounted checks
        $content = $content -replace 'ScaffoldMessenger\.of\(context\)\.showSnackBar\(', 'if (context.mounted) ScaffoldMessenger.of(context).showSnackBar('
        
        Set-Content $file $content -NoNewline
        Write-Host "Fixed: $file"
    } else {
        Write-Host "File not found: $file"
    }
}

Write-Host "Completed fixing BuildContext usage!"
