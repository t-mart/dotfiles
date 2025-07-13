# 1. EDIT THIS LIST ✏️
#    Add the full paths you want to prepend to your user PATH variable.
#    Using $env:USERPROFILE is a good practice for paths in your user directory.
[string[]]$PathsToAdd = @(
    "$env:USERPROFILE\.local\bin",
    "$env:USERPROFILE\.cargo\bin",
    "$env:USERPROFILE\scoop\shims",
    "$env:ProgramFiles\Docker\Docker\resources\bin",
    "$env:USERPROFILE\scoop\apps\nodejs\current",
    "$env:USERPROFILE\.local\share\pnpm",
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code Insiders\bin",
    "$env:LOCALAPPDATA\Microsoft\WinGet\Links",
)

$User = [System.EnvironmentVariableTarget]::User
$Path = [System.Environment]::GetEnvironmentVariable("Path", $User)
$PathArray = $Path -split ";"

$CombinedPaths = $PathsToAdd + $PathArray
$UniquePaths = $CombinedPaths | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

$NewPathString = $UniquePaths -join ";"
[System.Environment]::SetEnvironmentVariable("Path", $NewPathString, $User)
