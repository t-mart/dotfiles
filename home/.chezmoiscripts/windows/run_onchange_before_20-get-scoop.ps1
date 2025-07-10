if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "scoop not found, installing..."
    irm get.scoop.sh | iex
} else {
    Write-Host "scoop is already installed. Skipping installation."
}