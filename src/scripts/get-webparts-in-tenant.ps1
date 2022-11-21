#Purpose: locate all pages that contains a web part ( for checking number of returned items + duplicat check)

function Get-ReportPages ($pages, $url) 
{
    foreach($page in $pages)
    {

        $file = $page.FieldValues["FileLeafRef"]

        Write-Host " Processing Page $($file)" -ForegroundColor Cyan

        # Get-PnPPageComponent -Page $file -ListAvailable

        if ($file.contains('.aspx')){

            $components = Get-PnPPageComponent -Page $file

            # You can filter based on type of web part
            # c1f03ea7-64d1-4ffc-8a80-dee0a78770dc MgbToolsWebPart
            # e279c734-4a72-496d-8092-35a2bf5a9692 MgbMyToolsWebPart
            $mgbToolWp = $components | Where-Object { $_.WebPartId -eq 'c1f03ea7-64d1-4ffc-8a80-dee0a78770dc'}
            $mgbMyToolWp = $components | Where-Object { $_.WebPartId -eq 'e279c734-4a72-496d-8092-35a2bf5a9692'}
            Write-Host "$($mgbToolWp.Count) MgbToolsWebPart : $($mgbMyToolWp.Count) MgbMyToolsWebPart : $($url)" -ForegroundColor Yellow
    
        } else {
            Write-Host " No Page $($file)" -ForegroundColor Red        
        }


    }

}


$hits = New-Object -TypeName "System.Collections.ArrayList"
$cred = Get-Credential
$tenantUrl =  "https://[tenant]-admin.sharepoint.com"  
$tenantConn = Connect-PnPOnline -Url $tenantUrl -Credentials $cred -ReturnConnection

# get all Groups and Communication sites
# Get-PnPTenantSite | Where -Property Template -In ("GROUP#0", "SITEPAGEPUBLISHING#0")

# get all Groups sites
# $groupsSites = "GROUP#0"

# get all communication sites
$commSites = "SITEPAGEPUBLISHING#0"

$arraySiteCollection = Get-PnPTenantSite -Template $commSites -Connection $tenantConn

Disconnect-PnPOnline -Connection $tenantConn

$arraySiteCollection.Count

foreach($itemSiteCollection in $arraySiteCollection)
{
    $itemSiteCollection.Url
    Connect-PnPOnline -Url $itemSiteCollection.Url -Credentials $cred
    $pages = Get-PnPListItem -List "SitePages" 

    if ($pages) {
        Get-ReportPages -pages $pages -url $itemSiteCollection.Url
    }

}

# $hits | Export-Csv -Path C:\temp\searchwebpartswithtrimming.csv -Encoding UTF8 -Delimiter ";" -Force -NoTypeInformation