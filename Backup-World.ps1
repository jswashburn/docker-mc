[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$Container,

    [Parameter(Mandatory = $true)]
    [string]$ArchiveName,

    [Parameter(Mandatory = $true)]
    [string]$AccessKey,

    [Parameter(Mandatory = $true)]
    [string]$Folder
)

$backupCommand = @"
tar -zcvf $ArchiveName $Folder
"@

Invoke-Expression -Command $backupCommand

$context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $AccessKey

Set-AzStorageBlobContent @{
    File             = $ArchiveName
    Container        = $Container
    Blob             = $Blob
    Context          = $context
    StandardBlobTier = Hot
}
