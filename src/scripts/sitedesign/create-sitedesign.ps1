# https://blog.eardley.org.uk/2020/02/site-design-deployment-made-easy/

Remove-Module CPSSiteDesign-Functions
Import-Module -Name ".\CPSSiteDesign-Functions" -Verbose

$ShowDebug = $false
$SiteScripts = @("Remove")
$CSVPath = $PSScriptRoot + "\CSV\Intranet.csv"
$CSV = Import-Csv -Path $CSVPath

$hubSiteUrl = "https://$TenantName.sharepoint.com/sites/AE-Intranet"

foreach ($Row in $CSV) {
    $SiteScriptTitle = $Row.Title
    $SiteScriptDescription = $Row.Description
    $SiteScriptFile = $PSScriptRoot + $Row.File
    $HubJoin = $Row.HubJoin
    
    if ($ShowDebug) {
        Write-Host "SiteScriptTitle: $SiteScriptTitle" -ForegroundColor Yellow
        Write-Host "SiteScriptDescription: $SiteScriptDescription" -ForegroundColor Yellow
        Write-Host "SiteScriptFile: $SiteScriptFile" -ForegroundColor Yellow
        Write-Host "HubJoin: $HubJoin" -ForegroundColor Yellow
    }

    if ($HubJoin -eq "Yes") {
        $SiteScripts = Set-CPSSiteScriptWithHubJoin `
            -Title $SiteScriptTitle `
            -Description $SiteScriptDescription `
            -File $SiteScriptFile `
            -HubSiteUrl $hubSiteUrl `
            -SiteScripts $SiteScripts `
            -ShowDebug $ShowDebug
    }

    if ($HubJoin -eq "No") {
        $SiteScripts = Set-CPSSiteScript `
            -Title $SiteScriptTitle `
            -Description $SiteScriptDescription `
            -File $SiteScriptFile `
            -SiteScripts $SiteScripts `
            -ShowDebug $ShowDebug
    }

    if ($ShowDebug) {
        Write-Host "Hub: $SiteScripts" -ForegroundColor Yellow
    }
}

if ($ShowDebug) {
    Write-Host "Remove the initial entry in the Site Scripts array" -ForegroundColor Yellow
}
$TidySiteScripts = {$SiteScripts}.Invoke()
$TidySiteScripts.Remove("Remove")

if ($ShowDebug) {
    Write-Host "Set Site Design" -ForegroundColor Yellow
}
$SiteDesign = $null
$SiteDesign = Set-CPSSiteDesign `
    -Title "AE - Intranet Site" `
    -Description "Creates an Intranet site" `
    -SiteScripts $TidySiteScripts `
    -WebTemplate "68" `
    -ShowDebug $ShowDebug

if ($ShowDebug) {
    Write-Host "Site Design: $SiteDesign" -ForegroundColor Yellow
}