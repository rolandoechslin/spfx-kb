# Source: https://techcommunity.microsoft.com/t5/sharepoint/configure-modern-search-results-to-search-all-of-your/m-p/447334
# Source: https://www.siolon.com/blog/update-multiple-sharepoint-online-sites-to-search-whole-tenant/

$csvFile = "C:\file.csv"
$creds = Get-Credential
$table = Import-Csv $csvFile -Delimiter ","
Write-Host "Begin"
foreach ($row in $table)
{
  Write-Host  $row.SiteCollection
  Connect-PnPOnline -Url $row.SiteCollection -Credentials $creds
  $web = Get-PnPWeb
  $web.SearchScope = 1 
  $web.Update()
  Invoke-PnPQuery
}
Write-Host "End"