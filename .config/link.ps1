<#
.SYNOPSIS
A script to create symbolic links or directory junctions for a given list of
link-target pairs.

.DESCRIPTION
This script takes a list of link-target pairs and for each pair, creates a
symbolic link if the target is a file or a directory junction if the target is a
directory. Before creating a link, it checks if the link already exists. If the
link exists and points to the correct target, it skips without warning. If the
link exists but doesn't point to the correct target, it emits a warning. Also,
it ensures that the parent directory for the link exists. If not, it creates the
parent directory.
#>

# Define list of tuples (Link - Target)
# Target = path to which link refers (file/dir that already exists)
# Link = path to new link
$linksTargets = @(
    @{ 'Link' = '%USERPROFILE%\Documents\PowerShell'; 'Target' = '%USERPROFILE%\.config\powershell\' },
    @{ 'Link' = '%APPDATA%\streamlink'; 'Target' = '%USERPROFILE%\.config\streamlink\' },
    @{ 'Link' = '%APPDATA%\yt-dlp'; 'Target' = '%USERPROFILE%\.config\yt-dlp\' },
    @{ 'Link' = '%APPDATA%\beets'; 'Target' = '%USERPROFILE%\.config\beets\' },
    @{ 'Link' = '%APPDATA%\nushell'; 'Target' = '%USERPROFILE%\.config\nushell\' },
    @{ 'Link' = '%USERPROFILE%\.aria2'; 'Target' = '%USERPROFILE%\.config\aria2\' }
    @{ 'Link' = '%USERPROFILE%\scoop\persist\mpv.net\portable_config'; 'Target' = '%USERPROFILE%\.config\mpv.net\' }
    @{ 'Link' = '%APPDATA%\JPEGView\'; 'Target' = '%USERPROFILE%\.config\jpegview\' }
    @{ 'Link' = '%USERPROFILE%\Documents\My Games\Path of Exile\production_Config.ini'; 'Target' = '%USERPROFILE%\.config\Path of Exile\production_Config.ini' }
)

# Iterate through each link-target pair
foreach ($lt in $linksTargets) {
    $link = [Environment]::ExpandEnvironmentVariables($lt.Link)
    $target = [Environment]::ExpandEnvironmentVariables($lt.Target)

    # Check if link already exists
    if (Test-Path -Path $link) {
        # Check if link is a symbolic link (or junction) that points to the target
        $existingLink = Get-Item -Path $link
        if (!($existingLink.Attributes -band [IO.FileAttributes]::ReparsePoint) -or !((Get-ItemProperty -Path $link).Target -eq $target)) {
            Write-Warning "Link $link already exists and is not a link to $target."
        } else {
            Write-Host "Link $link already points to target $target."
        }
        continue
    }

    # Check if parent directory for link exists, if not, create it
    $linkParent = Split-Path -Path $link -Parent
    if (!(Test-Path -Path $linkParent)) {
        New-Item -ItemType Directory -Force -Path $linkParent
    }

    # Check if target is a directory or a file, and create the corresponding symbolic link
    if (Test-Path -Path $target -PathType Container) {
        # Target is a directory, create a directory junction
        cmd /c mklink /J $link $target
    }
    elseif (Test-Path -Path $target) {
        # Target is a file, create a symbolic link
        cmd /c mklink $link $target
    }
    else {
        # Target does not exist, print a warning
        Write-Warning "Target $target does not exist, no link created."
    }
}
