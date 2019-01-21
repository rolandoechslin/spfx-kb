# Original: https://capacreative.co.uk/2019/01/20/implementing-404-custom-page-on-communication-site/

$tenant = "<tenant>"
$site = "<site>"

$siteUrl = "https://$($tenant).sharepoint.com/sites/$($site)"

Write-Host "Setting 404 page at $($siteUrl)..."

# Connect to SharePoint Online with PnP PowerShell library
Connect-PnPOnline $siteUrl

# Disable NoScript
Write-Host "  Disabling NoScript" -ForegroundColor Cyan
Set-PnPTenantSite -Url $siteUrl -NoScriptSite:$false

# Sets the value in the property bag, note: ensure you have disabled NoScript
Write-Host "  Adding Property Bag Key" -ForegroundColor Cyan
Set-PnPPropertyBagValue -Key "vti_filenotfoundpage" -Value "/sites/$($site)/SitePages/Page-not-found.aspx"

# Enable NoScript
Write-Host "  Enabling NoScript" -ForegroundColor Cyan
Set-PnPTenantSite -Url $siteUrl -NoScriptSite

Write-Host "Script Complete! :)" -ForegroundColor Green