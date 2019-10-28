$loginUrl = "https://contoso.sharepoint.com/"
Connect-PnPOnline -Url $loginUrl -UseWebLogin
$appCatalog = Get-PnPTenantAppCatalogUrl
Connect-PnPOnline -Url $appCatalog -UseWebLogin

$items = Get-PnPListItem -List "Site Collection App Catalogs"
$count = 1
foreach($item in $items){
	Write-host $count "-" $item.FieldValues.Item("SiteCollectionUrl")
	$count = $count + 1 
}