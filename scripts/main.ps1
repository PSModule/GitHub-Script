[CmdletBinding()]
param()

begin {
    Write-Debug '[main] - Start'
}

process {
    try {
        $env:PSMODULE_GITHUB_SCRIPT = $true
        Write-Output '┏━━━━━┫ GitHub-Script ┣━━━━━┓'
        Write-Output '::group:: - Setup GitHub PowerShell'

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
        Write-Output '::endgroup::'

        LogGroup ' - Installed modules' {
            Get-InstalledPSResource | Select-Object Name, Version, Prerelease | Sort-Object -Property Name | Format-Table -AutoSize
        }

        LogGroup ' - GitHub connection' {
            if ($providedClientID -and $providedPrivateKey) {
                Connect-GitHub -ClientID $env:GITHUB_ACTION_INPUT_ClientID -PrivateKey $env:GITHUB_ACTION_INPUT_PrivateKey -Silent -PassThru |
                    Select-Object * | Format-List
            } elseif ($providedToken) {
                Connect-GitHub -Token $env:GITHUB_ACTION_INPUT_Token -Silent -PassThru |
                    Select-Object * | Format-List
            } else {
                Write-Output 'No connection provided'
            }
        }

        LogGroup ' - Configuration' {
            Get-GitHubConfig | Format-List
        }

        LogGroup ' - Event Info' {
            Get-GithubEventData | Format-List
        }

        LogGroup ' - Runner Info' {
            [pscustomobject]@{
                Name        = $env:RUNNER_NAME
                OS          = $env:RUNNER_OS
                Arch        = $env:RUNNER_ARCH
                Environment = $env:RUNNER_ENVIRONMENT
                Temp        = $env:RUNNER_TEMP
                Perflog     = $env:RUNNER_PERFLOG
                ToolCache   = $env:RUNNER_TOOL_CACHE
                TrackingID  = $env:RUNNER_TRACKING_ID
                Workspace   = $env:RUNNER_WORKSPACE
                Processors  = [System.Environment]::ProcessorCount
            } | Format-List
            Get-Content -Path $env:GITHUB_STATE
        }

        LogGroup ' - Environment Variables' {
            $props = @{}

            Get-ChildItem Env: | Where-Object { $_.Name -like 'RUNNER_*' } | ForEach-Object {
                $props[$_.Name] = $_.Value
            }

            $customObject = [PSCustomObject]$props

            $customObject | Format-List
        }


        Write-Output '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛'

    } catch {
        throw $_
    }
}

end {
    Write-Debug '[main] - End'
    $DebugPreference = $env:GITHUB_ACTION_INPUT_Debug -eq 'true' ? 'Continue' : 'SilentlyContinue'
    $VerbosePreference = $env:GITHUB_ACTION_INPUT_Verbose -eq 'true' ? 'Continue' : 'SilentlyContinue'
}
