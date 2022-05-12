[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$File = "paper-latest.jar",

    [Parameter(Mandatory = $false)]
    [string]$Memory = "2G"
)

# The command that starts the minecraft server, using Aikars flags
# https://docs.papermc.io/paper/aikars-flags
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
    -jar $File --nogui
"@

Invoke-Expression $startServer