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
    location = @{
        value = $settings.cloudResources.location
    }
    resourceGroupName = @{
        value = $settings.cloudResources.resourceGroupName
    }
    storageAccountName = @{
        value = $settings.cloudResources.storageAccountName
    }
    storageContainerName = @{
        value = $settings.cloudResources.storageContainerName
    }
    userPrincipleId = @{
        value = $aadUser.Id
    }
    environment = @{
        value = $settings.cloudResources.environment
    }
}

if (-not (Test-Path $env:SERVER_BACKUP_TEMPLATE_PARAMETERS)) {
    New-Item -Path $env:SERVER_BACKUP_TEMPLATE_PARAMETERS -ItemType File
}

$templateParameters | ConvertTo-Json | Set-Content $env:SERVER_BACKUP_TEMPLATE_PARAMETERS

#
# Deploy arm template with parameters
#

Write-Host "Deploying resources..."
$deployment = New-AzDeployment `
    -Location $settings.cloudResources.location `
    -TemplateFile $env:SERVER_BACKUP_TEMPLATE `
    -TemplateParameterFile $env:SERVER_BACKUP_TEMPLATE_PARAMETERS `
    -InformationAction SilentlyContinue `
    -ErrorVariable "deployError" `
    -ErrorAction SilentlyContinue

if ($deployment.ProvisioningState -eq 'Succeeded') {
    Write-Host "Deployment Succeeded!" -ForegroundColor Green
} else {
    Write-Host "Deployment did not succeed."
    if ($deployError) {
        Write-Host "Error: "
        Write-Output $deployError
    }
}
