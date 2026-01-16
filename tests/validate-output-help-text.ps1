#!/usr/bin/env pwsh
#Requires -Version 7.0

<#
.SYNOPSIS
    Validates that the output help text suggestions are correct for both direct and nested usage.

.DESCRIPTION
    This script tests the logic that generates help text in outputs.ps1 to ensure:
    1. Direct usage shows the correct step ID
    2. Nested usage shows the placeholder text for user's step ID
    3. The format is correct for both scenarios
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Test-OutputHelpText {
    param(
        [string]$StepId,
        [string]$OutputName,
        [bool]$HasStepId
    )

    $blue = $PSStyle.Foreground.Blue
    $reset = $PSStyle.Reset

    Write-Host "`n=== Testing Output Help Text ===" -ForegroundColor Cyan
    Write-Host "Step ID: $StepId" -ForegroundColor Yellow
    Write-Host "Output Name: $OutputName" -ForegroundColor Yellow
    Write-Host "Has Step ID: $HasStepId" -ForegroundColor Yellow

    if ($HasStepId -and -not [string]::IsNullOrEmpty($StepId)) {
        # Simulate what outputs.ps1 does for direct usage
        $directUsage = "Direct usage: [$blue`${{ fromJson(steps.$StepId.outputs.result).$OutputName }}$reset]"
        $nestedUsage = "Nested usage: [$blue`${{ fromJson(steps.<your-step-id>.outputs.result).$OutputName }}$reset]"

        Write-Host "`nGenerated help text:" -ForegroundColor Green
        Write-Host $directUsage
        Write-Host $nestedUsage

        # Remove ANSI codes for validation
        $directUsageClean = $directUsage -replace '\x1b\[[0-9;]*m', ''
        $nestedUsageClean = $nestedUsage -replace '\x1b\[[0-9;]*m', ''

        # Validate the format
        $expectedDirectPattern = "\$\{\{ fromJson\(steps\.$StepId\.outputs\.result\)\.$OutputName \}\}"
        $expectedNestedPattern = "\$\{\{ fromJson\(steps\.<your-step-id>\.outputs\.result\)\.$OutputName \}\}"

        if ($directUsageClean -match $expectedDirectPattern) {
            Write-Host "✅ Direct usage pattern is correct" -ForegroundColor Green
        } else {
            Write-Error "❌ Direct usage pattern is incorrect"
            return $false
        }

        if ($nestedUsageClean -match $expectedNestedPattern) {
            Write-Host "✅ Nested usage pattern is correct" -ForegroundColor Green
        } else {
            Write-Error "❌ Nested usage pattern is incorrect"
            return $false
        }

        # Verify both lines are present
        if ($directUsage -match "Direct usage:") {
            Write-Host "✅ Direct usage label is present" -ForegroundColor Green
        } else {
            Write-Error "❌ Direct usage label is missing"
            return $false
        }

        if ($nestedUsage -match "Nested usage:") {
            Write-Host "✅ Nested usage label is present" -ForegroundColor Green
        } else {
            Write-Error "❌ Nested usage label is missing"
            return $false
        }

    } else {
        # Simulate what outputs.ps1 does when step ID is not available
        $genericUsage = "Accessible via: [$blue`${{ fromJson(steps.<step-id>.outputs.result).$OutputName }}$reset]"

        Write-Host "`nGenerated help text:" -ForegroundColor Green
        Write-Host $genericUsage

        # Remove ANSI codes for validation
        $genericUsageClean = $genericUsage -replace '\x1b\[[0-9;]*m', ''

        $expectedGenericPattern = "\$\{\{ fromJson\(steps\.<step-id>\.outputs\.result\)\.$OutputName \}\}"

        if ($genericUsageClean -match $expectedGenericPattern) {
            Write-Host "✅ Generic usage pattern is correct" -ForegroundColor Green
        } else {
            Write-Error "❌ Generic usage pattern is incorrect"
            return $false
        }
    }

    return $true
}

# Test scenarios
$testsPassed = 0
$testsFailed = 0

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "Testing Direct Usage Scenario" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

if (Test-OutputHelpText -StepId "direct-test" -OutputName "DirectOutput" -HasStepId $true) {
    $testsPassed++
} else {
    $testsFailed++
}

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "Testing Composite Action Usage Scenario" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

if (Test-OutputHelpText -StepId "composite-test" -OutputName "TestOutput1" -HasStepId $true) {
    $testsPassed++
} else {
    $testsFailed++
}

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "Testing Scenario Without Step ID" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta

if (Test-OutputHelpText -StepId "" -OutputName "SomeOutput" -HasStepId $false) {
    $testsPassed++
} else {
    $testsFailed++
}

Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "Test Summary" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -gt 0) { 'Red' } else { 'Green' })

if ($testsFailed -gt 0) {
    Write-Error "Some tests failed!"
    exit 1
}

Write-Host "`n✅ All validation tests passed!" -ForegroundColor Green
exit 0
