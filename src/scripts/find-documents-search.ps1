# Original: http://www.sharepointdiary.com/2018/02/sharepoint-online-find-all-documents-using-keyword-query-powershell.html

#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Search.dll"
 
#Config Variables
$SiteURL="https://crescenttech.sharepoint.com/"
$SearchQuery= "path:https://crescenttech.sharepoint.com AND IsDocument:true AND (NOT FileType:aspx)"
$CSVFile = "C:\Temp\SearchResults.csv"
 
Try {
    $Cred= Get-Credential
    $Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
  
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    $Ctx.Credentials = $Credentials
     
    #Define Keyword
    $KeywordQuery = New-Object Microsoft.SharePoint.Client.Search.Query.KeywordQuery($Ctx)
    $KeywordQuery.QueryText = $SearchQuery
    $KeywordQuery.RowLimit  = 500
    $keywordQuery.SelectProperties.Add("CreatedBy")
    $keywordQuery.SelectProperties.Add("LastModifiedTime")
    $keywordQuery.SortList.Add("LastModifiedTime","Asc")
 
    #Execute Search       
    $SearchExecutor = New-Object Microsoft.SharePoint.Client.Search.Query.SearchExecutor($Ctx)
    $SearchResults = $SearchExecutor.ExecuteQuery($KeywordQuery)
    $Ctx.ExecuteQuery()
 
    Write-host "Search Results Found:"$SearchResults.Value[0].ResultRows.Count
 
    #Get Search Results
    If($SearchResults)
    {
        $Results = @()
        foreach($Result in $SearchResults.Value[0].ResultRows)
        {
            $Results += New-Object PSObject -Property @{
                        'Document Name' =  $Result["Title"]
                        'URL' = $Result["Path"]
                        'Created By' = $Result["CreatedBy"] 
                        'Last Modified' = $Result["LastModifiedTime"]              
                        }
        }
        $Results
        #Export search results to CSV
        $Results | Export-Csv $CSVFile -NoTypeInformation
        Write-Host -f Green "Search Results Exported to CSV File!"
    }
}
Catch {
    write-host -f Red "Error Getting Search Results!" $_.Exception.Message
}
