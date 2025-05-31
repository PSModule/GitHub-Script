Write-Debug "Cleaning up..."
Write-Debug "LASTEXITCODE: $LASTEXITCODE"
Write-Debug "PSMODULE_GITHUB_SCRIPT: $env:PSMODULE_GITHUB_SCRIPT"

# Check if credentials should be preserved
$preserveCredentials = $env:PSMODULE_GITHUB_SCRIPT_INPUT_PreserveCredentials -eq 'true'
Write-Debug "PreserveCredentials: $preserveCredentials"

if (-not $preserveCredentials) {
    Write-Debug "Disconnecting GitHub contexts and CLI..."
    try {
        # Import GitHub module if not already imported
        if (-not (Get-Module -Name GitHub -ErrorAction SilentlyContinue)) {
            Import-Module -Name GitHub -ErrorAction SilentlyContinue
        }
        
        # Disconnect GitHub account if the module and function are available
        if (Get-Command Disconnect-GitHubAccount -ErrorAction SilentlyContinue) {
            Disconnect-GitHubAccount
            Write-Debug "Successfully disconnected GitHub account"
        } else {
            Write-Debug "Disconnect-GitHubAccount command not available"
        }
    } catch {
        Write-Warning "Failed to disconnect GitHub account: $($_.Exception.Message)"
    }
}

$env:PSMODULE_GITHUB_SCRIPT = $false
Write-Debug "PSMODULE_GITHUB_SCRIPT: $env:PSMODULE_GITHUB_SCRIPT"
