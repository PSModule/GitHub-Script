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

        $showInfo = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowInfo -eq 'true'
        $showRateLimit = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowRateLimit -eq 'true'

        Write-Debug "[$scriptName] - ShowInfo: $showInfo"
        Write-Debug "[$scriptName] - ShowRateLimit: $showRateLimit"
        if (-not $showInfo -and -not $showRateLimit) {
            return
        }

        $fenceStart = "┏━━┫ $fenceTitle - Info ┣━━━━━━━━┓"
        Write-Output $fenceStart

        if ($showInfo) {
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
        } # end if ($showInfo)

        $env:PSMODULE_GITHUB_SCRIPT_RATELIMIT_LABEL = 'Pre'
        & "$PSScriptRoot/ratelimit.ps1"

        $fenceEnd = '┗' + ('━' * ($fenceStart.Length - 2)) + '┛'
        Write-Output $fenceEnd
    } catch {
        throw $_
    }
}

end {
    Write-Debug "[$scriptName] - End"
}
