# Reload Path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$sourceShellDir = Join-Path $env:CHEZMOI_SOURCE_DIR ".data\nilesoft-shell"
$sourceShellNss = Join-Path $sourceShellDir "shell.nss"
$sourceImportsDir = Join-Path $sourceShellDir "custom-imports"

$targetShellDir = "$env:ProgramFiles\Nilesoft Shell"
$targetShellNss = Join-Path $targetShellDir "shell.nss"
$targetImportsDir = Join-Path $targetShellDir "custom-imports"

# if target doesn't exist, exit
if (-not (Test-Path $targetShellDir)) {
    Write-Host "Target directory '$targetShellDir' does not exist. Exiting."
    exit 0
}

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

# link imports
if (Test-Path $sourceImportsDir) {
    Write-Host "Linking $targetImportsDir to $sourceImportsDir..."
    $linkCommandImports = "
        New-Item -ItemType SymbolicLink -Path '$targetImportsDir' -Value '$sourceImportsDir' -Force
    "
    sudo pwsh -Command $linkCommandImports
} else {
    Write-Host "Source imports directory '$sourceImportsDir' does not exist. Skipping."
}

# sudo $shellExecutable -register