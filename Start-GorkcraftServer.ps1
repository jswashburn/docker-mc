[CmdletBinding()]
param(
    # The name of the server .jar file to run
    [Parameter(Mandatory = $false)]
    [string]
    $ServerJarFile = "paper-latest.jar",

    # The ammount of memory to allocate to the Minecraft server
    [Parameter(Mandatory = $false)]
    [string]
    $Memory = "2G",

    # The location of your settings file that will hold information related to resources created in Azure
    # These cloud resources are used to upload world backups
    [Parameter(Mandatory = $false)]
    [string]
    $SettingsFile = ".\data\settings.json"
)

#
# Setup cloud storage for automated backups
#

if (-not (Test-Path -Path $SettingsFile)) {
    ConvertTo-Json @{
        resourcesAlreadyProvisioned = $false
    } | Out-File $SettingsFile
}

$azSettings = Get-Content -Path $SettingsFile | ConvertFrom-Json
if (-not $azSettings.resourcesAlreadyProvisioned) {
    .\Create-AzGorkcraftResources.ps1 `
        -SettingsFile $SettingsFile `
        -ResourceGroupName "gorkcraft-rg"
        -Location "eastus" `
        -StorageAccountName "gorkcraftsa" `
        -StorageContainerName "backups"
}

#
# Run the server using Aikars flags https://docs.papermc.io/paper/aikars-flags
#

$startServer = @"
java ``
    -Xms$Memory -Xmx$Memory ``
    -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 ``
    -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch ``
    -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M ``
    -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 ``
    -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 ``
    -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem ``
    -XX:MaxTenuringThreshold=1 ``
    -jar $ServerJarFile --nogui
"@

Invoke-Expression $startServer