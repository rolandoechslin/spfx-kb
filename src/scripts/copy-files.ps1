# Source: https://veronicageek.com/microsoft-365/sharepoint-online/copy-or-move-files-not-folders-to-another-sharepoint-library-or-site-using-powershell-pnp/2021/04/

Connect-PnPOnline -Url "https://<TENANT-NAME>.sharepoint.com/sites/SitePnP1" -Credentials "<YOUR-CREDS>"

$allItems = Get-PnPListItem -List "Shared Documents" -FolderServerRelativeUrl "/sites/SitePnP1/Shared Documents"
foreach ($item in $allItems) {
    if ($item.FileSystemObjectType -eq "File") {
        Write-Host "Copying file: $($item.FieldValues.FileLeafRef)" -ForegroundColor green
        Copy-PnPFile -SourceUrl "$($item.FieldValues.FileRef)" -TargetUrl "/sites/SitePnP2/TargetLibrary" -Force
    }
}