
# Source: https://sharepoint.handsontek.net/2023/02/15/save-deploy-sharepoint-pages-templates/

# ==================================================================
# Export
# ==================================================================

$siteCollection = "https://contoso.sharepoint.com/sites/ProjectX"
$saveTemplateLocation = "C:\Users\JOAO\Desktop\"
$templateName = "template"

Connect-PnPOnline -Url $siteCollection -Interactive
$siteTemplate = Get-PnPSiteTemplate -IncludeAllClientSidePages -Handlers Pages,PageContents -OutputInstance 

$pagesTemplate = New-PnPSiteTemplate
foreach($page in $siteTemplate.ClientSidePages)
{
     if($page.PromoteAsTemplate -eq $true)
     {
          $pagesTemplate.ClientSidePages.Add($page)
     }
}

Save-PnPSiteTemplate -Template $pagesTemplate -Out ("{0}{1}.xml" -f $saveTemplateLocation, $templateName)


# ==================================================================
# Import
# ==================================================================

$siteCollection = "https://contoso.sharepoint.com/"
$templateFileLocation = "C:\Users\JOAO\Desktop\template.xml"

Connect-PnPOnline -Url $siteCollection -Interactive
Invoke-PnPSiteTemplate -Path $templateFileLocation