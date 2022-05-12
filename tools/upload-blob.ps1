[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$KeyVaultName,

    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,

    [Parameter(Mandatory = $true)]
    [string]$File
)

#
# Get SAS token
#

$secretName = (Get-AzKeyVaultSecret -VaultName $KeyVaultName).Name

$secret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $secretName
$ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret.SecretValue)
try {
   $sasToken = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
} finally {
   [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
}

#
# Get storage context
#

$context = New-AzStorageContext -StorageAccountName $StorageAccountName -SasToken $sasToken

#
# Upload file
#

Set-AzStorageBlobContent -Container "backupscontainer" -File $File -Blob "test" -Context $context