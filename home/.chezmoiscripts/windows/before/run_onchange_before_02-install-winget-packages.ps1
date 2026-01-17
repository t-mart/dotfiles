# update winget itself
winget upgrade --id Microsoft.AppInstaller --exact --accept-source-agreements --accept-package-agreements

# Create a temporary file to store the export data.
$TempFilePath = (New-TemporaryFile).FullName

# export the list of installed winget packages to the temporary file
# this command requires writing to a file (yuck)
winget export --output $TempFilePath --source winget --ignore-warnings

# Read the JSON file and extract all PackageIdentifier properties.
$installedData = Get-Content -Path $TempFilePath | ConvertFrom-Json
Remove-Item -Path $TempFilePath
$installedPackageIds = [System.Collections.Generic.HashSet[string]]::new()

# The JSON has structure: Sources -> Packages -> PackageIdentifier
if ($installedData.Sources) {
    foreach ($source in $installedData.Sources) {
        foreach ($package in $source.Packages) {
            [void]$installedPackageIds.Add($package.PackageIdentifier)
        }
    }
}

$packagesToInstall = @(
    @{ Id = 'AgileBits.1Password'},
    @{ Id = 'Oven-sh.Bun'},
    @{ Id = 'DenoLand.Deno'},
    @{ Id = 'Docker.DockerDesktop'},
    @{ Id = 'Mozilla.Firefox'},
    @{ Id = 'GoLang.Go'},
    @{
        Id = 'Microsoft.VisualStudio.2022.BuildTools'
        Override = '--add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.26100 --wait --norestart --passive --nocache'
    },
    @{ Id = 'Microsoft.DotNet.DesktopRuntime.3_1'},
    @{ Id = 'Microsoft.DotNet.DesktopRuntime.5'},
    @{ Id = 'Microsoft.DotNet.DesktopRuntime.6'},
    @{ Id = 'Microsoft.DotNet.DesktopRuntime.7'},
    @{ Id = 'Microsoft.DotNet.DesktopRuntime.8'},
    @{ Id = 'Microsoft.DotNet.DesktopRuntime.9'},
    @{ Id = 'Microsoft.DotNet.DesktopRuntime.10'},
    @{ Id = 'OpenJS.NodeJS'},
    @{ Id = 'JanDeDobbeleer.OhMyPosh'},
    @{ Id = 'pnpm.pnpm'},
    @{ Id = 'Rustlang.Rustup'},
    @{ Id = 'OpenWhisperSystems.Signal'},
    @{ Id = 'Valve.Steam'},
    @{ Id = 'Microsoft.VCRedist.2005.x64'},
    @{ Id = 'Microsoft.VCRedist.2008.x64'},
    @{ Id = 'Microsoft.VCRedist.2010.x64'},
    @{ Id = 'Microsoft.VCRedist.2012.x64'},
    @{ Id = 'Microsoft.VCRedist.2013.x64'},
    @{ Id = 'Microsoft.VCRedist.2015+.x64'},
    @{ Id = 'Microsoft.VisualStudioCode'}
)

foreach ($package in $packagesToInstall) {
    $id = $package.Id
    $override = if ($package.ContainsKey('Override')) { $package.Override } else { '' }

    # Create the base arguments list
    $argsList = @("install", "--id", $id, "--exact", "--accept-package-agreements", "--accept-source-agreements")
    
    # Add override arguments if they exist
    if ($package.ContainsKey('Override') -and $package.Override) {
        # Split by space so winget sees them as separate flags
        $argsList += $package.Override.Split(' ') 
    }

    if (-not $installedPackageIds.Contains($id)) {
        Write-Host "Installing winget package '$id'..."
        winget @argsList
    }
    Write-Host ""
}