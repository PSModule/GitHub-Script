[CmdletBinding()]
param()

$rawUI = $Host.UI.RawUI
$rawUI

$env:PSMODULE_GITHUB_SCRIPT = $true
Write-Host "┏━━━━━┫ GitHub-Script ┣━━━━━┓"
Write-Host '::group:: - Setup GitHub PowerShell'

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
$alreadyInstalled | Format-Table
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
Write-Verbose 'Already imported:'
$alreadyImported | Format-Table
if (-not $alreadyImported) {
    Write-Verbose "Importing module: $Name"
    Import-Module -Name $Name
}

$providedToken = -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Token)
$providedClientID = -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_ClientID)
$providedPrivateKey = -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_PrivateKey)
[pscustomobject]@{
    Name                  = $Name
    Version               = [string]::IsNullOrEmpty($Version) ? 'latest' : $Version
    Prerelease            = $Prerelease
    'Already installed'   = $null -ne $alreadyInstalled
    'Already imported'    = $null -ne $alreadyImported
    'Provided Token'      = $providedToken
    'Provided ClientID'   = $providedClientID
    'Provided PrivateKey' = $providedPrivateKey
} | Format-List
Write-Host '::endgroup::'

LogGroup ' - Installed modules' {
    Get-InstalledPSResource | Select-Object Name, Version, Prerelease | Sort-Object -Property Name | Format-Table -AutoSize
}

LogGroup ' - GitHub connection' {
    if ($providedClientID -and $providedPrivateKey) {
        Write-Verbose 'Connected using provided GitHub App'
        Connect-GitHub -ClientID $env:GITHUB_ACTION_INPUT_ClientID -PrivateKey $env:GITHUB_ACTION_INPUT_PrivateKey -Silent
    } elseif ($providedToken) {
        Write-Verbose 'Connected using provided token'
        Connect-GitHub -Token $env:GITHUB_ACTION_INPUT_Token -Silent
    }
    Get-GitHubContext | Format-List
}

LogGroup ' - Configuration' {
    Get-GitHubConfig | Format-List
}

Write-Host '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛'

$DebugPreference = $env:GITHUB_ACTION_INPUT_Debug -eq 'true' ? 'Continue' : 'SilentlyContinue'
$VerbosePreference = $env:GITHUB_ACTION_INPUT_Verbose -eq 'true' ? 'Continue' : 'SilentlyContinue'
