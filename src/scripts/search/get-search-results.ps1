# Source: https://www.sharepointdiary.com/2019/03/sharepoint-online-run-search-query-using-pnp-powershell.html

#Config Variables
$SiteURL = "https://bls.sharepoint.com/sites/CloudSerachTest"
$SearchQuery = "Title:document* Path:" + $SiteURL
 
#Connect to PNP Online
Connect-PnPOnline -Url $SiteURL -UseWebLogin
 
#Run Search Query    
$SearchResults = Submit-PnPSearchQuery -Query $SearchQuery -All
 
$Results = @()
foreach($ResultRow in $SearchResults.ResultRows) 
{ 
    #Get All Properties from search results
    $Result = New-Object PSObject 
    $ResultRow.GetEnumerator()| ForEach-Object { $Result | Add-Member Noteproperty $_.Key $_.Value} 
    $Results+=$Result
}
$Results

