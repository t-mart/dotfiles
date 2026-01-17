$ElevatedBlock = {
    Write-Host "Enabling developer mode..." -NoNewline
    $RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
    if (-not (Test-Path -Path $RegPath)) {
        New-Item -Path $RegPath -ItemType Directory -Force
    }
    New-ItemProperty -Path $RegPath -Name 'AllowDevelopmentWithoutDevLicense' -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Host " Done." -ForegroundColor Green

    Write-Host "Enabling sudo..." -NoNewline
    sudo config --enable normal | Out-Null
    Write-Host " Done." -ForegroundColor Green

    Pause
}

$CurrentUserPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$IsAdmin = $CurrentUserPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($IsAdmin) {
    & $ElevatedBlock
}
else {
    # If not admin, start a new elevated process and pass the entire block to it.
    $ArgumentList = "-NoProfile -ExecutionPolicy Bypass -Command `"$ElevatedBlock`""
    Start-Process powershell.exe -Verb RunAs -ArgumentList $ArgumentList
}