$outputs = Get-GitHubOutput
$env:PSMODULE_GITHUB_SCRIPT = $false
Set-GitHubOutput -Name 'result' -Value $outputs.result
