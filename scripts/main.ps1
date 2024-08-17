[CmdletBinding()]
param()

Write-Host '::group::Install GitHub'
$params = @{
    Name            = 'GitHub'
    Repository      = 'PSGallery'
    TrustRepository = $true
    Verbose         = $true
}
Install-PSResource @params
Import-Module -Name 'GitHub' -Force -Verbose
Write-Host '::endgroup::'
