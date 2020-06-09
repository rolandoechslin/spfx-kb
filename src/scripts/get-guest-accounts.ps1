# Source: https://office365itpros.com/2020/06/09/finding-guests-office-365-groups-prohibited/?utm_source=rss&utm_medium=rss&utm_campaign=finding-guests-office-365-groups-prohibited

Write-Host "Finding confidential Office 365 Groups..."

$Groups = Get-UnifiedGroup | ? {$_.SensitivityLabel -eq "1b070e6f-4b3c-4534-95c4-08335a5ca610" -and $_.GroupExternalMemberCount -gt 0} 
If (!$Groups.Count) { Write-Host "No Office 365 Groups found with that label"}
  Else {
     $Report = [System.Collections.Generic.List[Object]]::new(); $NumberGuests = 0
     Write-Host "Now examining the membership of" $Groups.Count "groups to find guests..." 
     ForEach ($Group in $Groups) {
       Write-Host "Processing" $Group.DisplayName
       $Users = Get-UnifiedGroupLinks -Identity $Group.Alias -LinkType Members
       ForEach ($U in $Users) {
         If ($U.Name -Match "#EXT#" -and $U.Name -NotLike "*teams.ms*") {
## Remember to edit the string to make sure it’s your tenant name…
            $CheckName = $U.Name + "@EditMeTenantName.onmicrosoft.com"
            $User = (Get-AzureADUser -ObjectId $CheckName).DisplayName 
            $ReportLine = [PSCustomObject]@{
               Email           = $U.Name
               User            = $User
               Group           = $Group.DisplayName
               Site            = $Group.SharePointSiteURL }
            $Report.Add($ReportLine)
            $NumberGuests++ }         
}}}

Write-Host "All done." $NumberGuests "guests found in" $Groups.Count "groups"

$Report | Sort Email | Out-GridView