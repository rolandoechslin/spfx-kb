param
(
    [Parameter(Mandatory=$true)]
    [string]$teamID,
    [Parameter(Mandatory=$true)]
    [string]$SiteUrl
)

Connect-PnPOnline -AppId $global:AppID -AppSecret $global:AppSecret -AADDomain $global:tenantConfig.Settings.Azure.AADDomain
Write-Output "Connecting to $($global:tenantConfig.Settings.Tenant.TenantRootUrl)"
$accessToken = Get-PnPAccessToken

$header = @{
  "Content-Type" = "application/json"
  Authorization = "Bearer $accessToken"
}
$requestUrl = "https://graph.microsoft.com/v1.0/teams/$teamID/channels"
$requestUrl += '?$filter=displayName eq '
$requestUrl +=  "'General'"
$channelResponse = Invoke-RestMethod -Uri $requestUrl -Method Get -Headers $header
$channelID = $channelResponse.value.id

$listUrl = $SiteUrl + "/lists/Employees"
$addRequestUrl = "https://graph.microsoft.com/v1.0/teams/$teamID/channels/$channelID/tabs"
$tabRequest = @{
  "displayName" = "Employees"
  "teamsApp@odata.bind" = "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/com.microsoft.teamspace.tab.web"
  "configuration" = @{
    "entityId" = $null
    "contentUrl" = $listUrl
    "websiteUrl" = $listUrl
    "removeUrl" = $null
  }
}
$tabRequestBody = ConvertTo-Json -InputObject $tabRequest
Write-Output "$(Get-Date -Format u) Adding Employees tab to channel $channelID of team $teamID"
Invoke-RestMethod -Uri $addRequestUrl -Body $tabRequestBody -Method Post -Headers $header