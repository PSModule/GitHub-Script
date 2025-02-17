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
        $showInit = $env:GITHUB_ACTION_INPUT_ShowInit -eq 'true'

        Write-Debug "[$scriptName] - ShowInit: $env:GITHUB_ACTION_INPUT_ShowInit"

        if ($showInit) {
            $fenceStart = "┏━━┫ $fenceTitle - Init ┣━━━━━━━━┓"
            Write-Output $fenceStart
            Write-Output '::group:: - Install GitHub PowerShell module'
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

        if ($showInit) {
            Write-Output 'Already installed:'
            $alreadyInstalled | Format-List
        }
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
        if ($showInit) {
            Write-Output 'Already imported:'
            $alreadyImported | Format-List
        }
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
        if ($showInit) {
            Write-Output 'Module status:'
            $moduleStatus | Format-List
            Write-Output '::endgroup::'
            Write-Output '::group:: - Connect to GitHub'
        }
        if ($providedClientID -and $providedPrivateKey) {
            Connect-GitHub -ClientID $env:GITHUB_ACTION_INPUT_ClientID -PrivateKey $env:GITHUB_ACTION_INPUT_PrivateKey -Silent:(-not $showInit)
        } elseif ($providedToken) {
            Connect-GitHub -Token $env:GITHUB_ACTION_INPUT_Token -Silent:(-not $showInit)
            $env:GITHUB_HOST_NAME = ($env:GITHUB_SERVER_URL ?? 'github.com') -replace '^https?://'
            $env:GITHUB_ACTION_INPUT_Token | gh auth login --with-token --hostname $env:GITHUB_HOST_NAME
        }
        if ($showInit) {
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
