if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "scoop not found, installing..."
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
} else {
    Write-Host "scoop is already installed. Skipping installation."
}