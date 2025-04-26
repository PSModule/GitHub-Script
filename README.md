# GitHub-Script

A GitHub Action for running a PowerShell that is integrated into GitHub using the [GitHub PowerShell module](https://psmodule.io/GitHub).

To get started with your own GitHub PowerShell based action, [create a new repository from PSModule/Template-Action](https://github.com/new?template_name=Template-Action&template_owner=PSModule).

## Usage

### Inputs

| Name               | Description                                                               | Required | Default               |
|--------------------|---------------------------------------------------------------------------|----------|-----------------------|
| `Name`             | The name of the action.                                                   | false    | `GitHub-Script`       |
| `Script`           | The script to run. Can be inline, multi-line, or a path to a script file. | false    |                       |
| `Token`            | Log in using an Installation Access Token (IAT).                          | false    | `${{ github.token }}` |
| `ClientID`         | Log in using a GitHub App, with the App's Client ID and Private Key.      | false    |                       |
| `PrivateKey`       | Log in using a GitHub App, with the App's Client ID and Private Key.      | false    |                       |
| `Debug`            | Enable debug output.                                                      | false    | `'false'`             |
| `Verbose`          | Enable verbose output.                                                    | false    | `'false'`             |
| `Version`          | Specifies the exact version of the GitHub module to install.              | false    |                       |
| `Prerelease`       | Allow prerelease versions if available.                                   | false    | `'false'`             |
| `ErrorView`        | Configure the PowerShell `$ErrorView` variable. You can use full names ('NormalView', 'CategoryView', 'ConciseView', 'DetailedView'). It matches on partials. | false    | `'NormalView'`         |
| `ShowInfo`         | Show information about the environment.                                   | false    | `'true'`              |
| `ShowInit`         | Show information about the initialization.                                | false    | `'false'`             |
| `ShowOutput`       | Show the script's output.                                                 | false    | `'false'`             |
| `WorkingDirectory` | The working directory where the script runs.                              | false    | `'.'`                 |

### Outputs

| Name     | Description                                                                             |
|----------|---------------------------------------------------------------------------------------- |
| `result` | The script output as a JSON object. To add outputs to `result`, use `Set-GitHubOutput`. |

To use the outputs in a subsequent step, reference them as follows:

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

#### Example 1: Run a GitHub PowerShell script file

Runs a script (`scripts/main.ps1`) that uses the GitHub PowerShell module, authenticated using the `GITHUB_TOKEN`.

```yaml
jobs:
  Run-Script:
    runs-on: ubuntu-latest
    steps:
      - name: Run inline script - single line
        uses: PSModule/GitHub-Script@v1
        with:
          Script: Get-GitHubPullRequest

      - name: Run inline script - multiline
        uses: PSModule/GitHub-Script@v1
        with:
          Script: |
            LogGroup 'Get-GitHubPullRequest' {
              Get-GitHubPullRequest
            }

      - name: Run script file - Local repository
        uses: PSModule/GitHub-Script@v1
        with:
          Script: ./scripts/main.ps1

      - name: Run script file - In a composite action
        uses: PSModule/GitHub-Script@v1
        with:
          Script: ${{ github.action_path }}/scripts/main.ps1
```

> [!IMPORTANT]
> Use `${{ github.action_path }}/<pathToScript.ps1>` if you are creating an action of your own that uses this action as a step. This ensures
> the path references your action rather than the `GitHub-Script` action repository. Using `$env:GITHUB_ACTION_PATH` can lead to mixed results
> when nesting actions. The context syntax will expand to the correct path when the job is evaluated by GitHub before being processed by the runner.

The `Script` input supports these formats:

- Inline script:
  - Single-line
  - Multi-line
- Path to a script file (recommended):
  - `scripts/main.ps1`
  - `.\scripts\main.ps1`
  - `./scripts/main.ps1`
  - `. .\scripts\main.ps1`
  - `. ./scripts/main.ps1`
  - `. '.\scripts\main.ps1'`
  - `. './scripts/main.ps1'`

> [!WARNING]
> Using `tests\info.ps1` is PowerShell syntax for calling a function from a specific module (e.g., `Microsoft.PowerShell.Management\Get-ChildItem`).
<!-- markdownlint-disable-next-line -->

> [!TIP]
> Use script files instead of inline scripts for better support for development tools and linters. The PowerShell extension for Visual Studio Code and
> linters like PSScriptAnalyzer work natively with script files.

#### Example 2: Run a GitHub PowerShell script without a token

Runs a non-authenticated script that retrieves the GitHub Zen message.

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

Runs a script that uses the GitHub PowerShell module with a token. The token can be a personal access token (PAT) or
an installation access token (IAT). This example retrieves the GitHub Zen message.

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

Runs a script that uses the GitHub PowerShell module with a GitHub App. This example retrieves the GitHub App details.

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

#### Example 5: Using outputs from the script

Runs a script that uses the GitHub PowerShell module and outputs the result.

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
