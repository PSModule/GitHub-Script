[CmdletBinding()]
param(
    [Parameter()]
    [string] $Version,

    [Parameter()]
    [bool] $Prerelease
)

$params = @{
    Name            = 'GitHub'
    Repository      = 'PSGallery'
    TrustRepository = $true
    Version         = $Version
    Prerelease      = $Prerelease
}
Install-PSResource @params
Import-Module -Name 'GitHub' -Force
