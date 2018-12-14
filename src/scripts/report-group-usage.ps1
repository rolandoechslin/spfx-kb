# Orignal: https://github.com/wobba/espc18/blob/master/list-usage.ps1

# This script uses an ADAL app with app only permissions for authentication
# Feel free to change how you get an auth token, as there are many ways
$appId = "<ADAL AppId with Group.ReadWrite.All>"
$appSecret = "<ADAL App Secret with Group.ReadWrite.All>"
$domain = "<tenant>.onmicrosoft.com"

Write-Host "Prompt for service user"
Connect-PnPOnline -Scopes "Group.Read.All"
$serviceToken = Get-PnPAccessToken
# ID of AAD user to use for checking Planner
$serviceUserId = "0168f652-85fa-4ae9-9c72-fb827d6caebc" 

$today = (Get-Date)
$warningDate = (Get-Date).AddDays(-30)
$date = $today.ToString("yyyy'-'MM'-'dd") 
$report = @()
$reportFile = "c:\repos\espc18\ObsoleteGroups.html"
$lastFile = "c:\repos\espc18\ObsoleteGroups.csv"

$formFields = @{client_id = "$appId"; scope = "https://graph.microsoft.com/.default"; client_secret = "$appSecret"; grant_type = 'client_credentials'}
$url = "https://login.microsoftonline.com/$domain/oauth2/v2.0/token"

$result = Invoke-WebRequest -UseBasicParsing -Uri $url -Method Post -Body $formFields -ContentType "application/x-www-form-urlencoded"
$result = ConvertFrom-Json -InputObject $result.Content
$token = $result.access_token

function Get-GroupUsageReport() {
    try {
        $query = "https://graph.microsoft.com/beta/reports/getOffice365GroupsActivityDetail(period='D30')?`$format=application/json&`$top=200"
        $headers = @{"Authorization" = "Bearer " + $token}
        $response = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $query -Headers $headers -UseBasicParsing
        $reportItems = $response.value
    
        $nextLink = $response."@odata.nextLink"
    
        while ($null -ne $nextLink) {
            $response = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $nextLink -Headers $headers -UseBasicParsing
            $nextLink = $response."@odata.nextLink"
            $reportItems += $response.value
        }
        return ($reportItems | Sort-Object groupDisplayName) |? isDeleted -eq $false        
    }
    catch {
        exit   
    }
}
function Get-GroupByName($displayName) {
    try {
        $query = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$displayName'"
        $headers = @{"Authorization" = "Bearer " + $token}
        $response = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $query -Headers $headers -UseBasicParsing
        return $response.value            
    }
    catch {
        exit
    }
}

function Renew-Group($groupId) {
    $query = "https://graph.microsoft.com/v1.0/groups/$groupId/renew"
    $headers = @{"Authorization" = "Bearer " + $token}
    $response = Invoke-RestMethod -Method POST -ContentType "application/json" -Uri $query -Headers $headers -UseBasicParsing
    return $response.value
}

function Add-Member($groupId, $userId) {
    try {
        $query = "https://graph.microsoft.com/v1.0/groups/$groupId/members/`$ref"
        $headers = @{"Authorization" = "Bearer " + $token}
        $body = @"
{
    "@odata.id": "https://graph.microsoft.com/v1.0/directoryObjects/$userId"
}    
"@
        $response = Invoke-RestMethod -Method POST -ContentType "application/json" -Uri $query -Headers $headers -Body $body -UseBasicParsing        
        Start-Sleep 5
    }
    catch {
        #Write-Host "Failed to add service user as member"
    }
}

function Remove-Member($groupId, $userId) {
    try {
        $query = "https://graph.microsoft.com/v1.0/groups/$groupId/members/$userId/`$ref"
        $headers = @{"Authorization" = "Bearer " + $token}
        $response = Invoke-RestMethod -Method DELETE -ContentType "application/json" -Uri $query -Headers $headers -UseBasicParsing            
    }
    catch {
        Write-Host "Failed to remove service user as member"
    }
}

function Get-PlannerActive($groupId) {
    try {
        $plansQuery = "https://graph.microsoft.com/v1.0/groups/$groupId/planner/plans"
        $headers = @{"Authorization" = "Bearer " + $serviceToken}
        $response = Invoke-RestMethod -Method GET -ContentType "application/json" -Uri $plansQuery -Headers $headers -UseBasicParsing
        
        $plans = $response.value
        foreach ($plan in $plans) {
            $planId = $plan.id
            $tasksQuery = "https://graph.microsoft.com/v1.0/planner/plans/$planId/tasks"
            $response = Invoke-RestMethod -Method GET -ContentType "application/json" -Uri $tasksQuery -Headers $headers -UseBasicParsing
            if ($response.value.length -gt 0) {
                $task = $response.value[0];
                $taskDate = Get-Date -Date $task.createdDateTime
                if ( $taskDate -gt $warningDate) {
                    return $true
                }
            }
        }
        return $false            
    }
    catch {
        Write-Host "Failed to load plans"
    }
}

function Get-AllowSharing($groupId) {
    $query = "https://graph.microsoft.com/v1.0/groups/$groupId/settings"
    $headers = @{"Authorization" = "Bearer " + $token}
    $settings = Invoke-RestMethod -Method Get -ContentType "application/json" -Uri $query -Headers $headers -UseBasicParsing

    $template = $settings.value |? templateId -eq '08d542b9-071f-4e16-94b0-74abb372e3d9'
    if($null -ne $template) {
        return [bool]::Parse($template.values.value)
    }

    return $true
}

$previousItems = @()
if ([System.IO.File]::Exists($lastFile)) {
    $previousReportFile = Get-Content -Path $lastFile -Encoding UTF8
    $previousItems = ConvertFrom-Csv -Delimiter ';' -InputObject $previousReportFile 
}

$htmlhead = "<html>
	   <style>
	   BODY{font-family: Arial; font-size: 8pt;}
	   H1{font-size: 22px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
	   H2{font-size: 18px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
	   H3{font-size: 16px; font-family: 'Segoe UI Light','Segoe UI','Lucida Grande',Verdana,Arial,Helvetica,sans-serif;}
	   TABLE{border: 1px solid black; border-collapse: collapse; font-size: 8pt;}
	   TH{border: 1px solid #969595; background: #dddddd; padding: 5px; color: #000000;}
	   TD{border: 1px solid #969595; padding: 5px; }
	   td.pass{background: #B7EB83;}
	   td.warn{background: #FFF275;}
	   td.fail{background: #FF2626; color: #ffffff;}
       td.info{background: #85D4FF;}
       td:contains('False'){background-color: #FFF275}
	   </style>
	   <body>
           <div align=center>
           <p><h1>Report of Potentially Obsolete Office 365 Groups</h1></p>
           <p><h3>Generated: $date  - $domain</h3></p></div>"
		
# Get a list of all Office 365 Groups in the tenant
Write-Host "Extracting list of Office 365 Groups to be checked..."

$groupStats = Get-GroupUsageReport
$groupStats | % {
    Write-Host "$($_.groupDisplayName) - refresh date $($_.reportRefreshDate)"

    $groupData = Get-GroupByName -displayName $_.groupDisplayName

    if (-not $groupData.groupTypes.Contains("DynamicMembership")) {        
        Add-Member -groupId $groupData.id -userId $serviceUserId
        $plannerActive = Get-PlannerActive -groupId $groupData.id
        #Remove-Member -groupId $groupData.id -userId $serviceUserId                
    }
    
    $hasTeams = ($groupData.resourceProvisioningOptions -ne $null -and $groupData.resourceProvisioningOptions.Contains("Team"))
    $hasYammer = ($groupData.resourceBehaviorOptions -ne $null -and $groupData.resourceBehaviorOptions.Contains("YammerProvisioning"))

    $prevGroupData = $previousItems |? GroupId -eq $groupData.Id
    if ($prevGroupData -ne $null) {
        $lastMsgDate = $prevGroupData.LastMessageActivity
    }
    else {
        $lastMsgDate = $date
    }
    if ([int]$_.exchangeMailboxTotalItemCount -gt [int]$prevGroupData.MessageCount ) {
        $lastMsgDate = $date
    }
    $messageActive = (Get-Date -Date $lastMsgDate) -gt $warningDate

    $yammerActive = $false
    if ($hasYammer) {
        if ($prevGroupData.yammerPostedMessageCount -ne $null) {
            $lastYammerDate = $prevGroupData.LastYammerActivity
        }
        elseif ([int]$_.yammerPostedMessageCount -eq 0) {
            $lastYammerDate = "2018-01-01"
        }
        else {
            $lastYammerDate = $date
        }
        if ([int]$_.yammerPostedMessageCount -gt [int]$prevGroupData.YammerCount ) {
            $lastYammerDate = $date
        }

        $yammerActive = ((Get-Date -Date $lastYammerDate) -gt $warningDate) -and ([int]$_.yammerPostedMessageCount -gt 0)
    }

    if ($_.lastActivityDate) {
        $spoActive = (Get-Date -Date $_.lastActivityDate) -gt $warningDate
    }
    else {
        $spoActive = $false
        $_.lastActivityDate = "Never"
    }
    
    if ($spoActive -and $messageActive -or ($hasYammer -and $yammerActive)) {
        $status = "Pass"
    }
    elseif ($spoActive -or $messageActive) {
        $status = "Warn"
    }
    else {
        $status = "Fail"
    }

    $reportLine = [PSCustomObject][Ordered]@{
        GroupId             = $groupData.Id
        GroupName           = $_.groupDisplayName
        ManagedBy           = $_.ownerPrincipalName
        Members             = $_.memberCount
        ExternalGuests      = $_.externalMemberCount
        AllowExternalMembers = Get-AllowSharing -groupId $groupData.Id
        Description         = $groupData.description
        LastSPOActivity     = $_.lastActivityDate
        MessageCount        = $_.exchangeMailboxTotalItemCount
        LastMessageActivity = $lastMsgDate
        TeamEnabled         = if ($hasTeams) {"Yes"} else {"No"}
        YammerCount         = $_.yammerPostedMessageCount
        LastYammerActivity  = $lastYammerDate
        Classification      = $groupData.classification
        PlannerActive       = $plannerActive
        Active              = $status
    }
    $report += $reportLine
    if($status -eq 'Pass'){
        Write-Host "`t$status" -ForegroundColor Green
    }
    if($status -eq 'Warn'){
        Write-Host "`t$status" -ForegroundColor Yellow
    }
    if($status -eq 'Fail'){
        Write-Host "`t$status" -ForegroundColor Red
    }
    # if (($spoActive -or $messageActive)) {
    #     if ((Get-Date -Date $groupData.renewedDateTime) -lt $warningDate) { 
    #         Write-Host "Auto-renewing $($_.groupDisplayName)"
    #         Renew-Group -groupId $groupData.Id
    #     }
    # }
}

$htmlfooter = "
<p>
Messages includes both Teams activity and e-mail activity.
</p>
</body>
<script>
function contains(selector, text) {
    var elements = document.querySelectorAll(selector);
    return Array.prototype.filter.call(elements, function(element){
      return RegExp(text).test(element.textContent);
    });
}
//debugger;
var nodes = contains('td','Pass');
for (var i in nodes) {  
    nodes[i].className = 'Pass';
}
var nodes = contains('td','Warn');
for (var i in nodes) {  
    nodes[i].className = 'Warn';
}
var nodes = contains('td','Fail');
for (var i in nodes) {  
    nodes[i].className = 'Fail';
}
</script>
</html>
"

$htmlbody = $report | ConvertTo-Html -Fragment
$htmlreport = $htmlhead + $htmlbody + $htmlfooter
$htmlreport | Out-File $reportFile  -Encoding UTF8

($report | ConvertTo-Csv -NoTypeInformation -Delimiter ';') | Out-File -FilePath $lastFile -Encoding utf8