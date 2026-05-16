#Requires -Modules GitHub

[CmdletBinding()]
param()

$scriptName = $MyInvocation.MyCommand.Name
Write-Debug "[$scriptName] - Start"

try {
    $fenceTitle = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Name

    $showOutput = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowOutput -eq 'true'
    $showRateLimit = $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowRateLimit -eq 'true'

    Write-Debug "[$scriptName] - ShowOutput: $showOutput"
    Write-Debug "[$scriptName] - ShowRateLimit: $showRateLimit"

    $result = $null
    $hasResult = $false
    if ($showOutput) {
        $result = (Get-GitHubOutput).result
        $hasResult = [bool]$result
        Write-Debug "[$scriptName] - ResultPresent: $hasResult"
    }

    if (-not $hasResult -and -not $showRateLimit) {
        return
    }

    $fenceStart = "┏━━┫ $fenceTitle - Outputs ┣━━━━━┓"
    Write-Output $fenceStart

    if ($hasResult) {
        if ([string]::IsNullOrEmpty($env:GITHUB_ACTION)) {
            Write-GitHubWarning 'Outputs cannot be accessed as the step has no ID.'
        }

        if (-not (Test-Path -Path $env:GITHUB_OUTPUT)) {
            Write-Warning "File not found: $env:GITHUB_OUTPUT"
        }

        foreach ($output in $result.PSObject.Properties) {
            $blue = $PSStyle.Foreground.Blue
            $reset = $PSStyle.Reset
            LogGroup " - $blue$($output.Name)$reset" {
                $output.Value | Format-List | Out-String
            }
        }
    } # end if ($result)

    & "$PSScriptRoot/ratelimit.ps1"

    $fenceEnd = '┗' + ('━' * ($fenceStart.Length - 2)) + '┛'
    Write-Output $fenceEnd
} catch {
    throw $_
}

Write-Debug "$scriptName - End"
