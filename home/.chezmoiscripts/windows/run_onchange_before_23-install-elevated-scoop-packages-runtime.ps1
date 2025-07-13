# Checks for admin privileges and re-launches the script if needed.
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # If not running as admin, display a message and restart with elevated permissions.
    Write-Warning "Administrator permissions are required. Requesting elevation..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Wait
    exit # Exit the current non-elevated script.
}

# Reload Path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$scoopExecutable = Join-Path $env:USERPROFILE scoop\shims\scoop.ps1

# windowsdesktop-runtime is more like a task, not an application. it can be uninstalled after use.
& $scoopExecutable install windowsdesktop-runtime
& $scoopExecutable uninstall -p windowsdesktop-runtime

# ditto for vcredist
& $scoopExecutable install install extras/vcredist
& $scoopExecutable uninstall -p vcredist2005 vcredist2008 vcredist2010 vcredist2012 vcredist2013 vcredist
