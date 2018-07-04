# SPO Powershell

[SPO Index](https://technet.microsoft.com/en-us/library/fp161364(v=office.15)#SharePoint)

## Check Version

```Powershell
Get-Module Microsoft.Online.SharePoint.PowerShell* -ListAvailable | Select-Object Name,Version | Sort-Object Version -Descending
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
get-splogevent -starttime (get-date).addminutes(-20) | where-object { $_.correlation -eq "e434f79b-68bb-40d2-0000-03a47eae1bf9" }    | fl message > c:\errors1.txt
```

## Security

- [sharepoint-framework-and-microsoft-graph-access-%E2%80%93-convenient-but-be-very-careful](http://www.wictorwilen.se/sharepoint-framework-and-microsoft-graph-access-%E2%80%93-convenient-but-be-very-careful)
```Powershell
get-sposite | ?{$_.DenyAddAndCustomizePages -eq 'Disabled'}
 ```

## Ressources

- [resources-to-learn-powershell-for-office-365](https://absolute-sharepoint.com/2018/03/resources-to-learn-powershell-for-office-365.html)
