# GitHub-Script

A GitHub Action used for running a PowerShell Script that uses the GitHub PowerShell module.

For more information on the available functions and automatic loaded variables, see the [GitHub PowerShell module documentation](https://psmodule.io/GitHub)

## Usage

### Inputs

| Name | Description | Required | Default |
| - | - | - | - |
| `Script` | The script to run | false | |
| `Token` | Log in using an Installation Access Token (IAT) | false | `${{ github.token }}` |
| `ClientID` | Log in using a GitHub App, using the App's Client ID and Private Key | false | |
| `PrivateKey` | Log in using a GitHub App, using the App's Client ID and Private Key | false | |
| `Debug` | Enable debug output | false | `'false'` |
| `Verbose` | Enable verbose output | false | `'false'` |
| `Version` | Specifies the version of the GitHub module to be installed. The value must be an exact version. | false | |
| `Prerelease` | Allow prerelease versions if available | false | `'false'` |
| `WorkingDirectory` | The working directory where the script will run from | false | `${{ github.workspace }}` |

### Examples

#### Example 1: Run a GitHub PowerShell script

Run a script that uses the GitHub PowerShell module.
This example runs an authenticated script using the `GITHUB_TOKEN` and gets the GitHub Zen message.

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

#### Example 2: Run a GitHub PowerShell script without a token

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
          Token: ''
          Script: |
            LogGroup "Get-GitHubZen" {
              Get-GitHubZen
            }
```

#### Example 3: Run a GitHub PowerShell script with a custom token

Run a script that uses the GitHub PowerShell module with a token. The token can be both a personal access token (PAT) or
an installation access token (IAT). This example runs an authenticated script that gets the GitHub Zen message.

```yaml
jobs:
  Run-Script:
    runs-on: ubuntu-latest
    steps:
      - name: Run script
        uses: PSModule/GitHub-Script@v1
        with:
          Token: ${{ secrets.Token }}
          Script: |
            LogGroup "Get-GitHubZen" {
              Get-GitHubZen
            }
```

#### Example 4: Run a GitHub PowerShell script with a GitHub App using a Client ID and Private Key

Run a script that uses the GitHub PowerShell module with a GitHub App.
This example runs an authenticated script that gets the GitHub App.

```yaml
jobs:
  Run-Script:
    runs-on: ubuntu-latest
    steps:
      - name: Run script
        uses: PSModule/GitHub-Script@v1
        with:
          ClientID: ${{ secrets.CLIENT_ID }}
          PrivateKey: ${{ secrets.PRIVATE_KEY }}
          Script: |
            LogGroup "Get-GitHubApp" {
              Get-GitHubApp
            }
```

## Related projects

- [actions/create-github-app-token](https://github.com/actions/create-github-app-token) -> Functionality will be brought into GitHub PowerShell module.
- [actions/github-script](https://github.com/actions/github-script)
- [PSModule/GitHub](https://github.com/PSModule/GitHub)
