# Source: https://sympmarc.com/2022/11/28/find-all-the-stream-classic-web-parts-during-migration-to-stream-in-sharepoint/

# Connect to your tenant here. This should be the only change you need to make to use this script.
$tenant = "tenantname"
Connect-PnPOnline -Url "https://$($tenant)-admin.sharepoint.com" -Interactive

# Get all the sites to check

# Checking all the Communication Sites and Team Sites
# $sites = Get-PnPTenantSite | Where-Object { $_.Template -eq "SITEPAGEPUBLISHING#0" -or $_.Template -eq "GROUP#0" }
# Checking sites associated with the Intranet (Home Site)
$sites = Get-PnPHubSiteChild -Identity "https://$($tenant).sharepoint.com" | Sort-Object

# You may choose to exclude some subsets of sites
$filteredSites = $sites | Where-Object { $_ -eq "https://$($tenant).sharepoint.com/sites/Exec-BoardRelations" } 

foreach ($site in $filteredSites) {

    Write-Host -BackgroundColor White -ForegroundColor Black "Looking in $($site)"

    # Get the pages
    $siteConnection = Connect-PnPOnline -Url $site -Interactive -ReturnConnection
    $pages = Get-PnPListItem -Connection $siteConnection -List "Site Pages" | Where-Object { $_.FieldValues.File_x0020_Type -eq "aspx" } 

    foreach($page in $pages) {
        #Write-Host -BackgroundColor White -ForegroundColor Black "Checking $($page.FieldValues.FileLeafRef)"
        $streamPage = Get-PnPPageComponent -Page $page.FieldValues.FileLeafRef | Where-Object { $_.Title -eq "Stream" } | Select-Object Title, WebPartId
        if($streamPage) {
            Write-Host -BackgroundColor Green -ForegroundColor Black ">>> Found Stream Classic Web Parts in this page: $($page.FieldValues.Title) - $($page.FieldValues.FileDirRef)"
        }
    }

}