#Requires -Modules GitHub

[CmdletBinding()]
param()

begin {
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Debug "[$scriptName] - Start"
}

process {
    try {
        $fenceTitle = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Name

        Write-Debug "[$scriptName] - ShowInfo: $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowInfo"
        if ($env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowInfo -ne 'true') {
            return
        }

        $fenceStart = "┏━━┫ $fenceTitle - Info ┣━━━━━━━━┓"
        Write-Output $fenceStart

        LogGroup ' - Inputs' {
            $inputs = [ordered]@{
                Name                   = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Name
                Token                  = if ([string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_Token)) { '<not provided>' } else { '***' }
                ClientID               = if ([string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_ClientID)) { '<not provided>' } else { $env:PSMODULE_GITHUB_SCRIPT_INPUT_ClientID }
                PrivateKey             = if ([string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_PrivateKey)) { '<not provided>' } else { '***' }
                KeyVaultKeyReference   = if ([string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_KeyVaultKeyReference)) { '<not provided>' } else { $env:PSMODULE_GITHUB_SCRIPT_INPUT_KeyVaultKeyReference }
                Debug                  = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Debug
                Verbose                = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Verbose
                Version                = if ([string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_Version)) { '<not provided>' } else { $env:PSMODULE_GITHUB_SCRIPT_INPUT_Version }
                Prerelease             = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Prerelease
                ShowInfo               = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowInfo
                ShowInit               = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowInit
                ShowOutput             = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowOutput
                ErrorView              = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ErrorView
                PreserveCredentials    = $env:PSMODULE_GITHUB_SCRIPT_INPUT_PreserveCredentials
            }
            [PSCustomObject]$inputs | Format-List | Out-String
        }

        LogGroup ' - Installed modules' {
            Get-InstalledPSResource | Select-Object Name, Version, Prerelease | Sort-Object -Property Name | Format-Table -AutoSize | Out-String
        }

        LogGroup ' - GitHub connection - Default' {
            $context = Get-GitHubContext
            $context | Format-List | Out-String

            Write-Verbose "Token?    [$([string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_Token))]"
            Write-Verbose "AuthType? [$($context.AuthType)] - [$($context.AuthType -ne 'APP')]"
            Write-Verbose "gh auth?  [$($context.AuthType -ne 'APP' -and -not [string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_Token))]"

            if ($context.AuthType -ne 'APP' -and -not [string]::IsNullOrEmpty($env:PSMODULE_GITHUB_SCRIPT_INPUT_Token)) {
                Write-Output 'GitHub CLI status:'
                $before = $LASTEXITCODE
                gh auth status
                if ($LASTEXITCODE -ne $before) {
                    Write-Warning "LASTEXITCODE has changed [$LASTEXITCODE]"
                    $global:LASTEXITCODE = $before
                }
            }
        }

        LogGroup ' - GitHub connection - List' {
            Get-GitHubContext -ListAvailable | Format-Table | Out-String
        }

        LogGroup ' - Configuration' {
            Get-GitHubConfig | Format-List | Out-String
        }

        LogGroup ' - Event Information' {
            Get-GitHubEventData | Format-List | Out-String
        }

        $fenceEnd = '┗' + ('━' * ($fenceStart.Length - 2)) + '┛'
        Write-Output $fenceEnd
    } catch {
        throw $_
    }
}

end {
    Write-Debug "[$scriptName] - End"
}
