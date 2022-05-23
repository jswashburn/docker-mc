Get-AzADUser -ErrorVariable notSignedIn -ErrorAction SilentlyContinue

if ($notSignedIn) {
    Connect-AzAccount -UseDeviceAuthentication
}

Get-AzResourceGroup -Tag @{"docker-mc"=""} |  Remove-AzResourceGroup -Force -AsJob