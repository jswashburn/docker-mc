[CmdletBinding()]
param(
    # Name of the backup archive
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

# TODO: In order to actually have automatic updates, we need automatic sign in to azure, which involves getting a certificate or something?..
# TODO: You can attach metadata to blobs, may be a use case here
$settings = Get-Content -Path $env:SERVER_BACKUP_SETTINGS | ConvertFrom-Json

$context = New-AzStorageContext -StorageAccountName $settings.cloudResources.storageAccountName -UseConnectedAccount
Set-AzStorageBlobContent `
    -File $ArchiveName `
    -Container $settings.cloudResources.storageContainerName `
    -Blob $ArchiveName `
    -Context $context