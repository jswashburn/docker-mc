[CmdletBinding()]
param(
    # The Path to the settings file
    [Parameter(Mandatory = $false)]
    [string]
    $SettingsPath = "data/settings.json"
)

$settingsDir = Split-Path $SettingsPath

function CreateIfNotExists {
    param (
        [string]$Path,
        [string]$ItemType
    )
    
    if (-not (Test-Path -Path $Path)) {
        New-Item -Path $Path -ItemType $ItemType
    }
}

function Prompt {
    param(
        # The Prompt
        [Parameter(Position = 0)]
        [string]
        $Prompt,

        # The Default value if nothing is entered
        [Parameter(Position = 1)]
        [string]
        $Default
    )

    return (Read-Host $Prompt -OutVariable val) -eq "" ? $Default : $val[0]
}

CreateIfNotExists -Path $settingsDir -ItemType "Directory"
CreateIfNotExists -Path $SettingsPath -ItemType "File"

$settings = Get-Content -Path $SettingsPath -Raw | ConvertFrom-Json

$settings = @{
    cloudResources = @{
        skipResourceProvisioning = $false
        resourceGroupName = Prompt "Resource Group Name" "mc-server-rg"
        location = Prompt "Location" "eastus"
        storageAccountName = Prompt "Storage Account Name" "backupssa"
        storageContainerName = Prompt "Storage Container Name" "backups"
    }
}

$settings | ConvertTo-Json | Set-Content $SettingsPath