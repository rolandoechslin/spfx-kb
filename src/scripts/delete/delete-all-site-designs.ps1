$adminUrl = "https://mytenant-admin.sharepoint.com"
$sparksjoy = "Project Site", "Issues List"

Connect-PnPOnline $adminUrl -UseWebLogin

$siteDesigns = Get-PnPSiteDesign | where { -not ($sparksjoy -contains $_.Title) }

if ($siteDesigns.Count -eq 0) { break }

$siteDesigns | Format-Table Title, SiteScriptIds, Description

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $siteDesigns.Count

foreach ($siteDesign in $siteDesigns) 
{
    $progress++
    write-host $progress / $total":" $siteDesign.Title

    Remove-PnPSiteDesign -Identity $siteDesign.Id -Force
}