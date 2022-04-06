# https://sympmarc.com/2022/03/10/sharepoint-site-lock-and-remove-from-search-results/

$tenantName = "your tenant name here"
$spRoot = "https://$($tenantName).sharepoint.com"
$siteCollectionUrlFragment = "foo" # Part of the URL after /sites/, e.g., HRTeam, Marketing, etc.

# Work on this Site Collection
$siteCollection = "$(spRoot)/sites/$($siteCollectionUrlFragment)"

# Connect to Admin Center
$adminSiteUrl = "https://$($tenantName)-admin.sharepoint.com/"
$adminConnection = Connect-PnPOnline -Url $AdminSiteUrl -Interactive
 
# Connect to Site Collection
$siteCollectionConnection = Connect-PnPOnline -Url $siteCollection -Interactive

# Needed to set NoCrawl
Set-PnPSite -Identity $siteCollection -DenyAndAddCustomizePages $false
 
# Exclude Site Collection from Search Index
$Web = Get-PnPWeb -Connection $siteCollectionConnection
$Web.NoCrawl = $true
$Web.Update()
Invoke-PnPQuery

# Lock the site
Set-PnPSite -Identity $siteCollection -LockState ReadOnly