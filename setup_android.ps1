# Android Environment Setup Script
# Run this as Administrator in PowerShell

Write-Host "Setting up Android environment variables..." -ForegroundColor Cyan

# Set ANDROID_HOME
[Environment]::SetEnvironmentVariable('ANDROID_HOME', 'C:\Users\hp\AppData\Local\Android\Sdk', 'Machine')
Write-Host "ANDROID_HOME set to: C:\Users\hp\AppData\Local\Android\Sdk" -ForegroundColor Green

# Add Android tools to PATH
$currentPath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
$newPath = $currentPath + ';C:\Users\hp\AppData\Local\Android\Sdk\platform-tools;C:\Users\hp\AppData\Local\Android\Sdk\tools;C:\Users\hp\AppData\Local\Android\Sdk\tools\bin'
[Environment]::SetEnvironmentVariable('PATH', $newPath, 'Machine')
Write-Host "Android tools added to PATH" -ForegroundColor Green

Write-Host ""
Write-Host "Setup complete! Please:" -ForegroundColor Green
Write-Host "1. Close this PowerShell window" -ForegroundColor Yellow
Write-Host "2. Open a new PowerShell window" -ForegroundColor Yellow
Write-Host "3. Run: flutter doctor" -ForegroundColor Yellow
Write-Host ""
Write-Host "Then you can build APK with: flutter build apk" -ForegroundColor Cyan