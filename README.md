# GitHub-Script

A GitHub Action used for running a PowerShell Script that uses the GitHub PowerShell module

## Usage

### Inputs

| Name | Description | Required | Default |
| - | - | - | - |
| `Script` | The script to run | true | |
| `Token` | The GitHub token to use | false | ${{ github.token }} |
| `Debug` | Enable debug output | false | 'false' |
| `Verbose` | Enable verbose output | false | 'false' |
| `Version` | The version of the GitHub module to install | false | 'latest' |
| `Prerelease` | Allow prerelease versions if available | false | 'false' |
| `WorkingDirectory` | The working directory where the script will run from | false | ${{ github.workspace }} |

<!--
    Token
    JWT
    AppID
    Repos
    Organization
    Host -> github.com, *.ghe.com
-->

<!-- ### Secrets -->

<!--
    Token
    JWT
-->

<!-- ### Outputs -->

### Example

```yaml
Example here
```

### Similar projects

- [actions/create-github-app-token](https://github.com/actions/create-github-app-token) -> Functionality will be brought into GitHub PowerShell module.
- [actions/github-script](https://github.com/actions/github-script)
- [PSModule/GitHub](https://github.com/PSModule/GitHub)
