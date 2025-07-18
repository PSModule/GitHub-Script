[CmdletBinding()]
param()

begin {
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Debug "[$scriptName] - Start"
}

process {
    try {
        $env:PSMODULE_GITHUB_SCRIPT = $true
        $fenceTitle = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Name
        $showInit = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowInit -eq 'true'

        Write-Debug "[$scriptName] - ShowInit: $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowInit"

        if ($showInit) {
            $fenceStart = "┏━━┫ $fenceTitle - Init ┣━━━━━━━━┓"
            Write-Output $fenceStart
            Write-Output '::group:: - Install GitHub PowerShell module'
        }
        $Name = 'GitHub'
        $Version = [string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_Version) ? $null : $env:PSMODULE_GITHUB_SCRIPT_INPUT_Version
        $Prerelease = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Prerelease -eq 'true'

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
            $alreadyInstalled | Format-List | Out-String
        }
        if (-not $alreadyInstalled) {
            $params = @{
                Name            = $Name
                Repository      = 'PSGallery'
                TrustRepository = $true
                Prerelease      = $Prerelease
                Reinstall       = $true
                WarningAction   = 'SilentlyContinue'
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
            $alreadyImported | Format-List | Out-String
        }
        if (-not $alreadyImported) {
            Write-Verbose "Importing module: $Name"
            Import-Module -Name $Name
        }

        $providedToken = -not [string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_Token)
        $providedClientID = -not [string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_ClientID)
        $providedPrivateKey = -not [string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_PrivateKey)
        $providedKeyVaultKeyReference = -not [string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_KeyVaultKeyReference)

        # Validate mutual exclusion of PrivateKey and KeyVaultKeyReference
        if ($providedPrivateKey -and $providedKeyVaultKeyReference) {
            throw 'Only one of PrivateKey or KeyVaultKeyReference can be provided.'
        }

        # Validate that if ClientID is provided, exactly one of PrivateKey or KeyVaultKeyReference is also provided
        if ($providedClientID -and -not ($providedPrivateKey -or $providedKeyVaultKeyReference)) {
            throw 'When ClientID is provided, either PrivateKey or KeyVaultKeyReference must also be provided.'
        }

        $moduleStatus = [pscustomobject]@{
            Name                            = $Name
            Version                         = [string]::IsNullOrEmpty($Version) ? 'latest' : $Version
            Prerelease                      = $Prerelease
            'Already installed'             = $null -ne $alreadyInstalled
            'Already imported'              = $null -ne $alreadyImported
            'Provided Token'                = $providedToken
            'Provided ClientID'             = $providedClientID
            'Provided PrivateKey'           = $providedPrivateKey
            'Provided KeyVaultKeyReference' = $providedKeyVaultKeyReference
        }
        if ($showInit) {
            Write-Output 'Module status:'
            $moduleStatus | Format-List | Out-String
            Write-Output '::endgroup::'
            Write-Output '::group:: - Connect to GitHub'
        }
        if ($providedClientID -and $providedPrivateKey) {
            $params = @{
                ClientID   = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ClientID
                PrivateKey = $env:PSMODULE_GITHUB_SCRIPT_INPUT_PrivateKey
                Silent     = (-not $showInit)
            }
            Connect-GitHub @params
        } elseif ($providedClientID -and $providedKeyVaultKeyReference) {
            $params = @{
                ClientID             = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ClientID
                KeyVaultKeyReference = $env:PSMODULE_GITHUB_SCRIPT_INPUT_KeyVaultKeyReference
                Silent               = (-not $showInit)
            }
            Connect-GitHub @params
        } elseif ($providedToken) {
            $params = @{
                Token  = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Token
                Silent = (-not $showInit)
            }
            Connect-GitHub @params
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
