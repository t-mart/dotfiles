# Reload Path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

$scoopExecutable = Join-Path $env:USERPROFILE scoop\shims\scoop.ps1

# git is needed for scoop buckets
& $scoopExecutable install git

& $scoopExecutable bucket add extras
& $scoopExecutable bucket add nerd-fonts
& $scoopExecutable bucket add versions
