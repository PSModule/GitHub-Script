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
Install-PSResource @params
Import-Module -Name 'GitHub' -Force
