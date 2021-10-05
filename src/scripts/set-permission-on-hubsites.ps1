# Source: https://sympmarc.com/2021/09/29/grant-permissions-to-all-communication-sites-associated-with-a-hub-site/

# Import modules
Import-Module PnP.PowerShell

# Base variables
$adminUrl = "https://tenant-admin.sharepoint.com/"
$HubSiteURL = "https://tenant.sharepoint.com/"

# Connect to the tenant
Connect-PnPOnline -Url $adminUrl -Interactive

# Get the sites associated with the Intranet Hub Site
$associatedSites = Get-PnPHubSiteChild -Identity $HubSiteURL | Sort-Object 

foreach ($site in $associatedSites) {
    Connect-PnPOnline -Url $site -Interactive
    $ownerGroup = (Get-PnPSiteGroup | Where-Object { $_.LoginName -like "*Owner*" })[0]
    $memberGroup = (Get-PnPSiteGroup | Where-Object { $_.LoginName -like "*Member*" })[0]
    Add-PnPGroupMember -LoginName "lester.frogbottom@tenant.com" -Group $ownerGroup.LoginName

}