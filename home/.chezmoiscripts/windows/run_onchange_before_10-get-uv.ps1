if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "uv not found, installing..."
    irm https://astral.sh/uv/install.ps1 | iex
} else {
    Write-Host "uv is already installed. Skipping installation."
}