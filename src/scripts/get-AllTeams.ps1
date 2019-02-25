# https://drewmadelung.com/get-office-365-groups-with-teams-via-powershell-and-the-microsoft-graph/

#If scopes is empty it will check to run via app 
$scopes = 'Group.Read.All'
 
$appid = ''
$appsecret = ''
$appaaddomain = ''
 
#Graph URLs - uncomment one to run
 
#Get all groups
#$url = "https://graph.microsoft.com/v1.0/groups?`$filter=groupTypes/any(c:c eq 'Unified')&`$select=displayname,resourceProvisioningOptions"
#Get all groups with teams
$url = "https://graph.microsoft.com/beta/groups?`$filter=resourceProvisioningOptions/Any(x:x eq 'Team')"
 
#Establish connection
If($scopes.Length -gt 0){
    Connect-PnPOnline -Scopes "Group.Read.All"
} elseif($appid.Length -gt 0) {
    Connect-PnPOnline -AppId $appid -AppSecret $appsecret  -AADDomain $appaaddomain
} else {
    write-host 'Connection issue' -ForegroundColor Red
    exit
}
 
#Get token
$token = Get-PnPAccessToken
 
#Call graph
if($token){
    $response = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $token"}
} else {
    write-host 'Token issue' -ForegroundColor Red
    exit
}
 
#Parse data
if($response){
foreach($r in $response.value){ 
    if($r.resourceProvisioningOptions -eq 'Team'){
        write-host $r.displayname "is a Team enabled Group" -ForegroundColor Yellow
        #Do fancy stuff in here
    } else {
        write-host $r.displayname "is a regular O365 Group" -ForegroundColor Green
    }
}
} else {
    write-host 'Response issue' -ForegroundColor Red
}