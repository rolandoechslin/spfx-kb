$tenantUrl = "https://mytenant-admin.sharepoint.com"
$sparksjoy = "Cat Lovers United", "Multicolored theme"

Connect-PnPOnline -Url $tenantUrl -UseWebLogin

$themes = Get-PnPTenantTheme | where {-not ($sparksjoy -contains $_.Name)}

$themes | Format-Table Name

if ($themes.Count -eq 0) { break }

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $themes.Count

foreach ($theme in $themes)
{
    $progress++
    write-host $progress / $total":" $theme.Name

    Remove-PnPTenantTheme -name $theme.Name
}