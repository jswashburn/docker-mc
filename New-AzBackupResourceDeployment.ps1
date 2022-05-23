#
# Sign in to Azure
#

Connect-AzAccount -UseDeviceAuthentication
$aadUser = Get-AzADUser
Write-Host "Signed in user " -NoNewline
Write-Host $aadUser.DisplayName -ForegroundColor Green

#
# Replace placeholder values in arm parameters file
#

$templateParameters = Get-Content -Path $env:SERVER_BACKUP_TEMPLATE_PARAMETERS_GENERIC -Raw | ConvertFrom-Json

$settings = .\Get-UserSettings.ps1
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

$resourceGroupName = $settings.cloudResources.resourceGroupName
Get-AzResourceGroup -Name $resourceGroupName -ErrorVariable resourceGroupNotPresent -ErrorAction SilentlyContinue
if ($resourceGroupNotPresent) {
    New-AzResourceGroup -Name $resourceGroupName -Location $settings.cloudResources.location
}

#
# Deploy arm template with parameters
#

Write-Host "Deploying resources..."
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $env:SERVER_BACKUP_TEMPLATE `
    -TemplateParameterFile $env:SERVER_BACKUP_TEMPLATE_PARAMETERS 

Set-AzResourceGroup -Name $resourceGroupName -Tag @{"docker-mc"=""}
