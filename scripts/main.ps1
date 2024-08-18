[CmdletBinding()]
param()

$Name = 'GitHub'
$Version = [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Version) ? $null : $env:GITHUB_ACTION_INPUT_Version
$Prerelease = $env:GITHUB_ACTION_INPUT_Prerelease -eq 'true'

$installedModules = Get-InstalledPSResource -ErrorAction SilentlyContinue
Write-Verbose "Installed modules:"
Write-Verbose ($installedModules | Out-String)
$alreadyInstalled = $installedModules | Where-Object Name -EQ $Name
if ($Version) {
    $alreadyInstalled = $alreadyInstalled | Where-Object Version -EQ $Version
}
if ($Prerelease) {
    $alreadyInstalled = $alreadyInstalled | Where-Object Prerelease -EQ $Prerelease
}
if (-not $alreadyInstalled) {
    $params = @{
        Name            = $Name
        Repository      = 'PSGallery'
        TrustRepository = $true
        Prerelease      = $Prerelease
    }
    if ($Version) {
        $params['Version'] = $Version
    }
    Install-PSResource @params
}

$alreadyImported = Get-Module -Name $Name
if (-not $alreadyImported) {
    Import-Module -Name $Name
}
