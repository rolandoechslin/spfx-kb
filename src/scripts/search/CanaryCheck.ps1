# Input bindings are passed in via param block.
param($Timer)

# Source: https://github.com/kasperbolarsen/thecanaryinthecoalmine

# Search Index Freshness check
# set to start every X minutes
$siteUrl = "https://contoso.sharepoint.com/sites/SharePointSearchCanaryInTheCoalmine"
$listName = "SearchFreshNessTest"
$logginglistName = "SearchFreshNessTestLogginglist"

$ClientId = $env:ClientId
$thumbprint = $env:ThumbPrint
$tickvalueSearchField = "RefinableString125"

$conn = Connect-PnPOnline -Url $siteUrl -ClientId $ClientId -thumbprint $thumbprint -Tenant "contoso.onmicrosoft.com" -ReturnConnection


function LogToSeachIndexLoggingList ($message, $isOK, $minutes)
{
    $logginglist = Get-PnPList -Identity $logginglistName -Connection $conn
    if(-not $logginglist)
    {
        $logginglist = New-PnPList -Title $logginglistName -Template GenericList -Url $logginglistName -OnQuickLaunch -Connection $conn
        try 
        {
            $statusField = Get-PnPField -List $logginglistName -Identity "StatusField" -ErrorAction Stop -Connection $conn
        }
        catch 
        {
            Add-PnPField -List $logginglistName -Type Boolean -InternalName "search_StatusField" -AddToDefaultView -Required -DisplayName "ValueWasFoundUsingSearch" -Connection $conn
            Add-PnPField -List $logginglistName -Type Text -InternalName "search_MinutesField" -AddToDefaultView -Required -DisplayName "Minutes" -Connection $conn
        }
        $view = Get-PnPView -List $logginglistName -Connection $conn
        Remove-PnPView -List $logginglistName -Identity $view -Force -Connection $conn
        $Query="<OrderBy><FieldRef Name='Created' Ascending='FALSE'/></OrderBy>"
        Add-PnPView -List $logginglistName -Title "FreshnessView" -ViewType None -Fields "Title","ValueWasFoundUsingSearch","Minutes","Created"  -Query $Query -Connection $conn

     
    }
    Add-PnPListItem -List $logginglistName -Values @{"Title" = $message;"search_StatusField" = $isOK;"search_MinutesField" = $minutes} -Connection $conn
    
    
}
function isSetupCompleted 
{
    $list = Get-PnPList -Identity $listName -Connection $conn
    if(-not $list)
    {
        $list = New-PnPList -Title $listName -Template GenericList -Url $listName -OnQuickLaunch -Connection $conn
        try 
        {
            $tickField = Get-PnPField -List $list -Identity "TickField" -ErrorAction Stop -Connection $conn
        }
        catch {
            
            Add-PnPField -List $list -Type Text -InternalName "search_tickfield" -AddToDefaultView -Required -DisplayName "Ticks" -Connection $conn
        }
    }
    
    
        
}
isSetupCompleted

$date = [System.DateTime]::UtcNow
$ticks = $date.Ticks

$item = Get-PnPListItem -List $listName -Connection $conn -ErrorAction Stop
if(-not $item)
{
    Add-PnPListItem -List $listName -Values @{"Title"= "test" ; "search_tickfield" = $ticks} -Connection $conn
    return
}
else 
{
    $itemLastUpdated = $item["Modified"]  
    $itemTicksValue = $item["search_tickfield"]  
}

#check if the item from search has the same values
$querypath = "$siteUrl/$listName"
$itemquerypath = "$querypath/DispForm.aspx?ID=$($item.Id)"

$results = Submit-PnPSearchQuery -Query "path:$itemquerypath" -All -TrimDuplicates $false -SelectProperties @($tickvalueSearchField) -Connection $conn -ErrorAction Stop

$results.ResultRows.count

$ticksFromSearch = $results.ResultRows[0][$tickvalueSearchField]

$minutes =  $date - $itemLastUpdated
$numberofminutes = $minutes.Days*60*24 + $minutes.Hours*60 + $minutes.Minutes
if($ticksFromSearch -eq $itemTicksValue)
{
    #the values are identical so the item has been indexed recently
    LogToSeachIndexLoggingList -message "Item was updated at $itemLastUpdated and FOUND in Search at $date" -isOK $true -minutes $numberofminutes
    Set-PnPListItem -List $listName -Identity $item.Id -Values @{"search_tickfield" = $ticks} -Connection $conn
}
else 
{
    #the item has not been reindexed resently :-(
    LogToSeachIndexLoggingList -message "Item was updated at $itemLastUpdated and not found in Search at $date" -isOK $false -minutes $numberofminutes

    if($numberofminutes -gt 30)
    {
        Send-PnPMail -To "Admin@contoso.onmicrosoft.com" -Subject "The canary is not looking well" -Body "Item was updated at $itemLastUpdated and not found in Search at $date" -Connection $conn
    }

}
