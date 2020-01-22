$adminUrl = "https://mytenant-admin.sharepoint.com"

Connect-PnPOnline -Url $adminUrl -UseWebLogin
 
$deletedSites = Get-PnPTenantRecycleBinItem

if ($deletedSites.Count -eq 0) { break }

$deletedSites | Format-Table Url

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$total = $deletedSites.Count
$progress = 0

foreach ($deletedSite in $deletedSites)
{
	$progress++
	write-host $progress / $total":" $deletedSite.Url

	Clear-PnPTenantRecycleBinItem -Url $deletedSite.Url -Force
}