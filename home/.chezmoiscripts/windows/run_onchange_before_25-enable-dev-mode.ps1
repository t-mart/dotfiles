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

# Check if Developer Mode is already enabled.
try {
    $currentValue = Get-ItemPropertyValue -Path $RegPath -Name $RegProperty -ErrorAction SilentlyContinue
    if ($currentValue -and $currentValue.$RegProperty -eq 1) {
        Write-Host "Developer Mode is already enabled."
        exit
    }
}
catch {
    Write-Error "An unexpected error occurred while checking the registry: $_"
    Read-Host "Press Enter to exit"
    exit
}


# Proceed to enable Developer Mode.
Write-Host "Enabling Developer Mode..."
try {
    # The -Force parameter creates the registry path if it doesn't exist.
    Set-ItemProperty -Path $RegPath -Name $RegProperty -Value 1 -Type DWord -Force -ErrorAction Stop
    Write-Host "Successfully enabled Developer Mode."
}
catch {
    Write-Error "Failed to enable Developer Mode: $_"
}
finally {
    Read-Host "Press Enter to exit"
}