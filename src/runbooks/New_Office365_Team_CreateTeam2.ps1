param
(
    [Parameter(Mandatory=$true)]
    [string]$alias,
    [Parameter(Mandatory=$true)]
    [string]$displayName,
    [Parameter(Mandatory=$true)]
    [string]$teamDescription,
    [Parameter(Mandatory=$true)]
    [string]$teamOwner
)

Connect-PnPOnline -AppId $global:AppID -AppSecret $global:AppSecret -AADDomain $global:tenantConfig.Settings.Azure.AADDomain
Write-Output "$(Get-Date -Format u) Connecting to $($global:tenantConfig.Settings.Azure.AADDomain)"
$accessToken = Get-PnPAccessToken

$header = @{
  "Content-Type" = "application/json"
  Authorization = "Bearer $accessToken"
}

# Check if "Alias" is available, otherwise try Alias2, Alias3, ...
$groupAvailable = Get-PnPUnifiedGroup -Identity $alias
$increment = 1
$newGroupAlias = $alias
while ($groupAvailable -ne $null)
{
    $increment++
    $newGroupAlias = $alias + $increment.ToString()
    $groupAvailable = Get-PnPUnifiedGroup -Identity $newGroupAlias
}
Write-Output "$(Get-Date -Format u) Creating new group $displayName with alias $newGroupAlias"

$userResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$teamOwner" -Method Get -Headers $header
$teamOwnerID = $userResponse.id
$owners = @("https://graph.microsoft.com/beta/users/$teamOwnerID")

$groupRequest = @{
  displayName = "$displayName"
  description = "$teamDescription"
  groupTypes = @("Unified")
  mailEnabled = $true
  mailNickname = $newGroupAlias
  securityEnabled = $false
  "owners@odata.bind" = $owners
  "members@odata.bind" = $owners
}
$groupRequestBody = ConvertTo-Json -InputObject $groupRequest
$groupResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups" -Body $groupRequestBody -Method Post -Headers $header -UseBasicParsing
$groupID = $groupResponse.id

$teamRequest = @{  
  memberSettings = @{
    allowCreateUpdateChannels = $true
  }
  messagingSettings = @{
    allowUserEditMessages = $true
    allowUserDeleteMessages = $true
  }
  funSettings = @{
    allowGiphy = $true
    giphyContentRating = "strict"
  }
}
$teamRequestBody = ConvertTo-Json -InputObject $teamRequest

$response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups/$groupID/team" -Body $teamRequestBody -Method Put -Headers $header -UseBasicParsing
$global:TeamID = $response.id # Will be the same than $GroupID but ...
Write-Output "$(Get-Date -Format u) Team $displayName created with ID $TeamID"