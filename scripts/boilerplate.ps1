[CmdletBinding()]
param()

$scriptName = $MyInvocation.MyCommand.Name
Write-Debug "[$scriptName] - Start"

try {
    if ($env:GITHUB_ACTION_INPUT_ShowBoilerplate -ne 'true') {
        return
    }

    $title = "┏━━━━━┫ $Name ┣━━━━━┓"
    Write-Output $title

    LogGroup ' - Installed modules' {
        Get-InstalledPSResource | Select-Object Name, Version, Prerelease | Sort-Object -Property Name | Format-Table -AutoSize
    }

    LogGroup ' - GitHub connection - Default' {
        Get-GitHubContext | Format-List
    }

    LogGroup ' - GitHub connection - List' {
        Get-GitHubContext -ListAvailable | Format-Table
    }

    LogGroup ' - Configuration' {
        Get-GitHubConfig | Format-List
    }

    $endingFence = '┗' + ('━' * ($title.Length - 2)) + '┛'
    Write-Output $endingFence
} catch {
    throw $_
}

Write-Debug "[$scriptName] - End"
$DebugPreference = $env:GITHUB_ACTION_INPUT_Debug -eq 'true' ? 'Continue' : 'SilentlyContinue'
$VerbosePreference = $env:GITHUB_ACTION_INPUT_Verbose -eq 'true' ? 'Continue' : 'SilentlyContinue'
