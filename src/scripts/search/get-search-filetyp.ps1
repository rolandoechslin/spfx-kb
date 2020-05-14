# Source: https://www.m365-dev.com/2020/05/13/find-sharepoint-documents-by-file-type/

# Variables
$siteUrl = "https://XXXXXXX.sharepoint.com/sites/XXXXXX"
$FileType = "doc*"
 
$Query = "* FileType=""$FileType"""
$LogFile = "C:\users\$env:USERNAME\Desktop\File Type - $FileType.csv"
 
# ---------------------------------
 
Connect-PnPOnline -Url $siteUrl -UseWebLogin
 
$SearchResults = Submit-PnPSearchQuery -Query $query -All -TrimDuplicates $false -SelectProperties ListItemID, Filename 
 
$results = @()
foreach ($ResultRow in $SearchResults.ResultRows) {
     
    $itemId = $ResultRow["ListItemID"]
    $filename = $ResultRow["Filename"]
    $path = $ResultRow["Path"]
    $parentLink = $ResultRow["ParentLink"]
    Write-Host "Path: $path"
 
    Write-Host "-------------" -ForegroundColor Yellow
 
    #Creating object to export in .csv file
    $results += [pscustomobject][ordered] @{
        ItemId     = $itemId
        Filename   = $filename
        ParentLink = $parentLink
        Path       = $path
    }
 
}
 
$results | Export-Csv -Path $LogFile -NoTypeInformation