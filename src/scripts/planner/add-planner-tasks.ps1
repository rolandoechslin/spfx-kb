# Source: https://ms365thinking.blogspot.com/2023/02/creating-planner-tab-in-teams-including.html

$localConn = Connect-PnPOnline -Url $siteUrl -ClientId $ClientId -thumbprint $thumbprint -Tenant $TenantName -ReturnConnection -erroraction stop

$PlannerPlan = Get-PnPPlannerPlan -Group $groupId -Identity $PlannerName -Connection $localConn

if(-not $PlannerPlan)
{
    $PlannerPlan = New-PnPPlannerPlan -Group $groupId -Title $PlannerName -Connection $localConn
}

$bucket = Add-PnPPlannerBucket -Group $groupId -Plan $PlannerPlan.Id -Name "Tasks" -Connection $localConn

$newTask = Add-PnPPlannerTask -Group $groupId -Plan $PlannerPlan.Id -Bucket $bucket.Id -Title "Task A" -Connection $conn

$newTask = Add-PnPPlannerTask -Group $groupId -Plan $PlannerPlan.Id -Bucket $bucket.Id -Title "Task B" -Connection $conn

$newTask = Add-PnPPlannerTask -Group $groupId -Plan $PlannerPlan.Id -Bucket $bucket.Id -Title "Task C" -Connection $conn

$newTask = Add-PnPPlannerTask -Group $groupId -Plan $PlannerPlan.Id -Bucket $bucket.Id -Title "Task D" -Connection $conn

$plannerChannel = Get-PnPTeamsChannel -Team $groupId -Connection $conn | Where-Object {$_.DisplayName -eq "RFP"}

$teamsTab = Add-PnPTeamsTab -Team $groupId -Channel $plannerChannel -DisplayName "RFP" -Type Custom -TeamsAppId "com.microsoft.teamspace.tab.planner" -Connection $conn -ContentUrl "https://tasks.office.com/tcwlv.onmicrosoft.com/Home/PlannerFrame?page=7&planId=$($PlannerPlan.Id)"