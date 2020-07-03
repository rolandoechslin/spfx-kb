# Source: https://github.com/mpaukkon/SharePoint/blob/master/PowerShell/Copy-SharePointPageTemplateFromHub.ps1
# Blog: https://mattipaukkonen.com/2020/07/02/distribute-sharepoint-page-templates-with-pnp-powershell-and-provisioning-templates/

#Parameters
$tenant = "<tenant>.onmicrosoft.com"
$clientID = ""
$certificateThumbprint = ""
$hubSiteUrl = ""
$adminUrl = ""

$connection = Connect-PnPOnline -Url $hubSiteUrl -Tenant $tenant -ClientId $clientID -Thumbprint $certificateThumbprint -ReturnConnection
$hubSites = Get-PnPHubSiteChild -Identity $hubSiteUrl


$basetemplate = Get-PnPProvisioningTemplate -IncludeAllClientSidePages -Handlers PageContents,Pages -OutputInstance -Schema LATEST
$basetemplate.ClientSidePages.Count
$template = New-PnPProvisioningTemplate
foreach($page in $basetemplate.ClientSidePages)
{
    if($page.PromoteAsTemplate -eq $true)
    {
        $template.ClientSidePages.Add($page)
    }
        
}
Disconnect-PnPOnline -Connection $connection

foreach($site in $hubSites)
{
    $connection = Connect-PnPOnline -Url $site -Tenant $tenant -ClientId $clientID -Thumbprint $certificateThumbprint -ReturnConnection
    Apply-PnPProvisioningTemplate -InputInstance $template -Connection $connection
   
}