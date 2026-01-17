# Reload Path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$configFile = $env:CHEZMOI_CONFIG_FILE
$configDir = Split-Path -Parent -Path $configFile

$decryptedKeyFile = Join-Path $configDir "key.txt"

$sourceDir = $env:CHEZMOI_SOURCE_DIR
$encryptedKeyFile = Join-Path $sourceDir ".data\key.txt.age"

if (Test-Path $decryptedKeyFile) {
    Write-Host "Key file '$decryptedKeyFile' already exists. Skipping."
} else {
    # Reload the PATH variable
    $env:Path = @(
        [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
        [System.Environment]::GetEnvironmentVariable('Path', 'User')
    ) -join ';'

    # Create the configuration directory if it doesn't exist
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null

    Write-Host "Decrypting private age key to '$decryptedKeyFile'..."

    chezmoi age decrypt --output $decryptedKeyFile --passphrase $encryptedKeyFile

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to decrypt the key file."
    }

    # Set permissions
    $user = "$env:USERDOMAIN\$env:USERNAME"
    icacls $decryptedKeyFile /inheritance:r /grant:r "${user}:(R,W)"
    Write-Host "Successfully decrypted and secured '$decryptedKeyFile'."
}
