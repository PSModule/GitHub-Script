[CmdletBinding()]
param()

$DebugPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'

Write-Host '┏━━━━━┫ GitHub-Script ┣━━━━━┓'

LogGroup ' - Outputs' {
    if ([string]::IsNullOrEmpty($env:GITHUB_ACTION)) {
        Write-Warning 'Outputs cannot be accessed as the step has no ID.'
    }

    if (-not (Test-Path -Path $env:GITHUB_OUTPUT)) {
        Write-Warning "File not found: $env:GITHUB_OUTPUT"
    }

    (Get-GitHubOutput).result | Format-List
    Write-Host "Access outputs using `${{ fromJson(steps.$env:GITHUB_ACTION.outputs.result).<output-name> }}"
}

Write-Host '┗━━━━━━━━━━━━━━━━━━━━━━━━━━━┛'
