. "${env:CHEZMOI_SOURCE_DIR}/.chezmoiscripts/windows/.common.ps1"

if (-not (Command-Exists scoop)) {
    Write-Host "scoop not found, installing..."
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

# needed for scoop buckets
if (-not (Command-Exists git)) {
    Write-Host "git not found, installing..."
    scoop install main/git
}

$currentBucketNames = @((scoop bucket list).Name)
$currentApps = scoop list | ForEach-Object { "$($_.Source)/$($_.Name)" }

$packagesToInstall = @(
    @{ Name = 'AgileBits.1Password'},
)

# $packages = @"
# {{ joinPath .chezmoi.sourceDir ".data/packages.yaml" | include | fromYaml | toPrettyJson -}}
# "@ | ConvertFrom-Json

foreach ($package in $packagesToInstall) {
  if ($null -ne $package.scoop) {
    $appName = ""
    $elevate = $false
    if ($package.scoop -is [pscustomobject]) {
      $appName = $package.scoop.app
      if (($null -ne $package.scoop.elevate) -and $package.scoop.elevate) {
        $elevate = $true
      }
    }
    else {
        $appName = $package.scoop
    }

    $appParts = $appName.Split('/')
    $bucket = $appParts[0]
    $name = $appParts[1]

    if ($currentApps -contains $appName) {
      Write-Host "Package '$appName' is already installed. Skipping." -ForegroundColor Yellow
    }
    else {
      if (-not ($currentBucketNames -contains $bucket)) {
        Write-Host "Bucket '$bucket' not found. Adding it now."
        scoop bucket add $bucket
        $currentBucketNames += $bucket
      }
      
      $installCommand = "scoop install '$appName'"
      if ($elevate) {
        $installCommand = "sudo " + $installCommand
      }
      Invoke-Expression $installCommand
    }
    Write-Host ""
  }
}

