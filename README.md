# GitHub-Script

A GitHub Action used for running a PowerShell Script that uses the GitHub PowerShell module.

For more information on the available functions and automatic loaded variables, see the [GitHub PowerShell module documentation](https://psmodule.io/GitHub)

## Usage

### Inputs

| Name | Description | Required | Default |
| - | - | - | - |
| `Script` | The script to run | false | |
| `Token` | The GitHub token to use. This will override the default behavior of using the `GITHUB_TOKEN` environment variable. | false | `${{ github.token }}` |
| `Debug` | Enable debug output | false | `'false'` |
| `Verbose` | Enable verbose output | false | `'false'` |
| `Version` | Specifies the version of the GitHub module to be installed. The value must be an exact version. | false | |
| `Prerelease` | Allow prerelease versions if available | false | `'false'` |
| `WorkingDirectory` | The working directory where the script will run from | false | `${{ github.workspace }}` |

### Examples

#### Example 1: Run a script that uses the GitHub PowerShell module

Run a script that uses the GitHub PowerShell module.
This example runs a non-authenticated script that gets the GitHub Zen message.

```yaml
jobs:
  Run-Script:
    runs-on: ubuntu-latest
    steps:
      - name: Run script
        uses: PSModule/GitHub-Script@v1
        with:
          Script: |
            LogGroup "Get-GitHubZen" {
              Get-GitHubZen
            }
```

#### Example 2: Run a script that uses the GitHub PowerShell module with a token

Run a script that uses the GitHub PowerShell module with a token.
This example runs an authenticated script that gets the GitHub Zen message.

```yaml
jobs:
  Run-Script:
    runs-on: ubuntu-latest
    steps:
      - name: Run script
        uses: PSModule/GitHub-Script@v1
        with:
          Token: ${{ github.token }}
          Script: |
            LogGroup "Get-GitHubZen" {
              Get-GitHubZen
            }
```

## Related projects

- [actions/create-github-app-token](https://github.com/actions/create-github-app-token) -> Functionality will be brought into GitHub PowerShell module.
- [actions/github-script](https://github.com/actions/github-script)
- [PSModule/GitHub](https://github.com/PSModule/GitHub)
