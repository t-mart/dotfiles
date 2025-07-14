[string[]]$PathsToAdd = @(
    "$env:USERPROFILE\.local\bin",
    "$env:USERPROFILE\.cargo\bin",
    "$env:USERPROFILE\scoop\shims",
    "$env:USERPROFILE\.local\share\pnpm",
    "$env:ProgramFiles\Docker\Docker\resources\bin",
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin",
    "$env:LOCALAPPDATA\Microsoft\WinGet\Links"
)

$User = [System.EnvironmentVariableTarget]::User
$Path = [System.Environment]::GetEnvironmentVariable("Path", $User)
$PathArray = $Path -split ";"

$CombinedPaths = $PathsToAdd + $PathArray
$UniquePaths = $CombinedPaths | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

$NewPathString = $UniquePaths -join ";"
[System.Environment]::SetEnvironmentVariable("Path", $NewPathString, $User)
