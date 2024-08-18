[CmdletBinding()]
param()

$params = @{
    Name = 'GitHub'
}
if (-not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Version)) {
    $params['Version'] = $env:GITHUB_ACTION_INPUT_Version
}

$installParams = @{
    Repository      = 'PSGallery'
    TrustRepository = $true
    Prerelease      = $env:GITHUB_ACTION_INPUT_Prerelease -eq 'true'
}

$alreadyInstalled = Get-InstalledPSResource @params
if (-not $alreadyInstalled) {
    Install-PSResource @installParams
}

$alreadyImported = Get-Module -Name $params['Name'] -Refresh
if (-not $alreadyImported) {
    Import-Module -Name $params['Name']
}
