#Requires -Modules GitHub

[CmdletBinding()]
param()

$DebugPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$scriptName = $MyInvocation.MyCommand.Name
Write-Debug "[$scriptName] - Start"

try {
    $fenceTitle = 'GitHub-Script'

    Write-Debug "[$scriptName] - ShowOutput: $env:GITHUB_ACTION_INPUT_ShowOutput"
    if ($env:GITHUB_ACTION_INPUT_ShowOutput -ne 'true') {
        return
    }

    $result = (Get-GitHubOutput).result
    Write-Debug "[$scriptName] - Result: $(-not $result)"
    if (-not $result) {
        return
    }
    $fenceStart = "┏━━┫ $fenceTitle - Outputs ┣━━━━━┓"
    Write-Output $fenceStart
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
    $fenceEnd = '┗' + ('━' * ($fenceStart.Length - 2)) + '┛'
    Write-Output $fenceEnd
} catch {
    throw $_
}

Write-Debug "$scriptName - End"
