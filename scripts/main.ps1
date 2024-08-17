[CmdletBinding()]
param()

$params = @{
    Name            = 'GitHub'
    Repository      = 'PSGallery'
    TrustRepository = $true
}
Install-PSResource @params
Import-Module -Name 'GitHub' -Force
