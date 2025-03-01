#Requires -Modules GitHub

LogGroup ' - Get-GithubEventData' {
    Get-GitHubEventData | Format-List | Out-String
}

LogGroup ' - Get-GithubRunnerData' {
    Get-GitHubRunnerData | Format-List | Out-String
}
