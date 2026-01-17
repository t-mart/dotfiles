function Command-Exists {
    param (
        [string]$Name
    )
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}