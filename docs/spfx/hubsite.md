# HubSite

- [What is a SharePoint hub site](http://aftabsharepoint.blogspot.com/2018/12/sharepoint-hub-sites.html)
- [Video - SharePoint hub sites — What intranet managers need to know](https://www.youtube.com/watch?v=_8RCBsrpLg4)
- [spsnyc-how-hub-sites-raise-sharepoints-intranet-potential](https://www.slideshare.net/sharePTkarm/spsnyc-how-hub-sites-raise-sharepoints-intranet-potential-107836497)
- [the-intranet-managers-guide-to-office-365-sharepoint-hub-sites](https://www.habaneroconsulting.com/stories/insights/2018/the-intranet-managers-guide-to-office-365-sharepoint-hub-sites)
- [common-use-cases-for-office-365-sharepoint-hub-sites](https://www.habaneroconsulting.com/stories/insights/2018/common-use-cases-for-office-365-sharepoint-hub-sites)
- [architecture-considerations-and-quick-reference-tips-for-office-365s-sharepoint-hub-sites](https://www.habaneroconsulting.com/stories/insights/2018/architecture-considerations-and-quick-reference-tips-for-office-365s-sharepoint-hub-sites)
- [How to Create Hub Sites in SharePoint Online](https://sharepointmaven.com/how-to-create-hub-sites-in-sharepoint-online/)

## Planning

- <https://docs.microsoft.com/en-us/sharepoint/planning-hub-sites>

## Integration

- [sharepoint-hub-sites-make-their-debut](http://ericoverfield.com/sharepoint-hub-sites-make-their-debut/)
- [Organize-your-intranet-with-SharePoint-hub-sites](https://techcommunity.microsoft.com/t5/SharePoint-Blog/Organize-your-intranet-with-SharePoint-hub-sites/ba-p/174081)
- [Planning your SharePoint hub sites](https://support.office.com/en-us/article/planning-your-sharepoint-hub-sites-4e95dcd8-7e79-4732-aa9b-2f351031b4c2?ui=en-US&rs=en-US&ad=US)

## Navigation

- [Security Trimmed Hub Site Navigation Updates!](https://beaucameron.net/2018/04/17/security-trimmed-hub-site-navigation-updates/)
- [security-trimmed-hub-navigation](http://www.aerieconsulting.com/blog/security-trimmed-hub-navigation)
- [manage-sharepoint-communication-sites-megamenu-with-csom-and-powershell](https://mattipaukkonen.com/2018/08/22/manage-sharepoint-communication-sites-megamenu-with-csom-and-powershell)
- [6 tips to get mega value from the new megamenu navigation for SharePoint](https://www.nngroup.com/articles/mega-menus-work-well/)

## Tips

-[Introducing the idea of Archive Hub Sites](https://n8d.at/blog/introducing-the-idea-of-archive-hub-sites/)

```Powershell
cls

$tenantAdmin = "https://contoso-admin.sharepoint.com"
$hubSite = "https://contoso.sharepoint.com/sites/hub"
$extensionGUID = "6da1a9e8-471d-4f39-80e6-a7ded02e8881"
$extensionName = "Extension Name"
$extensionTitle = "Extension Title"

try
{
Connect-PnPOnline -Url $tenantAdmin -UseWebLogin
} catch {
Write-Host "Unable to connect."
exit
}

$HubSite = Get-PnPHubSite $hubSite
$HubSiteId = $HubSite.SiteId
$ModernSites = (Get-PnPTenantSite -Template 'GROUP#0') + (Get-PnPTenantSite -Template 'SITEPAGEPUBLISHING#0')
$SitesFromHub = New-Object System.Collections.ArrayList

Write-Host ("Searching {0} sites:" -f $HubSite.Title) -BackgroundColor Gray
foreach ($ModernSite in $ModernSites){
    $site = Get-PnPHubSite $ModernSite.Url
    if($site.SiteUrl){
    if($site.SiteId -eq $HubSiteId){
            Write-Host ("* {0} - {1}" -f $ModernSite.Title, $ModernSite.Url)
            $SitesFromHub.Add($ModernSite) | Out-Null
        }
    }
}

Write-Host ""
Write-Host "Installing at:" -BackgroundColor Gray
foreach ($SiteHub in $SitesFromHub){
    Write-Host ("* {0} - {1} ... " -f $SiteHub.Title, $SiteHub.Url) -NoNewline
    Connect-PnPOnline -Url $SiteHub.Url -UseWebLogin
    Add-PnPCustomAction -ClientSideComponentId $extensionGUID -Name $extensionName -Title $extensionTitle -Location ClientSideExtension.ApplicationCustomizer -Scope site
    Write-Host "Done" -BackgroundColor Green
    Disconnect-PnPOnline
}

Write-Host "All Done"
```

## CSOM

- [working-with-sharepoint-online-hub](https://www.vrdmn.com/2018/03/working-with-sharepoint-online-hub.html)

## Search API

- [working-with-hub-sites-and-search-api](https://www.techmikael.com/2018/04/working-with-hub-sites-and-search-api.html)
- [How to get all sites](https://sharepoint.stackexchange.com/questions/261222/spfx-and-pnp-sp-how-to-get-all-sites?atw=1)

```Powershell
 # List all sites being a hub site or associate to a hub site
$results = Submit-PnPSearchQuery -Query 'contentclass=sts_site' -RefinementFilters 'departmentid:string("{*",linguistics=off)' -TrimDuplicates $false -SelectProperties @("Title","Path","DepartmentId","SiteId") -All -RelevantResults

# Filter out the hub sites
$hubSites = $results |? { $_.DepartmentId.Trim('{','}') -eq $_.SiteId  }

# Loop over the hub sites
foreach( $hub in $hubSites ) {
    Write-Host $hub.Title - $hub.Path -ForegroundColor Green
    # Filter out sites associated to the current hub
    $associatedSites = ($results |? { $_.DepartmentId -eq $hub.DepartmentId -and $_.SiteId -ne $hub.SiteId })
    foreach($site in $associatedSites) {
        Write-Host "`t"$site.Title - $site.Path -ForegroundColor Yellow
    }
}
```
