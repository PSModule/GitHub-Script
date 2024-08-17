[CmdletBinding()]
param()
try {
    $params = @{
        Name            = 'GitHub'
        Repository      = 'PSGallery'
        TrustRepository = $true
        Version         = $env:GITHUB_ACTION_INPUT_Version ? $env:GITHUB_ACTION_INPUT_Version : $null
        Prerelease      = $env:GITHUB_ACTION_INPUT_Prerelease -eq 'true'
    }
    Install-PSResource @params
    Import-Module -Name 'GitHub' -Force
} catch {
    Write-Error $_
    exit 1
}
