
# Source: https://techcommunity.microsoft.com/t5/microsoft-365-pnp-blog/pnp-batch-versus-microsoft-graph-batch-in-powershell-to-add/ba-p/2761214

$action = Read-Host "Enter the action you want to perform, e.g. Add or Delete"
$siteUrl = "https://contoso.sharepoint.com/sites/Team1"
$listName = "TestDemo" 
$clientId = "00000000-0000-0000-0000-000000000000"
$thumbprint =  "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
#connect with application permissions
Connect-PnPOnline -ClientId $clientId  -Thumbprint $thumbprint -Tenant "contoso.onmicrosoft.com" -Url $siteUrl
write-host $("Start time " + (Get-Date)) 
$startTime = Get-Date
#site and list details
$siteID = (Get-PnPSite -Includes Id).Id
$listID = (Get-PnPList $listName).Id

$Total =  3000
$batchSize = 20
#bearer token for batch request
$token = Get-PnPGraphAccessToken

$Stoploop = $false
$Retrycount = 0 
$requests = @()
$header = @{ "Content-Type" = "application/json" }
do {
try {
if($action -eq "Add")
{   
   $lst = Get-PnPList -Identity $listName
    if($lst.ItemCount -lt $Total)
    {
      $startInc = $lst.ItemCount
      $itemsCountToCreate = $Total - $startInc
      for($i=$startInc;$i -lt ($Total);$i++)
        {
            $request = @{
              id      = $i
              method  = "POST"
              url     = "/sites/$siteID/lists/$listID/items/"
              body = @{ fields = @{ Title = "Test $i" } }
              headers = $header
            } 
            $requests += $request
       if($requests.count -eq $batchSize -or $requests.count -eq $itemsCountToCreate)
       { 
         $batchRequests = @{
         requests = $requests
        }
        #IMPORTANT: use -Deph parameter
        $batchBody = $batchRequests | ConvertTo-Json -Depth 4
        #send batch request
        $response = Invoke-WebRequest -Method Post -Uri 'https://graph.microsoft.com/v1.0/$batch' -Headers @{Authorization = "Bearer $($token)" } -ContentType "application/json" -Body $batchBody -ErrorAction Stop
        $StatusCode = $Response.StatusCode
       # This will only execute if the Invoke-WebRequest is successful.  
         #write-host $("$StatusCode response for adding 20")
         #reset batch item counter and requests array
         $requests = @()
         $itemsCountToCreate = $itemsCountToCreate - $batchSize
         }
        }
       }
    $lst = Get-PnPList -Identity $listName
    $Stoploop = $true   
}

if($action -eq "Delete")
{
   $requests = @()
   $listItems= Get-PnPListItem -List $listName -Fields "ID" -PageSize 1000  
   $itemCount = $listItems.Count
   for($i=$itemCount-1;$i -ge 0;$i--)
    {
          $itemId = $listItems[$i].Id 
            $request = @{
              id      = $i
              method  = "DELETE"
              url     = "/sites/$siteID/lists/$listID/items/$itemId"
              headers = $header
              }          
            $requests += $request 
       if($requests.count -eq $batchSize -or $requests.count -eq $itemCount)
       { 
          $batchRequests = @{
          requests = $requests
       }
         
        #IMPORTANT: use -Deph parameter
        $batchBody = $batchRequests | ConvertTo-Json -Depth 4
        #send batch request
        $response = Invoke-WebRequest -Method Post -Uri 'https://graph.microsoft.com/v1.0/$batch' -Headers @{Authorization = "Bearer $($token)" } -ContentType "application/json" -Body $batchBody
         #$StatusCode = $Response.StatusCode
       
         #write-host $("$StatusCode response for deleting 20")
         #reset batch item counter and requests array
         $requests = @()
         $itemCount = $itemCount - $batchSize
        }
      }
   }
 $Stoploop = $true
}
catch {
  if ($Retrycount -gt 3){
    Write-Host "Could not send Information after 3 retrys."
    $Stoploop = $true
}
else {
  Write-Host "Could not send Information retrying in 30 seconds..."
  write-host $("Time error happened " + (Get-Date)) 
  Write-host $("$_.Exception.Message") -ForegroundColor Red
  Start-Sleep -Seconds 30
   Connect-PnPOnline -ClientId $clientId -Thumbprint $thumbprint -Tenant "contoso.onmicrosoft.com" -Url $siteUrl
   $token = Get-PnPGraphAccessToken
   $Retrycount = $Retrycount + 1
  }
 }
}
While ($Stoploop -eq $false) 
$endTime = Get-Date
$totalTime = $endTime - $startTime
write-host "Total script run time: $($totalTime.Hours) hours, $($totalTime.Minutes) minutes, $($totalTime.Seconds) seconds" -ForegroundColor Cyan