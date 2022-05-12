[CmdletBinding()]
param(
    [switch]$Clear = $false
)

$clearCommand = @"
docker image rm -f wwishy/gorkcraft
"@

$runCommand = @"
docker run -itp 25565:25565 wwishy/gorkcraft
"@

if ($Clear) {
    Invoke-Expression -Command $clearCommand
}

Invoke-Expression -Command $runCommand