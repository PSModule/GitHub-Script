# GitHub-Script

A GitHub Action used for running a PowerShell Script that uses the GitHub PowerShell module.

For more information on the available functions and automatic loaded variables, see the
[GitHub PowerShell module documentation](https://psmodule.io/GitHub)

## Usage

### Inputs

| Name | Description | Required | Default |
| - | - | - | - |
| `Script` | The script to run. Can be inline, multi-line or a path to a script file. | false | |
| `Token` | Log in using an Installation Access Token (IAT). | false | `${{ github.token }}` |
| `ClientID` | Log in using a GitHub App, using the App's Client ID and Private Key. | false | |
| `PrivateKey` | Log in using a GitHub App, using the App's Client ID and Private Key. | false | |
| `Debug` | Enable debug output. | false | `'false'` |
| `Verbose` | Enable verbose output. | false | `'false'` |
| `Version` | Specifies the version of the GitHub module to be installed. The value must be an exact version. | false | |
| `Prerelease` | Allow prerelease versions if available. | false | `'false'` |
| `ShowOutput` | Show the output of the script. | false | `'false'` |
| `WorkingDirectory` | The working directory where the script will run from. | false | `${{ github.workspace }}` |

### Outputs

| Name | Description |
| - | - |
| `result` | The output of the script as a JSON object. To add outputs to `result`, use `Set-GitHubOutput`. |

To use the outputs in a subsequent step, you can use the following syntax:

```yaml
- uses: PSModule/GitHub-Script@v1
  id: set-output
  with:
    Script: |
      Set-GitHubOutput -Name 'Octocat' -Value @{
        Name = 'Octocat'
        Image = 'https://octodex.github.com/images/original.png'
      }

- name: Use outputs
  shell: pwsh
  env:
    result: ${{ steps.set-output.outputs.result }} # = '{"Octocat":{"Name":"Octocat","Image":"https://octodex.github.com/images/original.png"}}'
    name: ${{ fromJson(steps.set-output.outputs.result).Octocat.Name }} # = 'Octocat'
  run: |
    $result = $env:result | ConvertFrom-Json
    Write-Output $env:name
    Write-Output $result.Octocat.Image
```


### Examples

#### Example 1: Run a GitHub PowerShell script

Run a script (`scripts/main.ps1`) that uses the GitHub PowerShell module, authenticated using the `GITHUB_TOKEN`.

```yaml
jobs:
  Run-Script:
    runs-on: ubuntu-latest
    steps:
      - name: Run script
        uses: PSModule/GitHub-Script@v1
        with:
          Script: scripts/main.ps1
```

The `Script` supports the following formats:

- Inline script, although it is recommended to use a script file for better tooling support and linting capabilities.
- Multi-line script.
- Path to a script file.
  - `tests/info.ps1`
  - `.\tests\info.ps1`
  - `./tests/info.ps1`
  - `. .\tests\info.ps1`
  - `. ./tests/info.ps1`

If you are creation an action of your own, you should use the `${{ github.action_path }}` variable to get the path to the action.
You should avoid using `$env:GITHUB_ACTION_PATH` as it will not be the expected value if you nest actions inside one another.

> [!WARNING]
> Using `tests\info.ps1` is PowerShells syntax for calling a function under a specific module.

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

#### Example 5: Using the outputs from the script

Run a script that uses the GitHub PowerShell module and outputs the result.

```yaml
- name: Run GitHub Script
  uses: PSModule/GitHub-Script@v1
  id: outputs
  with:
    Script: |
      $cat = Get-GitHubOctocat
      $zen = Get-GitHubZen
      Set-GitHubOutput -Name 'Octocat' -Value $cat
      Set-GitHubOutput -Name 'Zen' -Value $zen

- name: Use outputs
  shell: pwsh
  env:
    result: ${{ steps.test.outputs.result }}
  run: |
      $result = $env:result | ConvertFrom-Json
      Set-GitHubStepSummary -Summary $result.WISECAT
      Write-GitHubNotice -Message $result.Zen -Title 'GitHub Zen'
```

## Related projects

- [actions/create-github-app-token](https://github.com/actions/create-github-app-token) -> Functionality will be brought into GitHub PowerShell module.
- [actions/github-script](https://github.com/actions/github-script)
- [PSModule/GitHub](https://github.com/PSModule/GitHub)
