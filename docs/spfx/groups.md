# Groups

- http://www.techmikael.com/2017/03/enable-usage-policy-for-office-365.html
- http://www.techmikael.com/2017/03/controlling-groups-creation-in-tenant.html
- http://www.techmikael.com/2017/05/three-reasons-why-you-should-take.html
- https://www.sharepointeurope.com/defining-good-governance-office-365-groups/
- http://icansharepoint.com/everyday-guide-office-365-groups/
- https://en.share-gate.com/blog/office-365-groups-explained
- https://www.avepoint.com/blog/technical-blog/office-365-groups-vs-teams/
- http://sympmarc.com/2017/04/09/dear-microsoft-in-office-365-groups-are-groups-are-groups-unless-they-arent/
- http://blog.fpweb.net/get-excited-about-office-365-groups-then-relax/#.WOvyNdLyjZs
- https://techcommunity.microsoft.com/t5/Microsoft-Teams/Office-365-Groups-vs-Microsoft-Teams-blog-post/m-p/60743#M3798
- http://blog.ioz.ch/productivity-news-beyond-groups-ein-einblick-und-ausblick/
- https://channel9.msdn.com/Events/Ignite/Australia-2017/PROD225
- https://channel9.msdn.com/Events/Ignite/Australia-2017/PROD222
- https://vigneshsharepointthoughts.com/2018/03/30/office-365-groups-what-you-need-to-know

## Provisioning

https://github.com/SharePoint/PnP-PowerShell/tree/master/Samples/Provisioning.SelfHostedWithAzureWebJob/Engine

## Permissions

- [Copying Office 365 Group Permissions with PowerShell](https://www.toddklindt.com/blog/Lists/Posts/Post.aspx?List=56f96349-3bb6-4087-94f4-7f95ff4ca81f&ID=808&Web=48e6fdd1-17db-4543-b2f9-6fc7185484fc)

## Tipps

- [Generic URLs for all Office 365 Group connected workloads](https://blog.yannickreekmans.be/generic-urls-for-all-office-365-group-connected-workloads/)

```Powershell
# SiteCollection URL <site>
<site>/_layouts/15/groupstatus.aspx?Target=PLANNER

# XML Provisioning Engine - SiteCollection Token {site}
{site}/_layouts/15/groupstatus.aspx?Target=PLANNER
```

## Powershell

- <https://github.com/mikemcleanlive/Ignite-2018-BRK3098-Demo-Scripts>
- <https://vigneshsharepointthoughts.com/2018/05/16/useful-powershell-cmdlets-to-administer-office-365-groups/>
- <https://www.sharepointeurope.com/useful-powershell-cmdlets-administer-office-365-groups>

To get the list of all the Office 365 groups in descending order:

```Powershell
Get-UnifiedGroup | Select Id, DisplayName, ManagedBy, Alias, AccessType, WhenCreated, @{Expression={([array](Get-UnifiedGroupLinks -Identity $_.Id -LinkType Members)).Count }; Label=’Members’} | Sort-Object whencreated | Format-Table displayname, alias, managedby, Members, accesstype, whencreated
```

To get the list of all private Office 365 groups in your tenant:

```Powershell
Get-UnifiedGroup | Where-Object {$_.AccessType -eq ‘Private’} | Sort-Object whencreated | Format-Table displayname, alias, managedby, accesstype, whencreated
``` 

To get list of deleted Office 365 groups in descending order:

```Powershell
Get-AzureADMSDeletedGroup | Sort-Object DeletedDateTime -Descending | Format-Table Id, DisplayName, Description, Visibility, DeletedDateTime
```

How to resolve the error The alias is being used by another group in your organization

```Powershell
Get-AzureADMSDeletedGroup -All:$true | Remove-AzureADMSDeletedDirectoryObject
```

To get the list of orphaned Office 365 groups in your tenant:

```Powershell
$Groups = Get-UnifiedGroup | Where-Object {([array](Get-UnifiedGroupLinks -Identity $_.Id -LinkType Owners)).Count -eq 0} `

| Select Id, DisplayName, ManagedBy, WhenCreated

ForEach ($G in $Groups) {

Write-Host “Warning! The following group has no owner:” $G.DisplayName

}
```

To determine where a group was provisioned (Planner, Yammer, Teams etc.)

```Powershell
Get-UnifiedGroup |Where-Object {$_.ProvisioningOption -eq ‘YammerProvisioning’} |select DisplayName,Alias,ProvisioningOption,GroupSKU,SharePointSiteUrl,SharePointDocumentsUrl,AccessType
```

To get the list of Teams integrated Office 365 group list:

```Powershell
Get-UnifiedGroup |Where-Object {$_.ProvisioningOption -eq ‘ExchangeProvisioningFlags:481’}|select DisplayName,Alias,ProvisioningOption,GroupSKU,SharePointSiteUrl,SharePointDocumentsUrl,AccessType
```
