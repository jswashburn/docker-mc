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
