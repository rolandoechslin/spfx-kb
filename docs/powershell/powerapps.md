# Teams Powershell

- [PowerShell support for Power Apps](https://docs.microsoft.com/en-us/power-platform/admin/powerapps-powershell)
- [PowerShell Cmdlets for PowerApps and Flow creators and administrators](https://powerapps.microsoft.com/de-de/blog/gdpr-admin-powershell-cmdlets/)

## Check Version

Latest Version

- [History - Microsoft.PowerApps.Administration.PowerShell](https://www.powershellgallery.com/packages/Microsoft.PowerApps.Administration.PowerShell/2.0.102)

```Powershell
Get-Module Microsoft.PowerApps* -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending
```

## Update Module to latest version

```Powershell
Update-Module Microsoft.PowerApps*
```

## Delete old version

```Powershell
# Admin
Get-InstalledModule -Name "Microsoft.PowerApps.Administration.PowerShell" -RequiredVersion 2.0.56 | Uninstall-Module

## Maker
Get-InstalledModule -Name "Microsoft.PowerApps.PowerShell" -RequiredVersion 1.0.9 | Uninstall-Module
```

## Connect

```Powershell
Add-PowerAppsAccount
```

## Disconnect
