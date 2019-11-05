# Info : https://albandrodsmemory.wordpress.com/2019/11/05/disabling-teams-creation-prompt-in-sharepoint-online/

$tenant = "https://spotenant-admin.sharepoint.com"
$web = "https://spotenant.sharepoint.com/sites/Modernsposite"

Connect-PnPOnline -Url $tenant -SPOManagementShell
$site = Get-PnPTenantSite -Detailed -Url $web
if ($site.DenyAddAndCustomizePages -ne 'Disabled') {
    $site.DenyAddAndCustomizePages = 'Disabled'
    $site.Update()
    $site.Context.ExecuteQuery()
}

Set-PnPPropertyBagValue -Key 'TeamifyHidden' -Value 'True'