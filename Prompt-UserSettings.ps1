# Get the default settings
$settings = .\Get-UserSettings.ps1

$environment = .\Prompt-Default.ps1 "Environment (can be either 'test' or 'prod')" $settings.cloudResources.environment
if ($environment -notin @('test', 'prod')) {
    throw "Invalid argument specified for environment: '$environment'. Value must be 'test' or 'prod'"
}

$suffix = ""
if ($environment -eq 'test') {
    $suffix = (New-Guid).Guid.Substring(0, 5)
}

return @{
    cloudResources = @{
        skipResourceProvisioning = $false
        resourceGroupName = .\Prompt-Default.ps1 "Resource Group Name" ($settings.cloudResources.resourceGroupName + $suffix)
        location = .\Prompt-Default.ps1 "Location" $settings.cloudResources.location
        storageAccountName = .\Prompt-Default.ps1 "Storage Account Name" ($settings.cloudResources.storageAccountName + $suffix)
        storageContainerName = .\Prompt-Default.ps1 "Storage Container Name" ($settings.cloudResources.storageContainerName + $suffix)
        environment = $environment
    }
}
