[CmdletBinding()]
param()

if ($env:GITHUB_ACTION_INPUT_Debug -eq 'true') {
    $DebugPreference = 'Continue'
}
if ($env:GITHUB_ACTION_INPUT_Verbose -eq 'true') {
    $VerbosePreference = 'Continue'
}

'::group::Setting up GitHub PowerShell module'

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
'::endgroup::'


if (-not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_ClientID) -and -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_PrivateKey)) {
    LogGroup 'Connect-Github - GitHub App' {
        Connect-Github -ClientID $env:GITHUB_ACTION_INPUT_ClientID -PrivateKey $env:GITHUB_ACTION_INPUT_PrivateKey
    }
} elseif (-not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Token)) {
    LogGroup 'Connect-Github - Token' {
        Connect-Github -Token $env:GITHUB_ACTION_INPUT_Token
    }
}
