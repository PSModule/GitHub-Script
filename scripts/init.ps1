[CmdletBinding()]
param()

begin {
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Debug "[$scriptName] - Start"
}

process {
    try {
        $env:PSMODULE_GITHUB_SCRIPT = $true
        $fenceTitle = 'GitHub-Script'

        Write-Debug "[$scriptName] - ShowInit: $env:GITHUB_ACTION_INPUT_ShowInit"
        if ($env:GITHUB_ACTION_INPUT_ShowInit -ne 'true') {
        }

        if ($VerbosePreference -eq 'Continue') {
            $fenceStart = "┏━━┫ $fenceTitle - Init ┣━━━━━━━━┓"
            Write-Output $fenceStart
            Write-Output '::group:: - SetupGitHub PowerShell module'
        }
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
        Write-Verbose "$($alreadyInstalled | Format-List)"
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
            $Count = 5
            $Delay = 10
            for ($i = 1; $i -le $Count; $i++) {
                try {
                    Install-PSResource @params -ErrorAction Stop
                    break
                } catch {
                    Write-Warning $_.Exception.Message
                    if ($i -eq $Count) {
                        throw $_
                    }
                    Start-Sleep -Seconds $Delay
                }
            }
        }

        $alreadyImported = Get-Module -Name $Name
        Write-Verbose 'Already imported:'
        Write-Verbose "$($alreadyImported | Format-Table)"
        if (-not $alreadyImported) {
            Write-Verbose "Importing module: $Name"
            Import-Module -Name $Name
        }

        $providedToken = -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Token)
        $providedClientID = -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_ClientID)
        $providedPrivateKey = -not [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_PrivateKey)
        $moduleStatus = [pscustomobject]@{
            Name                  = $Name
            Version               = [string]::IsNullOrEmpty($Version) ? 'latest' : $Version
            Prerelease            = $Prerelease
            'Already installed'   = $null -ne $alreadyInstalled
            'Already imported'    = $null -ne $alreadyImported
            'Provided Token'      = $providedToken
            'Provided ClientID'   = $providedClientID
            'Provided PrivateKey' = $providedPrivateKey
        }
        Write-Verbose "$($moduleStatus | Format-List)"
        if ($VerbosePreference -eq 'Continue') {
            Write-Output '::endgroup::'
            Write-Output '::group:: - GitHub connection'
        }
        if ($providedClientID -and $providedPrivateKey) {
            Connect-GitHub -ClientID $env:GITHUB_ACTION_INPUT_ClientID -PrivateKey $env:GITHUB_ACTION_INPUT_PrivateKey -Silent
        } elseif ($providedToken) {
            Connect-GitHub -Token $env:GITHUB_ACTION_INPUT_Token -Silent
        }
        if ($VerbosePreference -eq 'Continue') {
            Write-Output '::endgroup::'
            $fenceEnd = '┗' + ('━' * ($fenceStart.Length - 2)) + '┛'
            Write-Output $fenceEnd
        }
    } catch {
        throw $_
    }
}

end {
    Write-Debug "[$scriptName] - End"
}
