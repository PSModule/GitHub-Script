#Requires -Modules GitHub

[CmdletBinding()]
param()

$scriptName = $MyInvocation.MyCommand.Name
Write-Debug "[$scriptName] - Start"

try {
    if ($env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowRateLimit -ne 'true') {
        return
    }

    $fenceTitle = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Name
    $label = $env:PSMODULE_GITHUB_SCRIPT_RATELIMIT_LABEL

    $fenceStart = "┏━━┫ $fenceTitle - Rate Limit ($label) ┣━━━━━━━━┓"
    Write-Output $fenceStart

    LogGroup " - Rate Limit ($label)" {
        try {
            Get-GitHubRateLimit | Format-Table -AutoSize | Out-String
        } catch {
            Write-Warning "Could not retrieve rate limit information: $($_.Exception.Message)"
        }
    }

    $fenceEnd = '┗' + ('━' * ($fenceStart.Length - 2)) + '┛'
    Write-Output $fenceEnd
} catch {
    throw $_
}

Write-Debug "[$scriptName] - End"
