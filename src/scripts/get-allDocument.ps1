#Read more: https://www.sharepointdiary.com/2018/08/sharepoint-online-powershell-to-get-all-files-in-document-library.html#ixzz76F2UsYsM

#Parameters
$SiteURL = "https://crescent.sharepoint.com/sites/mexico"
$ListName= "Documents"
$ReportOutput = "C:\Temp\mex-DocInventory.csv"
$Pagesize = 500
   
#Connect to SharePoint Online site
Connect-PnPOnline $SiteURL -UseWebLogin
 
#Delete the Output report file if exists
If (Test-Path $ReportOutput) { Remove-Item $ReportOutput}
 
#Array to store results
$Results = @()
   
#Get all Documents from the document library
$List  = Get-PnPList -Identity $ListName
$global:counter = 0;
$ListItems = Get-PnPListItem -List $ListName -PageSize $Pagesize -Fields Author, Editor, Created, File_x0020_Type -ScriptBlock `
        { Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete ($global:Counter / ($List.ItemCount) * 100) -Activity `
             "Getting Documents from Library '$($List.Title)'" -Status "Getting Documents data $global:Counter of $($List.ItemCount)";} | Where {$_.FileSystemObjectType -eq "File"}
  
$ItemCounter = 0
#Iterate through each item
Foreach ($Item in $ListItems)
{
        $Results += New-Object PSObject -Property ([ordered]@{
            Name              = $Item["FileLeafRef"]
            Type              = $Item.FileSystemObjectType
            FileType          = $Item["File_x0020_Type"]
            RelativeURL       = $Item["FileRef"]
            CreatedByEmail    = $Item["Author"].Email
            CreatedOn         = $Item["Created"]
            Modified         = $Item["Modified"]
            ModifiedByEmail    = $Item["Editor"].Email
        })
    $ItemCounter++
    Write-Progress -PercentComplete ($ItemCounter / ($List.ItemCount) * 100) -Activity "Exporting data from Documents $ItemCounter of $($List.ItemCount)" -Status "Exporting Data from Document '$($Item['FileLeafRef'])"        
}
  
#Export the results to CSV
$Results | Export-Csv -Path $ReportOutput -NoTypeInformation
   
Write-host "Document Library Inventory Exported to CSV Successfully!"
