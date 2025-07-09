# Permenantly set some environment variables on Windows.
#
# We do this this so that we have a common way to reference directories across
# different systems.

$variables = @{
    # HOME isn't a standard environment variable on Windows, but it's used by
    # some tools (or by me in shells), so alias from USERPROFILE
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

foreach ($name in $variables.Keys) {
    SetAndLogEnvironmentVariable $name $variables[$name]
}

Write-Host "Done!"
