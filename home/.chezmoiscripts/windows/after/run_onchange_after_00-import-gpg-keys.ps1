& ${env:CHEZMOI_EXECUTABLE} decrypt "${env:CHEZMOI_WORKING_TREE}/data/gpg-keys.txt.age" | gpg --import --batch --yes
Write-Host "Successfully imported GPG keys using the default gpg command."
