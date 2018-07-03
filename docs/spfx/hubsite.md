# HubSite

## Integration

- [sharepoint-hub-sites-make-their-debut](http://ericoverfield.com/sharepoint-hub-sites-make-their-debut/)
- [Organize-your-intranet-with-SharePoint-hub-sites](https://techcommunity.microsoft.com/t5/SharePoint-Blog/Organize-your-intranet-with-SharePoint-hub-sites/ba-p/174081)

## Navigation

 - [security-trimmed-hub-navigation](http://www.aerieconsulting.com/blog/security-trimmed-hub-navigation)

 ## CSOM

 - [working-with-sharepoint-online-hub](https://www.vrdmn.com/2018/03/working-with-sharepoint-online-hub.html)

 ## Search API

 - [working-with-hub-sites-and-search-api](https://www.techmikael.com/2018/04/working-with-hub-sites-and-search-api.html)

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
