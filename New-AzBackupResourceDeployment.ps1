<#
This script deploys the resources needed for world backups to your Azure subscription
#>

[CmdletBinding()]
param(
    # Whether or not to append random letters to the end of resource names.
    # Could be useful if testing resource creation.
    [Parameter(Mandatory = $false)]
    [bool]
    $UseRandomResourceNameSuffix = $false
)

$suffix = ($UseRandomResourceNameSuffix ? (-join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_})) : "").ToLower()
$settings = Get-Content -Path $env:SERVER_BACKUP_SETTINGS | ConvertFrom-Json
$settings.cloudResources.storageAccountName += $suffix
$settings.cloudResources.storageContainerName += $suffix
$settings.cloudResources.resourceGroupName += $suffix
$settings | ConvertTo-Json | Set-Content $env:SERVER_BACKUP_SETTINGS

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

$settings.cloudResources.resourcesAlreadyProvisioned = $true
$settings | ConvertTo-Json | Set-Content $env:SERVER_BACKUP_SETTINGS