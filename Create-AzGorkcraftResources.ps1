[CmdletBinding()]
param(
    # The location of the output settings file
    [Parameter(Mandatory = $true)]
    [string]
    $SettingsFile,

    # Name of the storage account used for world backups
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,

    # Name of the blob storage container used for world backups
    [Parameter(Mandatory = $true)]
    [string]
    $StorageContainerName,

    # Name of the resource group
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,

    # Location of Azure resources
    [Parameter(Mandatory = $true)]
    [string]
    $Location
)

$templateParametersGenericPath = ".\template\gorkcraft.Parameters-generic.json"
$templateParametersPath = ".\template\gorkcraft.Parameters.json"
$templatePath = ".\template\gorkcraft.Template.json"

#
# Sign in to Azure
#

Connect-AzAccount -UseDeviceAuthentication
$aadUser = Get-AzADUser
Write-Host "Signed in user ${aadUser.DisplayName}"

#
# Replace placeholder values in arm parameters file
#

$templateParameters = Get-Content -Path $templateParametersGenericPath -Raw | ConvertFrom-Json

$templateParameters.parameters = @{
    storageAccountName = @{
        value = $StorageAccountName
    }
    storageContainerName = @{
        value = $StorageContainerName
    }
    userPrincipleId = @{
        value = $aadUser.Id
    }
}

$templateParameters | ConvertTo-Json | Set-Content $templateParametersPath

#
# Deploy arm template with parameters
#

$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorVariable resourceGroupNotPresent -ErrorAction SilentlyContinue
if ($resourceGroupNotPresent) {
    $resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

Write-Host "Deploying resources..."
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroup.ResourceGroupName `
    -TemplateFile $templatePath `
    -TemplateParameterFile $templateParametersPath
