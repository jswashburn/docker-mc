<#
In order to run a Minecraft server, the EULA must be accepted - this script will do that
This script is run as part of container build and does not need to be run manually.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$EulaPath
)

if (Test-Path -Path $EulaPath) {
    (Get-Content -Path $EulaPath -Raw).Replace("eula=false", "eula=true") | Out-File $EulaPath -NoNewline
} else {
    throw "Cannot accept the eula.txt since the path specified does not exist."
}
