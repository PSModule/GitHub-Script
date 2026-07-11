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

        $installedParams = @{
            Name        = $Name
            ErrorAction = 'SilentlyContinue'
        }
        if ($Version) {
            # Version accepts an exact version or a NuGet version range. Let PSResourceGet resolve
            # range satisfaction instead of comparing the raw value with an exact string match.
            Write-Verbose "Filtering by version: $Version"
            $installedParams['Version'] = $Version
        }
        $alreadyInstalled = Get-InstalledPSResource @installedParams

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

        # Resolve the exact installed version that satisfies the request (newest match), so the loaded
        # module is deterministic instead of whatever PowerShell would auto-load from PSModulePath.
        $resolveParams = @{
            Name        = $Name
            ErrorAction = 'SilentlyContinue'
        }
        if ($Version) {
            $resolveParams['Version'] = $Version
        }
        $resolved = Get-InstalledPSResource @resolveParams | Sort-Object Version -Descending | Select-Object -First 1
        if (-not $resolved) {
            throw "No installed '$Name' version satisfies the requested version '$Version'."
        }

        $alreadyImported = Get-Module -Name $Name
        if ($showInit) {
            Write-Output 'Already imported:'
            $alreadyImported | Format-List | Out-String
        }
        # Remove any already-loaded versions so only the chosen version remains loaded, then import that
        # exact version into the global session state so every subsequent command (info.ps1, the user
        # script, clean.ps1) uses the selected version.
        Remove-Module -Name $Name -Force -ErrorAction SilentlyContinue
        Write-Verbose "Importing module: $Name $($resolved.Version)"
        Import-Module -Name $Name -RequiredVersion $resolved.Version -Force -Global

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
