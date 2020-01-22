# Source: https://laurakokkarinen.com/does-it-spark-joy-powershell-scripts-for-keeping-your-development-environment-tidy-and-spotless/

$adminUrl = "https://mytenant-admin.sharepoint.com"
$sparksjoy = "Cat Lovers United", "Extranet", "Hub"

Connect-PnPOnline -Url $adminUrl -UseWebLogin

$sites = Get-PnPTenantSite | where { $_.template -eq "SITEPAGEPUBLISHING#0" -or $_.template -eq "STS#3" -and -not ($sparksjoy -contains $_.Title)} # -or $_.template -eq "GROUP#0"

if ($sites.Count -eq 0) { break }

$sites | Format-Table Title, Url, Template

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $sites.Count

foreach ($site in $sites) 
{
    $progress++
    write-host $progress / $total":" $site.Title

    Remove-PnPTenantSite -Url $site.Url -Force
}