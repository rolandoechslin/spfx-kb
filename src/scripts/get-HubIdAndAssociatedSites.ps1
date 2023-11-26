$AdminCenterURL="https://contoso-admin.sharepoint.com"
$hubSiteUrl = "https://contoso.sharepoint.com"
 
Connect-PnPOnline $AdminCenterURL -Interactive
$adminConnection  = Get-PnPConnection

$HubSiteID = (Get-PnPTenantSite -Identity $hubSiteUrl -Connection $adminConnection ).HubSiteId
 
# Get associated sites with hub
$associatedSites = Get-PnPTenantSite -Detailed -Connection $adminConnection | Where-Object { $_.HubSiteId -eq $HubSiteID }

$associatedSites

Disconnect-PnPOnline
