# Source: https://sympmarc.com/2021/10/27/cleaning-up-redirect-sites-in-sharepoint-online/

# Import modules
Import-Module PnP.PowerShell

$adminSiteUrl = "https://tenantName-admin.sharepoint.com"

Connect-PnPOnline -Url $adminSiteUrl -Interactive

$redirectSites = Get-PnPTenantSite -Template "RedirectSite#0"

########################################################################
# STOP HERE - Validate the redirect sites you actually want to remove. #
########################################################################

foreach ($site in $redirectSites) {

    Remove-PnPTenantSite -Url $site.Url -Force    

    # $redirectSites = Get-PnPTenantSite -Template "RedirectSite#0" | Where-Object { $_.Url -eq "https://tenantName.sharepoint.com/sites/212"
    # or
    # $redirectSites = Get-PnPTenantSite -Template "RedirectSite#0" | Where-Object { $_.Url -gt "https://tenantName.sharepoint.com/sites/211" 
}