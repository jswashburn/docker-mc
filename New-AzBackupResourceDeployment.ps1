<#
This script deploys the resources needed for world backups to your Azure subscription
#>

#
# Sign in to Azure
#

Connect-AzAccount -UseDeviceAuthentication
$aadUser = Get-AzADUser
Write-Host "Signed in user"
Write-Host $aadUser.DisplayName -ForegroundColor Green

#
# Replace placeholder values in arm parameters file
#

$templateParameters = Get-Content -Path $env:SERVER_BACKUP_TEMPLATE_PARAMETERS_GENERIC -Raw | ConvertFrom-Json

$settings = Get-Content -Path $env:SERVER_BACKUP_SETTINGS | ConvertFrom-Json
$templateParameters.parameters = @{
    storageAccountName = @{
        value = $settings.cloudResources.storageAccountName
    }
    storageContainerName = @{
        value = $settings.cloudResources.storageContainerName
    }
    userPrincipleId = @{
        value = $aadUser.Id
    }
}

if (-not (Test-Path $env:SERVER_BACKUP_TEMPLATE_PARAMETERS)) {
    New-Item -Path $env:SERVER_BACKUP_TEMPLATE_PARAMETERS -ItemType File
}

$templateParameters | ConvertTo-Json | Set-Content $env:SERVER_BACKUP_TEMPLATE_PARAMETERS

#
# Create resource group if doesn't exist
#

Get-AzResourceGroup -Name $settings.cloudResources.resourceGroupName -ErrorVariable resourceGroupNotPresent -ErrorAction SilentlyContinue
if ($resourceGroupNotPresent) {
    New-AzResourceGroup -Name $settings.cloudResources.resourceGroupName -Location $Location
}

#
# Deploy arm template with parameters
#

Write-Host "Deploying resources..."
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroup.ResourceGroupName `
    -TemplateFile $env:SERVER_BACKUP_TEMPLATE `
    -TemplateParameterFile $env:SERVER_BACKUP_TEMPLATE_PARAMETERS

$settings.cloudResources.resourcesAlreadyProvisioned = $true
$settings | ConvertTo-Json | Set-Content $env:SERVER_BACKUP_SETTINGS