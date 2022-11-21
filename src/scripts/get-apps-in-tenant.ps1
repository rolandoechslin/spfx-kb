Clear-Host


function Get-InstalledApps
{
    param (
        $siteUrl
    )

    Write-Host "[$($counter)] : Processing Site $($siteUrl)" -ForegroundColor Cyan

    Connect-PnPOnline -Url $siteUrl -Credentials $cred

    $web = Get-PnPWeb -Includes AppTiles

    $appTiles = $web.AppTiles
    Invoke-PnPQuery


    foreach($app in $appTiles) {
        # if ($app.Title -eq "mgb-incident-webpart") {
        if ($app | Where-Object -Property Title -In ("mgb-incident-webpart", "mgb-tools-webpart")) {

            $ReportLine = [PSCustomObject][Ordered]@{
                appSite             = $siteUrl
                appTitle            = $app.Title
                appProductIdd       = $app.ProductId
                appStatus           = $app.AppStatus
                appType             = $app.AppType
            }         
            $Report.Add($ReportLine)
        }

    }


    # $f = Get-PnPApp | Select-Object *

    # foreach($fg in $f) {

    #     if ($fg.Title -eq "mgb-tools-webpart") {

    #         $ReportLine = [PSCustomObject][Ordered]@{
    #             appSite                 = $siteUrl
    #             appTitle                = $fg.Title
    #             appId                   = $fg.Id
    #             appCatalogVersion       = $fg.AppCatalogVersion
    #             appCanUpgrade           = $fg.CanUpgrade
    #             appDeployed             = $fg.Deployed
    #             appIsClientSideSolution = $fg.IsClientSideSolution
    #         }         
    #         $Report.Add($ReportLine)
    #     }

    # }

}

$counter = 1
$outputReport = "C:\temp\apps-installed.csv"
$Report = New-Object -TypeName "System.Collections.ArrayList"
$cred = Get-Credential
$tenantUrl =  "https://[tenant]-admin.sharepoint.com"  
$tenantConn = Connect-PnPOnline -Url $tenantUrl -Credentials $cred -ReturnConnection

# get all Groups and Communication sites
$arraySiteCollection = Get-PnPTenantSite -Connection $tenantConn | Where-Object -Property Template -In ("GROUP#0", "SITEPAGEPUBLISHING#0")

# $commSites = "SITEPAGEPUBLISHING#0"
# $arraySiteCollection = Get-PnPTenantSite -Template $commSites -Connection $tenantConn

Disconnect-PnPOnline -Connection $tenantConn

$arraySiteCollection.Count

foreach($itemSiteCollection in $arraySiteCollection)
{
    Get-InstalledApps -siteUrl $itemSiteCollection.Url
    $counter++
}



$Report | Export-Csv -Path $outputReport -Encoding UTF8 -Delimiter "," -Force -NoTypeInformation

