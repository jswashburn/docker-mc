[CmdletBinding()]
param(
    # The name of the server .jar file to run
    [Parameter(Mandatory = $false)]
    [string]
    $ServerJarFile = "paper-latest.jar",

    # The ammount of memory to allocate to the Minecraft server
    [Parameter(Mandatory = $false)]
    [string]
    $Memory = "2G"
)

$settings = .\Get-UserSettings.ps1
if (-not $settings.cloudResources.skipResourceProvisioning) {
    $settings = .\Prompt-UserSettings.ps1
    .\Write-UserSettings.ps1 -Settings $settings

    .\New-AzBackupResourceDeployment.ps1

    $settings.cloudResources.skipResourceProvisioning = $true
    .\Write-UserSettings.ps1 -Settings $settings
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

Write-Host "Server Stopped. Backing up world data..."

.\Start-ArchiveUpload.ps1 -ArchiveName "backup-latest"
