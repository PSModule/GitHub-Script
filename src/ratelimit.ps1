#Requires -Modules GitHub

# Helper script - called from info.ps1 and outputs.ps1 to display rate limit information.

if ($env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowRateLimit -ne 'true') {
    return
}

LogGroup ' - Rate Limits' {
    try {
        Get-GitHubRateLimit -ErrorAction Stop |
            Select-Object Name, Limit, Used, Remaining, ResetsAt, ResetsIn |
            Format-Table -AutoSize | Out-String
    } catch {
        Write-Warning "Could not retrieve rate limit information: $($_.Exception.Message)"
    }
}
