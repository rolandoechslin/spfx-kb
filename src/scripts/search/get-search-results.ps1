# Source: https://www.sharepointdiary.com/2019/03/sharepoint-online-run-search-query-using-pnp-powershell.html

# Config Variables
$Tenant = "<name>"
$AdminSiteURL = "https://$($Tenant)-admin.sharepoint.com"
$SiteURL = "https://$($Tenant).sharepoint.com/sites/CloudSerachTest"
$SearchQuery = "Title:Austausch* Path:" + $SiteURL
 
# Connect to PNP Online
# Connect-PnPOnline -Url $SiteURL -UseWebLogin
Connect-PnPOnline -Url $AdminSiteURL -UseWebLogin
 
# ---------------------------------------------------------------------------------------
# Run Search Query
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/submit-pnpsearchquery?view=sharepoint-ps
# https://support.office.com/en-gb/article/about-the-crawl-log-880822ee-5c4b-4f6a-bfe1-27285597b2db
# https://www.techmikael.com/2018/06/
# ---------------------------------------------------------------------------------------

# $SearchResults = Submit-PnPSearchQuery -Query $SearchQuery -All
 
# $Results = @()
# foreach($ResultRow in $SearchResults.ResultRows) 
# { 
#     # Get All Properties from search results
#     $Result = New-Object PSObject 
#     $ResultRow.GetEnumerator()| ForEach-Object { $Result | Add-Member Noteproperty $_.Key $_.Value} 
#     $Results+=$Result
# }
# $Results

# ---------------------------------------------------------------------------------------
# Search Logs
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/get-pnpsearchcrawllog?view=sharepoint-ps
# ---------------------------------------------------------------------------------------

# Get-PnPSearchCrawlLog -Filter $SiteURL -RowLimit 10


# ---------------------------------------------------------------------------------------
# Search Configuration
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/get-pnpsearchconfiguration?view=sharepoint-ps
# ---------------------------------------------------------------------------------------

# all
# Get-PnPSearchConfiguration -Path searchconfig.xml -Scope Subscription

# ---------------------------------------------------------------------------------------
# Search Settigns
# https://docs.microsoft.com/en-us/powershell/module/sharepoint-pnp/get-pnpsearchconfiguration?view=sharepoint-ps
# ---------------------------------------------------------------------------------------

# Get-PnPSearchSettings

# Classic Search Center URL             :
# Redirect search URL                   :
# Site Search Scope                     : DefaultScope
# Site collection search box visibility : Inherit
# Site search box visibility            : Inherit
