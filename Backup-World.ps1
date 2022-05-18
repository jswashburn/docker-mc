[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$ContainerName,

    [Parameter(Mandatory = $false)]
    [string]$ArchiveName = "world.tar.gz",

    [Parameter(Mandatory = $false)]
    [string]$Folder = "./world"
)

#
# Zip the world folders
#

$backupCommand = @"
tar -zcvf $ArchiveName $Folder
"@

Invoke-Expression -Command $backupCommand

#
# Upload to blob storage container
#

# TODO: In order to actually have automatic updates, we need automatic sign in to azure, which involves getting a certificate or something?..
$context = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount

Set-AzStorageBlobContent @{
    File             = $ArchiveName
    Container        = $ContainerName
    Blob             = $Blob
    Context          = $context
    StandardBlobTier = Hot
}
