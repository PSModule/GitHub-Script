#Requires -Modules GitHub

LogGroup ' - Get-GithubEventData' {
    Get-GitHubEventData | Format-List
}

LogGroup ' - Get-GithubRunnerData' {
    Get-GitHubRunnerData | Format-List
}
