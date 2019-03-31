param
(
    [Parameter(Mandatory=$true)]
    [string]$displayName,
    [Parameter(Mandatory=$true)]
    [string]$teamDescription,
    [Parameter(Mandatory=$true)]
    [string]$teamOwner
)

Connect-PnPOnline -AppId $global:AppID -AppSecret $global:AppSecret -AADDomain $global:tenantConfig.Settings.Azure.AADDomain
$accessToken = Get-PnPAccessToken

$header = @{
  "Content-Type" = "application/json"
  Authorization = "Bearer $accessToken"
}
$userResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users/$teamOwner" -Method Get -Headers $header
$teamOwnerID = $userResponse.id
$owners = @("https://graph.microsoft.com/beta/users/$teamOwnerID")
$teamRequest = @{
  "template@odata.bind" = "https://graph.microsoft.com/beta/teamsTemplates('standard')"
  displayName = "$displayName"
  description = "$teamDescription"
  "owners@odata.bind" = $owners
}
$teamRequestBody = ConvertTo-Json -InputObject $teamRequest | % { [System.Text.RegularExpressions.Regex]::Unescape($_) } #https://www.cryingcloud.com/blog/2017/05/02/replacefix-unicode-characters-created-by-convertto-json-in-powershell-for-arm-templates

$response = Invoke-RestMethod -Uri "https://graph.microsoft.com/beta/teams" -Body $teamRequestBody -Method Post -Headers $header -UseBasicParsing

# Grab Team via Display Name (not secure)
$queryUrl = 'https://graph.microsoft.com/beta/groups?$filter=resourceProvisioningOptions'
$queryUrl += "/Any(x:x eq 'Team') and displayName eq '$displayName'"

$teamResponse = Invoke-RestMethod -Uri $queryUrl -Method Get -Headers $header
$orderedTeams = $teamResponse.value | Sort-Object -Property createdDateTime -Descending
$TeamID = $orderedTeams[0].id
return $TeamID