[CmdletBinding()]
param()

$DebugPreference = $env:GITHUB_ACTION_INPUT_Debug -eq 'true' ? 'Continue' : 'SilentlyContinue'
$VerbosePreference = $env:GITHUB_ACTION_INPUT_Verbose -eq 'true' ? 'Continue' : 'SilentlyContinue'

'::group::Setting up GitHub PowerShell module'
$env:PSMODULE_GITHUB_SCRIPT = $true

$Name = 'GitHub'
$Version = [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Version) ? $null : $env:GITHUB_ACTION_INPUT_Version
$Prerelease = $env:GITHUB_ACTION_INPUT_Prerelease -eq 'true'

$alreadyInstalled = Get-InstalledPSResource -Name $Name -ErrorAction SilentlyContinue
if ($Version) {
    Write-Verbose "Filtering by version: $Version"
    $alreadyInstalled = $alreadyInstalled | Where-Object Version -EQ $Version
}
if ($Prerelease) {
    Write-Verbose 'Filtering by prerelease'
    $alreadyInstalled = $alreadyInstalled | Where-Object Prerelease -EQ $Prerelease
}
Write-Verbose 'Already installed:'
Write-Verbose ($alreadyInstalled | Format-Table | Out-String)
if (-not $alreadyInstalled) {
    Write-Verbose "Installing module. Name: [$Name], Version: [$Version], Prerelease: [$Prerelease]"
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
Write-Verbose 'Already imported:'
Write-Verbose ($alreadyImported | Format-Table | Out-String)
if (-not $alreadyImported) {
    Write-Verbose "Importing module: $Name"
    Import-Module -Name $Name
}

Write-Output 'Installed modules:'
Get-InstalledPSResource | Select-Object Name, Version, Prerelease | Format-Table -AutoSize

Write-Output 'GitHub module configuration:'
Get-GitHubConfig | Select-Object Name, ID, RunEnv | Format-Table -AutoSize

'::endgroup::'

$providedToken = -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Token)
$providedClientID = -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_ClientID)
$providedPrivateKey = -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_PrivateKey)
Write-Verbose 'Provided authentication info:'
Write-Verbose "Token:      [$providedToken]"
Write-Verbose "ClientID:   [$providedClientID]"
Write-Verbose "PrivateKey: [$providedPrivateKey]"

if ($providedClientID -and $providedPrivateKey) {
    LogGroup 'Connecting using provided GitHub App' {
        Connect-GitHub -ClientID $env:GITHUB_ACTION_INPUT_ClientID -PrivateKey $env:GITHUB_ACTION_INPUT_PrivateKey -Silent
        Get-GitHubContext | Format-Table -AutoSize
    }
} elseif ($providedToken) {
    LogGroup 'Connecting using provided token' {
        Connect-GitHub -Token $env:GITHUB_ACTION_INPUT_Token -Silent
        Get-GitHubContext | Format-Table -AutoSize
    }
}
