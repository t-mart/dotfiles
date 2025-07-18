# Reload Path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$sourceShellNss = Join-Path $env:CHEZMOI_SOURCE_DIR ".data\nilesoft-shell.nss"
$targetShellNss = "$env:ProgramFiles\Nilesoft Shell\shell.nss"

# link
if (Test-Path $sourceShellNss) {
    Write-Host "Linking $targetShellNss to $sourceShellNss..."
    $linkCommandNss = "
        Remove-Item -Path '$targetShellNss' -Force -ErrorAction SilentlyContinue
        New-Item -ItemType SymbolicLink -Path '$targetShellNss' -Value '$sourceShellNss' -Force
    "
    sudo pwsh -Command $linkCommandNss
} else {
    Write-Host "Source shell.nss file '$sourceShellNss' does not exist. Skipping."
}
