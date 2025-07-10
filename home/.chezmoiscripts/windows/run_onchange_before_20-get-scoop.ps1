Function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "scoop not found, installing..."
    if (-not (Test-IsAdministrator)) {
        irm get.scoop.sh | iex
    } else {
        iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
    }
} else {
    Write-Host "scoop is already installed. Skipping installation."
}