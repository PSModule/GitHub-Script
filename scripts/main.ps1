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

        Write-Output '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛'

        LogGroup 'EventInfo' {
            $gitHubEventJson = Get-Content -Path $env:GITHUB_EVENT_PATH
            $gitHubEvent = $gitHubEventJson | ConvertFrom-Json

            $eventAction = $gitHubEvent.action
            $eventSender = $gitHubEvent.sender | Select-Object -Property login, type, id, node_id, html_url
            $eventEnterprise = $gitHubEvent.enterprise | Select-Object -Property name, slug, id, node_id, html_url
            $eventOrganization = $gitHubEvent.organization | Select-Object -Property login, id, node_id
            $eventOwner = $gitHubEvent.repository.owner | Select-Object -Property login, type, id, node_id, html_url
            $eventRepository = $gitHubEvent.repository | Select-Object -Property name, full_name, html_url, id, node_id, default_branch

            $gitHubEvent = $gitHubEvent | Select-Object -ExcludeProperty action, sender, enterprise, organization, repository
            $gitHubEvent | Add-Member -MemberType NoteProperty -Name Name -Value $env:GITHUB_EVENT_NAME -Force
            if ($eventAction) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Action -Value $eventAction -Force
            }
            if ($eventSender) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Sender -Value $eventSender -Force
            }
            if ($eventEnterprise) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Enterprise -Value $eventEnterprise -Force
            }
            if ($eventOrganization) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Organization -Value $eventOrganization -Force
            }
            if ($eventOwner) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Owner -Value $eventOwner -Force
            }
            if ($eventRepository) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Repository -Value $eventRepository -Force
            }
            $gitHubEvent | Format-List
        }
    } catch {
        throw $_
    }
}

end {
    Write-Debug '[main] - End'
    $DebugPreference = $env:GITHUB_ACTION_INPUT_Debug -eq 'true' ? 'Continue' : 'SilentlyContinue'
    $VerbosePreference = $env:GITHUB_ACTION_INPUT_Verbose -eq 'true' ? 'Continue' : 'SilentlyContinue'
}
