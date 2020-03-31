# https://joelfmrodrigues.wordpress.com/2020/03/31/send-sharepoint-items-to-second-stage-recycle-bin-with-pnp-powershell/

#Connect to SPO
Connect-PnPOnline -Url https://contoso.sharepoint.com/sites/Test -UseWebLogin
 
#Store in variable all the document libraries in the site
$DocLibrary = Get-PnPList | Where-Object { $_.BaseTemplate -eq 101 } 
$LogFile = "C:\users\$env:USERNAME\Desktop\SPOEmptyFoldersAndDocuments.csv"
 
$results = @()
foreach ($DocLib in $DocLibrary) {
    #Get list of all folders and documents in the document library
    $AllItems = Get-PnPListItem -PageSize 1000 -List $DocLib -Fields "SMTotalFileStreamSize", "Author", "ID"
     
    #Loop through each files/folders in the document library for folder size = 0
    foreach ($Item in $AllItems) {
        if ((([uint64]$Item["SMTotalFileStreamSize"]) -eq 0)) {
 
            Write-Host "Empty folder/file:" $Item["FileLeafRef"] -ForegroundColor Yellow
                 
            #Creating object to export in .csv file
            $results += [pscustomobject][ordered] @{
                CreatedDate      = [DateTime]$Item["Created_x0020_Date"]
                FileName         = $Item["FileLeafRef"] 
                CreatedBy        = $Item.FieldValues.Author.LookupValue
                FilePath         = $Item["FileRef"]
                SizeInMB         = ($Item["SMTotalFileStreamSize"] / 1MB).ToString("N")
                LastModifiedBy   = $Item.FieldValues.Editor.LookupValue
                EditorEmail      = $Item.FieldValues.Editor.Email
                LastModifiedDate = [DateTime]$Item["Modified"]
            }
 
            #Remove item - send to first-level recycle bin
            Remove-PnPListItem -List $DocLib -Identity $Item["ID"] -Recycle -Force
            #Generate relative path in the same format as used by the recycle bin. Example: sites/Test/Shared Documents
            $path = $Item["FileRef"].substring(1) # remove first '/' from path as recycle bin items don't start with '/'
            $path = $path.substring(0, $path.LastIndexOf('/')) # remove folder name and last '/'
            #Get previously deleted item from first stage recycle bin using path and title
            $deletedItem = Get-PnPRecycleBinItem -FirstStage -RowLimit 1 | Where-Object { $_.DirName -Eq $path -and $_.Title -Eq $Item["FileLeafRef"]}
            #Move item to second-stage recycle bin
            Move-PnpRecycleBinItem -Identity "$($deletedItem.Id)" -Force
             
            Invoke-PnPQuery
 
        }#end of IF statement
    }
}
$results | Export-Csv -Path $LogFile -NoTypeInformation