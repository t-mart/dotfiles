# consider that this is an ordered list before modification
[string[]]$PathsToAdd = @(
    "$env:USERPROFILE\.local\bin",
    "$env:USERPROFILE\.cargo\bin",
    "$env:LOCALAPPDATA\Microsoft\WinGet\Links",
    "$env:USERPROFILE\scoop\shims",
    "$env:USERPROFILE\.local\share\pnpm",
    "$env:ProgramFiles\Docker\Docker\resources\bin",
    "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin"
)

$User = [System.EnvironmentVariableTarget]::User
$Path = [System.Environment]::GetEnvironmentVariable("Path", $User)
$PathArray = $Path -split ";"

$CombinedPaths = $PathsToAdd + $PathArray
$UniquePaths = $CombinedPaths | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

$NewPathString = $UniquePaths -join ";"
[System.Environment]::SetEnvironmentVariable("Path", $NewPathString, $User)
