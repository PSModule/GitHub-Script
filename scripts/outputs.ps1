[CmdletBinding()]
param()

begin {
    Write-Debug "[outputs] - Start"
}

process {
    $DebugPreference = 'SilentlyContinue'
    $VerbosePreference = 'SilentlyContinue'

    if ($env:GITHUB_ACTION_INPUT_ShowOutput -ne 'true') {
        return
    }

    $result = (Get-GitHubOutput).result
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
}

end {
    Write-Debug "[outputs] - End"
}
