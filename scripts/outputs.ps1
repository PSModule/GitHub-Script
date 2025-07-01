#Requires -Modules GitHub

[CmdletBinding()]
param()

$scriptName = $MyInvocation.MyCommand.Name
Write-Debug "[$scriptName] - Start"

try {
    $fenceTitle = $env:PSMODULE_GITHUB_SCRIPT_INPUT_Name

    Write-Debug "[$scriptName] - ShowOutput: $env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowOutput"
    if ($env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowOutput -ne 'true') {
        return
    }

    $result = (Get-GitHubOutput).result
    Write-Debug "[$scriptName] - Result: $(-not $result)"
    if (-not $result) {
        return
    }
    $fenceStart = "┏━━┫ $fenceTitle - Outputs ┣━━━━━┓"
    Write-Output $fenceStart
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
            $outputAccess = "Accessible via: [$blue`${{ fromJson(steps.$env:GITHUB_ACTION.outputs.result).$($output.Name) }}$reset]"
            $outputFence = ('─' * ($outputAccess.Length - 9))
            Write-Output $outputAccess
            Write-Output $outputFence
            $output.Value | Format-List | Out-String
        }
    }
    $fenceEnd = '┗' + ('━' * ($fenceStart.Length - 2)) + '┛'
    Write-Output $fenceEnd
} catch {
    throw $_
}

Write-Debug "$scriptName - End"
