[CmdletBinding()]
param(
    # A hash table representing the user settings
    [Parameter(Mandatory = $true, Position = 0)]
    [PSCustomObject]
    $Settings
)

$Settings | ConvertTo-Json | Set-Content $env:SERVER_BACKUP_SETTINGS
