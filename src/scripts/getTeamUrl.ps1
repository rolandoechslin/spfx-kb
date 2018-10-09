<#

    Script to construct team link using Microsoft Teams PowerShell module.
    https://docs.microsoft.com/en-us/powershell/teams/intro
    https://www.powershellgallery.com/packages/MicrosoftTeams/

#>

#Enter team display name or group ID
$teamDisplayName = ""
$groupID = ""

#Team link template
$teamLinkTemplate = "https://teams.microsoft.com/l/team/<ThreadId>/conversations?groupId=<GroupId>&tenantId=<TenantId>"

#Connect to Microsoft Teams
$connectTeams = Connect-MicrosoftTeams

#Retrieve the team via display name or group ID
$team = Get-Team | Where-Object {$_.DisplayName -eq $teamDisplayName -or $_GroupId -eq $groupID} | Select-Object -First 1

#Retrieve team channel General (can be replaced by another Channel if needed)
$channel = Get-TeamChannel -GroupId $team.GroupId | Where-Object {$_.DisplayName -eq "General"} | Select-Object -First 1

#Construct the team link
$teamLink = $teamLinkTemplate.Replace("<ThreadId>",$channel.Id).Replace("<GroupId>",$team.GroupId).Replace("<TenantId>",$connectTeams.TenantId)
$teamLink