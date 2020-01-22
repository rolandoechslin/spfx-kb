$adminUrl = "https://mytenant-admin.sharepoint.com"
$sparksjoy = "Project Site", "Issues List"

Connect-PnPOnline $adminUrl -UseWebLogin

$siteScripts = Get-PnPSiteScript | where { -not ($sparksjoy -contains $_.Title) }

if ($siteScripts.Count -eq 0) { break }

$siteScripts | Format-Table Title, Id

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $siteScripts.Count

foreach ($siteScript in $siteScripts) 
{
    $progress++
    write-host $progress / $total":" $siteScript.Title

    Remove-PnPSiteScript -Identity $siteScript.Id -Force
}