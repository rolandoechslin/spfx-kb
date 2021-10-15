# https://sympmarc.com/2021/10/14/clean-up-unwanted-site-columns-from-content-types-and-lists-libraries/
# https://pnp.github.io/script-samples/spo-cleanup-site-column-usage/README.html?tabs=pnp-ps

# Import modules
Import-Module PnP.PowerShell

# Base variables
$siteURL = "https://tenant.sharepoint.com/sites/sitename"
$siteColumn = "EffectiveDate"
$reportOnly = $false # If $true, just report. If $false, take action.

# Connect to the tenant
$siteConnection = Connect-PnPOnline -Url $siteUrl -Interactive -ReturnConnection

# Remove the Site Column from all Content Types which have it
Write-Host -BackgroundColor Blue "Checking Content Types"

# Get all the Content Types. Here, I have all my custom Content Types in a Group called _ClientName.
$cts = Get-PnPContentType -Connection $siteConnection | Where-Object { $_.Group -eq "_ClientName" }

foreach ($ct in $cts) {

    Write-Host "Checking Content Type $($ct.Name)"

    $fields = Get-PnPProperty -ClientObject $ct -property "Fields" | Where-Object { $_.InternalName -eq $siteColumn }
    $field = $fields | Where-Object { $_.InternalName -eq $siteColumn }

    if ($field) {
        Write-Host -ForegroundColor Green "Found column $($siteColumn) in $($ct.Name)"
        if (!$reportOnly) {
            Write-Host -ForegroundColor Yellow "Removing column $($siteColumn) in $($ct.Name)"
            Remove-PnPFieldFromContentType -Field $field -ContentType $ct -Connection $siteConnection
        }
    }

}

# Remove the orphaned Site Column from all lists/libraries which have it
Write-Host -BackgroundColor Blue "Checking Lists"

# Get all lists/libraries in the site, but exclude System or Hidden lists
$lists = Get-PnPList -Connection $siteConnection | Where-Object { $_.Hidden -ne $true -and $_.IsSystemList -ne $true }

foreach ($list in $lists) {

    Write-Host "Checking list $($list.Title)"

    $field = Get-PnPField -List $list | Where-Object { $_.InternalName -eq $siteColumn }

    if ($field) {
        Write-Host -ForegroundColor Green "Found column $($siteColumn) in $($list.Title)"

        if (!$reportOnly) {
            Write-Host -ForegroundColor Yellow "Removing column $($siteColumn) in $($list.Title)"
            Remove-PnPField -Identity $field -List $list -Connection $siteConnection -Force
        }

    }

}

# Remove the Site Column itself
if (!$reportOnly) {
    Remove-PnPField -Identity $siteColumn
}