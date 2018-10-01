#Setup
$UserCredential = Get-Credential -Credential "admin@M365x291009.onmicrosoft.com"
Connect-AzureAD -Credential $UserCredential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

#Set the groups and retrieve the Security Group members

$O365Group = (Get-UnifiedGroup -Identity "Finance")
$SecurityGroup = (Get-AzureADGroup -SearchString "Finance SG")
$SecurityGroupMembers = (Get-AzureADGroupMember -ObjectId $SecurityGroup.ObjectId | Select UserPrincipalName, Membertype)
$SecurityGroupMembers

#Add each security group member to the O365 Group
ForEach ($i in $SecurityGroupMembers) {
    Write-Host "Adding Member: " $i.UserPrincipalName
    Add-UnifiedGroupLinks -Identity $O365Group.Alias -LinkType Members -Links $i.UserPrincipalName }

#Remove Members from the O365 Group who don't exist in the Security Group
$O365Group = (Get-UnifiedGroup -Identity "Finance")
$O365GroupMembers = (Get-UnifiedGroupLinks -Identity $O365Group.Alias -LinkType Member)
$O365GroupMembers

# Grab list of security group members
$SecurityGroup = (Get-AzureADGroup -SearchString "Finance SG")
$SecurityGroupMembers = (Get-AzureADGroupMember -ObjectId $SecurityGroup.ObjectId | Select UserPrincipalName, Membertype)
$SecurityGroupMembers

#Remove members from O365 Group who don't exist in Security Group
ForEach ($i in $O365GroupMembers) {
    $Member = (Get-Mailbox -Identity $i.Name)
    If ($SecurityGroupMembers -Match $Member.UserPrincipalName)
        {Write-Host $Member.DisplayName "is in security group" }
    Else
        { Write-Host "Removing" $Member.DisplayName "from Office 365 group because they are not in the security group" -ForeGroundColor Red
        Remove-UnifiedGroupLinks -Identity $O365Group.Alias -Links $Member.Alias -LinkType Member -Confirm:$False}}

#Close the Exchange session
Remove-PSSession $Session

#######################################################################################################################
#To ensure Debra and Enrico are not members of the O365 Group, run this script to reset
ForEach ($i in $O365GroupMembers) {
    $Member = (Get-Mailbox -Identity $i.Name)
    Write-Host $Member.Alias }
Remove-UnifiedGroupLinks -Identity enricoc -Links $Member.Alias -LinkType Member -Confirm:$False
Remove-UnifiedGroupLinks -Identity debrab -Links $Member.Alias -LinkType Member -Confirm:$False
#To ensure Nestor is a member of the Finance O365 Group and not the SG, run this script.
Add-UnifiedGroupLinks -Identity  -LinkType Members -Links $i.UserPrincipalName