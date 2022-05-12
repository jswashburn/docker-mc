[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    $OutputJarFilename = "paper-latest.jar",

    [Parameter(Mandatory = $false)]
    $Version = $null,

    [Parameter(Mandatory = $false)]
    $Build = $null,

    [Parameter(Mandatory = $false)]
    $DownloadFilename = $null
)

$WarningPreference = "Inquire"
Write-Warning "This will replace the existing $OutputJarFilename file with the latest version downloaded from PaperMC's api."

$baseUrl = "https://papermc.io/api/v2"

try {
    $versionToGet = $Version ?? (Invoke-RestMethod -Method "GET" -Uri "$baseUrl/projects/paper").versions[-1]
    $buildVersionToGet = $Build ?? (Invoke-RestMethod -Method "GET" -Uri "$baseUrl/projects/paper/versions/$versionToGet").builds[-1]
    $downloadFilenameToGet = $DownloadFilename ?? (Invoke-RestMethod -Method "GET" -Uri "$baseUrl/projects/paper/versions/$versionToGet/builds/$buildVersionToGet").downloads.application.name

    Write-Warning @"
This will download $downloadFilenameToGet and rename to $OutputJarFilename.
This will replace the jar file that was previously there.
If your server starts with $OutputJarFilename, please make sure the old one has been stopped before moving on!
"@

    Invoke-RestMethod -Method "GET" -Uri "$baseUrl/projects/paper/versions/$versionToGet/builds/$buildVersionToGet/downloads/$downloadFilenameToGet" -OutFile $OutputJarFilename
} catch {
    Write-Error "Could not update world due to error"
    Write-Output $_
}
