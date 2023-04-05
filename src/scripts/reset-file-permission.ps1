
# Source: https://pnp.github.io/script-samples/reset-files-permission-unique-to-inherited/README.html?tabs=pnpps

# Make sure necessary modules are installed
# PnP PowerShell to get access to M365 tenent

Install-Module PnP.PowerShell
$siteURL = "https://tenent.sharepoint.com/sites/Dataverse"

Connect-PnPOnline -Url $siteURL -Credentials (Get-Credential)
$listName = "Document Library"
#Get the Context
$Context = Get-PnPContext

try {
    ## Get all folders from given list
    $folders = Get-PnPFolder -List $listName
}
catch {
    ## Do this if a terminating exception happens
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    try {
        Write-Host "Trying to use Get-PnPListItem" -ForegroundColor Yellow
        #Treat the folder as item, and the item attribute is Folder (FileSystemObjectType -eq "Folder")  
    $folders = Get-PnPListItem -List $listName -PageSize 500 -Fields FileLeafRef | Where {$_.FileSystemObjectType -eq "Folder"}
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Output "Total Folder found $($Folders.Count)"
## Traverse all files from all folders.
foreach($folder in $folders){
    Write-Host "get all files from folder '$($folder.Name)'" -ForegroundColor DarkGreen
    $files = Get-PnPListItem -List $listName -FolderServerRelativeUrl $folder.ServerRelativeUrl -PageSize 500 
    Write-Host "Total Files found $($Files.Count) in folder $($folder.Name)" -ForegroundColor DarkGreen
    foreach ($file in $files){
        ## Check object type is file or folder.If file than do process else do nothing.
        if($file.FileSystemObjectType.ToString() -eq "File"){
            #Check File is unique permission or inherited permission.
            # If File has Unique Permission than below line return True else False
            $hasUniqueRole = Get-PnPProperty -ClientObject $file -Property HasUniqueRoleAssignments
            if($hasUniqueRole -eq $true){
                ## If File has Unique Permission than reset it to inherited permission from parent folder.
                Write-Output "Reset Permisison starting for file with id $($file.Id)" -ForegroundColor DarkGreen
                $file.ResetRoleInheritance()
                $file.update()
                $Context.ExecuteQuery()
            }
        }
    }
}
## Disconnect PnP Connection.
Disconnect-PnPOnline