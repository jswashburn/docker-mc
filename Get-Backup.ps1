[CmdletBinding()]
param(
    # The name of the blob
    [Parameter(Mandatory = $true)]
    [string]
    $Blob,

    # The destination for the download
    [Parameter(Mandatory = $false)]
    [string]
    $Destination = "."
)


$settings = Get-Content -Path $env:SERVER_BACKUP_SETTINGS | ConvertFrom-Json
$context = New-AzStorageContext -StorageAccountName $settings.cloudResources.storageAccountName -UseConnectedAccount

Get-AzStorageBlobContent `
    -Container $settings.cloudResources.storageContainerName `
    -Blob $Blob `
    -Destination $Destination `
    -Context $context
