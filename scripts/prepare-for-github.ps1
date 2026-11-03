# Usage:  .\prepare-for-github.ps1 -User your-github-name
# Replaces the YOUR-GITHUB-USERNAME placeholder in the MOVE Motor fork and the example project.
param([Parameter(Mandatory = $true)][string]$User)
$root = Split-Path $PSScriptRoot -Parent
foreach ($f in @("pxt-kitronik-move-motor-ble\pxt.json", "example\pxt.json")) {
    $p = Join-Path $root $f
    $text = [IO.File]::ReadAllText($p) -replace 'YOUR-GITHUB-USERNAME', $User
    [IO.File]::WriteAllText($p, $text, (New-Object Text.UTF8Encoding($false)))   # UTF-8 without BOM
    Write-Host "updated $p"
}
