#Requires -Modules GitHub

LogGroup ' - Event Info' {
    Get-GithubEventData | Format-List
}

LogGroup ' - Runner Info' {
    Get-GithubRunnerData | Format-List
}
