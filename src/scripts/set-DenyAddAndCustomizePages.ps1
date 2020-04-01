## SOurce: https://spdcp.com/2020/03/26/access-denied-error-on-styles-library/

Import-Module -Name SharePointPnPPowerShellOnline -DisableNameChecking
 $adminUrl = "https://mytenant-admin.sharepoint.com/"
$siteurl = "https://mytenant.sharepoint.com/sites/MySiteUrl"
 
Connect-PnPOnline -Url $adminUrl -Credentials (Get-Credential)
  
$DenyAddAndCustomizePagesStatusEnum = [Microsoft.Online.SharePoint.TenantAdministration.DenyAddAndCustomizePagesStatus]
  
$context = Get-PnPContext
$site = Get-PnPTenantSite -Detailed -Url $siteurl
  
$site.DenyAddAndCustomizePages = $DenyAddAndCustomizePagesStatusEnum::Disabled
  
$site.Update()
$context.ExecuteQuery()
  
Disconnect-PnPOnline