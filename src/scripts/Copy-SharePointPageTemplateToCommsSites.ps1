# Source : https://github.com/mpaukkon/SharePoint/blob/master/PowerShell/Copy-SharePointPageTemplateToCommsSites.ps1
# Blog: https://mattipaukkonen.com/2020/07/02/distribute-sharepoint-page-templates-with-pnp-powershell-and-provisioning-templates/

#Parameters
$tenant = "<tenant>.onmicrosoft.com"
$clientID = ""
$certificateThumbprint = ""
$templateSiteUrl = ""


$connection = Connect-PnPOnline -Url $templateSiteUrl -Tenant $tenant -ClientId $clientID -Thumbprint $certificateThumbprint -ReturnConnection
$sites = Get-PnPTenantSite -Template SITEPAGEPUBLISHING#0


$basetemplate = Get-PnPProvisioningTemplate -IncludeAllClientSidePages -Handlers PageContents,Pages -OutputInstance -Schema LATEST
$template = New-PnPProvisioningTemplate
foreach($page in $basetemplate.ClientSidePages)
{
    if($page.PromoteAsTemplate -eq $true)
    {
        $template.ClientSidePages.Add($page)
    }
        
}
Disconnect-PnPOnline -Connection $connection

foreach($site in $sites)
{
    $connection = Connect-PnPOnline -Url $site.Url -Tenant $tenant -ClientId $clientID -Thumbprint $certificateThumbprint -ReturnConnection
    Apply-PnPProvisioningTemplate -InputInstance $template -Connection $connection
   
}