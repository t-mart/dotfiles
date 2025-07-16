# Checks for admin privileges and re-launches the script if needed.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # If not running as admin, display a message and restart with elevated permissions.
    Write-Warning "Administrator permissions are required. Requesting elevation..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Wait
    exit # Exit the current non-elevated script.
}

# Set registry path and property variables
$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
$RegProperty = 'AllowDevelopmentWithoutDevLicense'

if (-not(Test-Path -Path $RegPath)) {
    New-Item -Path $RegPath -ItemType Directory -Force
}

New-ItemProperty -Path $RegPath -Name $RegProperty -Value 1 -PropertyType DWord -Force
Write-Host "Enabled Developer Mode"


sudo config --enable normal
Write-Host "Sudo enabled"