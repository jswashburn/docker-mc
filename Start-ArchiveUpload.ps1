[CmdletBinding()]
param(
    # Name of the backup archive. This will also be the name of the blob
    [Parameter(Mandatory = $true)]
    [string]
    $ArchiveName,

    # An array of folders to archive
    [Parameter(Mandatory = $false)]
    [string[]]
    $Folders = @("world", "world_the_end", "world_nether")
)

#
# Zip the world folders
#

$backupCommand = @"
tar -zcvf $ArchiveName $Folders
"@

Invoke-Expression -Command $backupCommand

#
# Upload to blob storage container
#

$settings = .\Get-UserSettings.ps1
$context = New-AzStorageContext -StorageAccountName $settings.cloudResources.storageAccountName -UseConnectedAccount
Set-AzStorageBlobContent `
    -File $ArchiveName `
    -Container $settings.cloudResources.storageContainerName `
    -Blob $ArchiveName `
    -Context $context
