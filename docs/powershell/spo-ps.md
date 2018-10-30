# SPO Powershell

- [SPO Index](https://technet.microsoft.com/en-us/library/fp161364(v=office.15)#SharePoint)
- [Getting started with SharePoint Online Management Shell](https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps)

## Check Version

Latest Version
- https://www.powershellgallery.com/packages/Microsoft.Online.SharePoint.PowerShell/16.0.8119.0

```Powershell
Get-Module Microsoft.Online.SharePoint.PowerShell* -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending
```

- [Download](https://www.microsoft.com/en-us/download/details.aspx?id=35588)

## Update Module to latest version

```Powershell
Update-Module Microsoft.Online.SharePoint.PowerShell
```

## Delete old version

```Powershell
Get-InstalledModule -Name "Microsoft.Online.SharePoint.PowerShell" -RequiredVersion 16.0.8119.0 | Uninstall-Module
```

## Credential Manager

- [How-to-use-the-Windows-Credential-Manager-to-ease-authentication-with-PnP-PowerShell](https://github.com/SharePoint/PnP-PowerShell/wiki/How-to-use-the-Windows-Credential-Manager-to-ease-authentication-with-PnP-PowerShell)

## Connect

- [connecting-to-all-office-365-services-with-powershell-and-multi-factor-authentication](https://absolute-sharepoint.com/2018/03/connecting-to-all-office-365-services-with-powershell-and-multi-factor-authentication.html)
- [Connect to Office 365/Exchange Services Functions](https://gallery.technet.microsoft.com/Connect-to-Office-53f6eb07)

```Powershell
Connect-SPOService https://devro-admin.sharepoint.com -Credential admin@devro.onmicrosoft.com
```

## Disconnect

```Powershell
Disconnect-SPOService
```

## ULS-Correlation ID

```Powershell
get-splogevent -starttime (get-date).addminutes(-20) | where-object { $_.correlation -eq "e434f79b-68bb-40d2-0000-03a47eae1bf9" } | fl message > c:\errors1.txt
```

## Security

- [SPO Authentication in Powershell for CSOM when Legacy Authentication is disabled for tenant or Multi Factor Authentication is enabled for user](https://blogs.technet.microsoft.com/sharepointdevelopersupport/2018/10/27/sharepoint-online-authentication-in-powershell-for-csom-when-legacy-authentication-is-disabled-for-tenant-or-multi-factor-authentication-is-enabled-for-user/)
- [sharepoint-framework-and-microsoft-graph-access-%E2%80%93-convenient-but-be-very-careful](http://www.wictorwilen.se/sharepoint-framework-and-microsoft-graph-access-%E2%80%93-convenient-but-be-very-careful)

```Powershell
get-sposite | ?{$_.DenyAddAndCustomizePages -eq 'Disabled'}
 ```

## Ressources

- [resources-to-learn-powershell-for-office-365](https://absolute-sharepoint.com/2018/03/resources-to-learn-powershell-for-office-365.html)

## Tenant Configuration

### Remove Feedback Button

```Powershell
Set-SPOTenant -UserVoiceForFeedbackEnabled:$false
```