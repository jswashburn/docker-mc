return @{
    cloudResources = @{
        skipResourceProvisioning = $false
        resourceGroupName = .\Prompt-Default.ps1 "Resource Group Name [Enter:default]" "mc-server-rg"
        location = .\Prompt-Default.ps1 "Location [Enter:default]" "eastus"
        storageAccountName = .\Prompt-Default.ps1 "Storage Account Name [Enter:default]" "backupssa"
        storageContainerName = .\Prompt-Default.ps1 "Storage Container Name [Enter:default]" "backups"
    }
}
