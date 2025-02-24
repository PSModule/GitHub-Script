#Requires -Modules GitHub

[CmdletBinding()]
param()

begin {
    $scriptName = $MyInvocation.MyCommand.Name
    Write-Debug "[$scriptName] - Start"
}

process {
    try {
        $fenceTitle = 'GitHub-Script'

        Write-Debug "[$scriptName] - ShowInfo: $env:GITHUB_ACTION_INPUT_ShowInfo"
        if ($env:GITHUB_ACTION_INPUT_ShowInfo -ne 'true') {
            return
        }

        $fenceStart = "┏━━┫ $fenceTitle - Info ┣━━━━━━━━┓"
        Write-Output $fenceStart

        LogGroup ' - Installed modules' {
            Get-InstalledPSResource | Select-Object Name, Version, Prerelease | Sort-Object -Property Name | Format-Table -AutoSize
        }

        LogGroup ' - GitHub connection - Default' {
            $context = Get-GitHubContext
            $context | Format-List

            if ($context.AuthType -ne 'APP' -and [string]::IsNullOrEmpty($env:GITHUB_ACTION_INPUT_Token)) {
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
            Get-GitHubContext -ListAvailable | Format-Table
        }

        LogGroup ' - Configuration' {
            Get-GitHubConfig | Format-List
        }

        $fenceEnd = '┗' + ('━' * ($fenceStart.Length - 2)) + '┛'
        Write-Output $fenceEnd
    } catch {
        throw $_
    }
}

end {
    Write-Debug "[$scriptName] - End"
    $DebugPreference = $env:GITHUB_ACTION_INPUT_Debug -eq 'true' ? 'Continue' : 'SilentlyContinue'
    $VerbosePreference = $env:GITHUB_ACTION_INPUT_Verbose -eq 'true' ? 'Continue' : 'SilentlyContinue'
}
