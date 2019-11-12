# source: https://thechriskent.com/2019/11/11/extending-the-list-of-sites-you-can-embed-from-in-sharepoint-using-powershell/

$SiteUrls = @("HR","Accounting","IT")

foreach($SiteUrl in $SiteUrls) {

    Write-Host -ForegroundColor Cyan "Applying to $SiteUrl..."

    $FullSiteUrl = "https://superspecial.sharepoint.com/sites/$SiteUrl"

    Connect-PnPOnline $FullSiteUrl -ErrorAction Stop

    $site = Get-PnPSite -Includes CustomScriptSafeDomains
    $ctx = Get-PnPContext

    $ssDomain = [Microsoft.SharePoint.Client.ScriptSafeDomainEntityData]::new()
    $ssDomain.DomainName = "special.hosted.panopto.com"

    $site.CustomScriptSafeDomains.Create($ssDomain)

    $ctx.ExecuteQuery()

    Disconnect-PnPOnline
}