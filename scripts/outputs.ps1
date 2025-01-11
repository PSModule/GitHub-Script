[CmdletBinding()]
param()

begin {
    Write-Debug '[outputs] - Start'
}

process {
    try {
        $DebugPreference = 'SilentlyContinue'
        $VerbosePreference = 'SilentlyContinue'

        Write-Debug "[outputs] - ShowOutput: $env:GITHUB_ACTION_INPUT_ShowOutput"
        if ($env:GITHUB_ACTION_INPUT_ShowOutput -ne 'true') {
            return
        }

        $result = (Get-GitHubOutput).result
        Write-Debug "[outputs] - Result: $(-not $result)"
        if (-not $result) {
            return
        }
        Write-Host '┏━━━━━┫ GitHub-Script ┣━━━━━┓'
        LogGroup ' - Outputs' {
            if ([string]::IsNullOrEmpty($env:GITHUB_ACTION)) {
                Write-GitHubWarning 'Outputs cannot be accessed as the step has no ID.'
            }

            if (-not (Test-Path -Path $env:GITHUB_OUTPUT)) {
                Write-Warning "File not found: $env:GITHUB_OUTPUT"
            }

            $result | Format-List
            Write-Host "Access outputs using `${{ fromJson(steps.$env:GITHUB_ACTION.outputs.result).<output-name> }}"
        }
        Write-Host '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛'
    } catch {
        throw $_
    }
}

end {
    Write-Debug '[outputs] - End'
}
