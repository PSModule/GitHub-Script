[CmdletBinding()]
param()

$Name = 'GitHub'
$Version = [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Version) ? $null : $env:GITHUB_ACTION_INPUT_Version
$Prerelease = $env:GITHUB_ACTION_INPUT_Prerelease -eq 'true'

$alreadyInstalled = Get-InstalledPSResource -Name $Name -ErrorAction SilentlyContinue
if ($Version) {
    Write-Verbose "Filtering by version: $Version"
    $alreadyInstalled = $alreadyInstalled | Where-Object Version -EQ $Version
}
if ($Prerelease) {
    Write-Verbose "Filtering by prerelease"
    $alreadyInstalled = $alreadyInstalled | Where-Object Prerelease -EQ $Prerelease
}
Write-Verbose "Filtered modules:"
Write-Verbose ($alreadyInstalled | Format-Table | Out-String)
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
