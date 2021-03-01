# Source: https://github.com/pnp/powershell/discussions/347

$ListList = (Get-PnPList -Includes IsSystemList).Where({$_.IsSystemList -EQ $false})
Foreach ($List in $ListList) {
   Get-PnPListItem -List $List -PageSize 1000 | Set-PnPListItemPermission -InheritPermissions -List $List
}