# This script creates the pre-requisite resources that need to be in place before onboarding to teleport.
# https://msazure.visualstudio.com/One/_wiki/wikis/One.wiki/162145/Teleportal-Onboarding-Detailed-Instructions

[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$Location,
    
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory = $true)]
    [string]$KeyVaultName,
    
    [Parameter(Mandatory = $false)]
    [string]$KeyVaultServicePrincipleId = "cfa8b339-82a2-471a-a3c9-0fc0be7a4093",
    
    [Parameter(Mandatory = $false)]
    [string]$StorageAccountContainerName = "backupscontainer",
    
    [Parameter(Mandatory = $false)]
    [string]$SasTokenName = "gorkcraftsastoken",
    
    [Parameter(Mandatory = $false)]
    [switch]$UseRandomResourceNameSuffix = $false,

    [Parameter(Mandatory = $false)]
    [switch]$Cleanup = $false
)

function wi {
    param(
        [string]$msg
    )

    Write-Host $msg
}

function ww {
    param(
        [string]$msg,

        [Parameter(Mandatory = $false)]
        [string]$action = "Continue"
    )

    Write-Warning "`n$msg" -WarningAction $action
}

#
# Begin script
#

ww @"
This script will create Azure resources. Use the -WhatIf flag to prevent any resource provisioning.
Make sure you are a member of AM/TM-UsageBilling. This is needed for the role assignment step.
Remember to clean up resources in the portal if you CTRL-C before the cleanup section in this script is run.
"@ -action "Inquire"

#
# Construct variables
#

$storageAccountSku = "Standard_LRS"
$storageAccountKind = "StorageV2"

if ($UseRandomResourceNameSuffix) {
    # Append random characters to avoid naming collisions when testing
    # Taken from https://devblogs.microsoft.com/scripting/generate-random-letters-with-powershell/
    $randomstring=-join((97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})
    
    $ResourceGroupName += $randomstring
    $KeyVaultName += $randomstring
    $StorageAccountName += $randomstring
}

#
# Install required modules
#

$requiredModules = @("Az.Resources", "Az.Accounts", "Az.Storage", "Az.KeyVault")
if ($PSCmdlet.ShouldProcess($requiredModules, "Install-Module")) {
    $alreadyAvailable = Get-Module -ListAvailable | Where-Object {$_.Name -in $requiredModules}
    foreach ($module in $requiredModules) {
        if (!$module -in $alreadyAvailable) {
            Install-Module -Name $module
        }
    }
}

#
# Connect to Azure
#

if ($PSCmdlet.ShouldProcess("", "Connect-AzAccount")) {
    Connect-AzAccount
}

if ($PSCmdlet.ShouldProcess($SubscriptionId, "Set-AzContext")) {
    Set-AzContext -SubscriptionId $SubscriptionId
}

#
# Create the pre-requisite resources needed for teleport onboarding
# https://msazure.visualstudio.com/One/_wiki/wikis/One.wiki/46972/Configuring-AKV-for-Teleport
#

if ($PSCmdlet.ShouldProcess($ResourceGroupName, "New-AzResourceGroup")) {
    wi "Creating Resource Group: $ResourceGroupName in $Location..."
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}
if ($PSCmdlet.ShouldProcess($KeyVaultName, "New-AzKeyVault")) {
    wi "Creating KeyVault: $KeyVaultName in $Location..."
    New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroupName -Location $Location
}
if ($PSCmdlet.ShouldProcess($StorageAccountName, "New-AzStorageAccount")) {
    wi "Creating Storage Account: $StorageAccountName in $Location..."
    New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -SkuName $storageAccountSku -Kind $storageAccountKind
}

#
# Connect the storage account to the key vault
# Taken from https://docs.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys-powershell
#

ww @"
Connect storage account to key vault - add role assignment

In order to create a role assignment, your user principle will need the proper permissions."
If this step DOES fail, ensure you are cleaning up resources created in the previous step.
"@ -action "Inquire"

if ($PSCmdlet.ShouldProcess($StorageAccountName, "New-AzRoleAssignment")) {
    wi "Adding role assignment for key vault to storage account..."
    $storageAccount = (Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName)
    New-AzRoleAssignment -ApplicationId $KeyVaultServicePrincipleId -RoleDefinitionName 'Storage Account Key Operator Service Role' -Scope $storageAccount.Id 
}

# Give your user principal access to all storage account permissions, on your Key Vault instance
if ($PSCmdlet.ShouldProcess($KeyVaultName, "Set-AzKeyVaultAccessPolicy")) {
    $userId = (Get-AzContext).Account.Id
    wi "Giving user principle $userId access to all storage account permissions on key vault: $KeyVaultName..."
    Set-AzKeyVaultAccessPolicy -VaultName $KeyVaultName -UserPrincipalName $userId -PermissionsToStorage get, list, delete, set, update, regeneratekey, getsas, listsas, deletesas, setsas, recover, backup, restore, purge
}

# Create a managed storage account in the key vault instance
if ($PSCmdlet.ShouldProcess($KeyVaultName, "Add-AzKeyVaultManagedStorageAccount")) {
    $storageAccountKey = "key1"
    $regenPeriod = [System.Timespan]::FromDays(3)
    wi "Creating managed storage account in key vault: $KeyVaultName..."
    Add-AzKeyVaultManagedStorageAccount -VaultName $KeyVaultName -AccountName $StorageAccountName -AccountResourceId $storageAccount.Id -ActiveKeyName $storageAccountKey -RegenerationPeriod $regenPeriod
    Get-AzKeyVaultManagedStorageAccount -VaultName $KeyVaultName -AccountName $StorageAccountName
}

#
# Create a storage container, SAS token, and set SAS definition in kv
#

# Create the storage container
if ($PSCmdlet.ShouldProcess($StorageAccountContainerName, "New-AzStorageContainer")) {
    wi "Creating storage container: $StorageAccountContaierName..."
    $storageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -Protocol Https -StorageAccountKey Key1
    Set-AzCurrentStorageAccount -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName
    New-AzStorageContainer -Name $StorageAccountContainerName -Permission Off
}

# Create the SAS token
if ($PSCmdlet.ShouldProcess($storageContext, "New-AzStorageAccountSasToken")) {
    $start = [System.DateTime]::Now.AddDays(-1)
    $end = [System.DateTime]::Now.AddMonths(1)
    wi "Creating SAS token with permissions 'rl'..."
    $sasToken = New-AzStorageAccountSasToken -Service blob -ResourceType Container,Object -Permission "rl" -Protocol HttpsOnly -StartTime $start -ExpiryTime $end -Context $storageContext
}

# Set the SAS definition in key vault
if ($PSCmdlet.ShouldProcess($KeyVaultName, "Set-AzKeyVaultManagedStorageSasDefinition")) {
    wi "Setting the SAS definition on key vault: $KeyVaultName..."
    Set-AzKeyVaultManagedStorageSasDefinition -AccountName $StorageAccountName -VaultName $KeyVaultName -Name $SasTokenName -TemplateUri $sasToken -SasType 'account' -ValidityPeriod ([System.Timespan]::FromDays(30))
}

#
# List new resources and output teleport onboarding info
#

if ($PSCmdlet.ShouldProcess("List created resources")) {
    $resourcesCreated = (Get-AzResource -ResourceGroupName $ResourceGroupName)
    wi "The below resources have been created:"
    foreach ($resource in $resourcesCreated) {
        wi $resource.Name
    }
}

#
# Run cleanup if specified
#

if ($Cleanup -and $PSCmdlet.ShouldProcess($ResourceGroupName, "Remove-AzResourceGroup")) {
    wi "Removing Resource Group: $ResourceGroupName."
    Remove-AzResourceGroup $ResourceGroupName -AsJob
}
