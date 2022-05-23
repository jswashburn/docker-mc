$settings = Get-Content -Path $env:SERVER_BACKUP_SETTINGS | ConvertFrom-Json

return $settings