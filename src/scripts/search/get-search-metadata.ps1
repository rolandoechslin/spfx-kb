# Source: https://www.m365-dev.com/2020/04/08/script-to-update-metadata-term-instances-on-all-sharepoint-documents-and-folders/

$siteUrl = "https://contoso.sharepoint.com/sites/Home"
# ampersand: ＆
$oldTerm = "My old term label" -replace '&amp;', '＆'
$newTerm = "My new term label" -replace '&amp;', '＆'
$listColumn = "MyCustomField"
$termPath = "My Term Group|My Term Set|"
$Query = "* RefinableString01=""$oldTerm"""
$LogFile = "C:\users\$env:USERNAME\Desktop\UpdatedItems.csv"
# ---------------------------------
Connect-PnPOnline -Url $siteUrl -UseWebLogin
$SearchResults = Submit-PnPSearchQuery -Query $query -All -TrimDuplicates $false -SelectProperties ListItemID, ContentTypeId 
# $SearchResults
$results = @()
foreach ($ResultRow in $SearchResults.ResultRows) {
     
    $itemId = $ResultRow["ListItemID"]
    $library = $ResultRow["ParentLink"].Split("/")[5] # quick way to get library from path
    $contentTypeId = $ResultRow["ContentTypeId"]
    $path = $ResultRow["Path"]
    $parentLink = $ResultRow["ParentLink"]
    $type = ""
    Write-Host "Path: $path"
    if ($contentTypeId -like '0x0101*') {
        Write-Host "Document" -ForegroundColor Yellow
        $type = 'Document'     
    }
    if ($contentTypeId -like '0x0120*') {
        Write-Host "Folder" -ForegroundColor Yellow
        $type = 'Folder'
    }
    # Get list item
    $listItem = Get-PnPListItem -List $library -Id $itemId -Fields $listColumn
    if ($null -ne $listItem[$listColumn]) {
         
        # Generate new value for the field
        $termsWithPath = $null
        if ($listItem[$listColumn].Count -gt 1) {
            # check current value, in case search index is not updated
            if ($listItem[$listColumn].Label -contains $oldTerm) {
                # If multi-value, create an array of terms, and replace the old term by the new one
                $termsWithPath = @()
                foreach ($term in $listItem[$listColumn]) {
                    if ($term.Label -eq $oldTerm) {
                        $termsWithPath += $termPath + $newTerm
                    }
                    else {
                        $termsWithPath += $termPath + $term.Label
                    }
                }
            }
            else {
                Write-Host "Skipped: multi-value field does not contain term" -ForegroundColor Red
            }
        }
        else {
            # If single value, replace term
            # check current value, in case search index is not updated
            if ($listItem[$listColumn].Label -eq $oldTerm) {
                $termsWithPath = $termPath + $newTerm
            }
            else {
                Write-Host "Skipped: single-value field does not match term" -ForegroundColor Red
            }
        }
         
        if ($null -ne $termsWithPath) {
            # Update list item
            $termsWithPath
            Set-PnPListItem -List $library -Identity $itemId -SystemUpdate -Values @{"$listColumn" = $termsWithPath }
        }
    } 
    else { 
        Write-Host "Skipped: field is empty" -ForegroundColor Yellow
    }
    Write-Host "-------------" -ForegroundColor Yellow
    #Creating object to export in .csv file
    $results += [pscustomobject][ordered] @{
        Library    = $library
        ItemId     = $itemId
        Type       = $type
        ParentLink = $parentLink
        Path       = $path
    }
    # break
}
$results | Export-Csv -Path $LogFile -NoTypeInformation