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

    # Whether or not to skip Azure resource creation
    [Parameter(Mandatory = $false)]
    [switch]
    $SkipAzResourceProvisioning
)

#
# Setup cloud storage for automated backups
#


if (-not $settings.cloudResources.resourcesAlreadyProvisioned -and -not $SkipAzResourceProvisioning) {
    .\Create-AzGorkcraftResources.ps1
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