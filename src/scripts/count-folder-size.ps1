# Source: https://veronicageek.com/2019/get-nested-folders-files-count-folder-size/

#Connect to SPO
Connect-PnPOnline -Url "https://<TENANT-NAME>.sharepoint.com/sites/<YOUR-SITE>"

#My list target 
$myList = "/Shared Documents"

#Store the results
$results = @()

foreach ($list in $myList) {
    $allItems = Get-PnPListItem -List $list -Fields "FileLeafRef", "SMTotalFileStreamSize", "FileDirRef", "FolderChildCount", "ItemChildCount"
    
    foreach ($item in $allItems) {
        
        #Narrow down to folder type only
        if (($item.FileSystemObjectType) -eq "Folder") {
            $results += New-Object psobject -Property @{
                FileType          = $item.FileSystemObjectType 
                RootFolder        = $item["FileDirRef"]
                LibraryName       = $list 
                FolderName        = $item["FileLeafRef"]
                FullPath          = $item["FileRef"]
                FolderSizeInMB    = ($item["SMTotalFileStreamSize"] / 1MB).ToString("N")
                NbOfNestedFolders = $item["FolderChildCount"]
                NbOfFiles         = $item["ItemChildCount"]
            }
        }
    }
}
#Export the results
$results | Export-Csv -Path "C:\Users\$env:USERNAME\Desktop\NestedFoldersForONEdoclib.csv" -NoTypeInformation