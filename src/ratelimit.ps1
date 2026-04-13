#Requires -Modules GitHub

# Helper script - called from info.ps1 and outputs.ps1 to display rate limit information.
# Expects $env:PSMODULE_GITHUB_SCRIPT_RATELIMIT_LABEL to be set to 'Pre' or 'Post'.

if ($env:PSMODULE_GITHUB_SCRIPT_INPUT_ShowRateLimit -ne 'true') {
    return
}

$label = $env:PSMODULE_GITHUB_SCRIPT_RATELIMIT_LABEL

LogGroup " - Rate Limit ($label)" {
    try {
        Get-GitHubRateLimit | Format-Table -AutoSize | Out-String
    } catch {
        Write-Warning "Could not retrieve rate limit information: $($_.Exception.Message)"
    }
}
