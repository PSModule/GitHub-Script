[CmdletBinding()]
param()

$params = @{
    Name            = 'GitHub'
    Repository      = 'PSGallery'
    TrustRepository = $true
    Prerelease      = $env:GITHUB_ACTION_INPUT_Prerelease -eq 'true'
}
if (-not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Version)) {
    $params['Version'] = $env:GITHUB_ACTION_INPUT_Version
}

$alreadyInstalled = Get-InstalledPSResource -Name $params['Name'] -Version $params['Version']
if (-not $alreadyInstalled) {
    Install-PSResource @params
}

$alreadyImported = Get-Module -Name $params['Name'] -Refresh
if (-not $alreadyImported) {
    Import-Module -Name $params['Name']
}
