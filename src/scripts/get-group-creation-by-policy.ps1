# Source: https://office365itpros.com/2020/01/22/using-groups-admin-role

# Find the settings in the Azure AD Policy for Groups
$Settings = Get-AzureADDirectorySetting | ? {$_.DisplayName -eq "Group.Unified"}

If ($Settings["GroupCreationAllowedGroupId"] -ne $Null) { # We have a group defined to control group creation
   
   $Members = Get-AzureADGroupMember -ObjectId $Settings["GroupCreationAllowedGroupId"]
   $GroupAdminRole = Get-AzureADDirectoryRole | ? {$_.DisplayName -eq "Groups Administrator"} | Select ObjectId
   ForEach ($Member in $Members) { # Assign the Groups Admin role to each member
      Try {
        Add-AzureADDirectoryRoleMember -ObjectId $GroupAdminRole.ObjectId -RefObjectId $Member.ObjectId }
      Catch { 
        Write-Host "Groups Admin role already assigned to" $Member.DisplayName }
      }

} Else {
  Write-Host "This tenant does not control group creation via policy"
}

Write-Host "----------------------------------------"
Write-Host "Current holders of the Group Admins role"
Write-Host "----------------------------------------"

Get-AzureADDirectoryRoleMember -ObjectId $GroupAdminRole.ObjectId | Format-Table DisplayName, UserPrincipalName