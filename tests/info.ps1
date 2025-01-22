#Requires -Modules GitHub

LogGroup ' - Get-GithubEventData' {
    Get-GithubEventData | Format-List
}

LogGroup ' - Get-GithubRunnerData' {
    Get-GithubRunnerData | Format-List
}
