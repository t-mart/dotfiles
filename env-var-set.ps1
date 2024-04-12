# Windows environment variables are "mastered" by Windows itself. While we can set
# them for a particular shell session, they will not persist, nor be accessible to
# applications that are not started from that shell session (e.g., double-clicked
# in Explorer).
#
# Therefore, it is necessary to use Windows APIs to set them permanently. One way
# to do this is with PowerShell's
# [SetEnvironmentVariable](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-powershell-1.0/ff730964(v=technet.10))
# function, which we use in this script.

$variables = @{
    # HOME isn't a standard environment variable on Windows, but it's used by
    # some tools (or me in shells), so alias from USERPROFILE
    "HOME" = "$env:USERPROFILE"

    "XDG_DATA_HOME" = "$env:USERPROFILE\.local\share"

    "XDG_CONFIG_HOME" = "$env:USERPROFILE\.config"

    "XDG_STATE_HOME" = "$env:USERPROFILE\.local\state"

    "XDG_CACHE_HOME" = "$env:USERPROFILE\.cache"
}

function SetAndLogEnvironmentVariable($name, $value) {
    [Environment]::SetEnvironmentVariable($name, $value, "User")
    $actualValue = [Environment]::GetEnvironmentVariable($name, "User")
    Write-Host "Set $name to $actualValue"
}

# it takes an abnormally long time to do this for some reason
Write-Host "Setting environment variables. This may take a few seconds..."

foreach ($variable in $variables.GetEnumerator()) {
    SetAndLogEnvironmentVariable $variable.Key $variable.Value
}

Write-Host "Done!"
