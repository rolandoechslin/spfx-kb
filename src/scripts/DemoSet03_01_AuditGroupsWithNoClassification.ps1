#Setup
$UserCredential = Get-Credential -Credential "admin@M365x291009.onmicrosoft.com"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-AzureAD -Credential $UserCredential

#Retrieve the classification list to show the audience what values are configured
Get-AzureADDirectorySetting | ForEach Values

#Show the list of all groups within the tenant. Point out there are no groups with classification "High"
Get-UnifiedGroup | Sort-Object DisplayName | Select DisplayName, Classification, ExternalDirectoryObjectId

#Retrieve all groups that don't have null or blank values
$GroupsWithNoClassification = Get-UnifiedGroup | Where-Object {$_.Classification -Eq $Null -or $_.Classification -Eq ""} | Sort-Object DisplayName | Select DisplayName, Classification, ExternalDirectoryObjectId
$GroupsWithNoClassification

#Set the classification of each group to "Highly Confidential" for demo purposes
ForEach ($G in $GroupsWithNoClassification) {
    If ($G.Classification -Eq $Null -or $G.Classification -Eq "") {
        Set-UnifiedGroup -Identity $G.DisplayName -Classification “Highly Confidential”
        Write-Host “The group classification setting for" $G.DisplayName "was updated to Highly Confidential."}}

#Retrieve the list of groups that now have classification set to "Highly Confidential"
$GroupsWithNoClassification = Get-UnifiedGroup | Where-Object {$_.Classification -Eq "Highly Confidential"} | Sort-Object DisplayName | Select DisplayName, Classification, ExternalDirectoryObjectId
$GroupsWithNoClassification

#Double check all groups now have a classification setting
$GroupsWithNoClassification = Get-UnifiedGroup | Where-Object {$_.Classification -Eq $Null -or $_.Classification -Eq ""} | Sort-Object DisplayName | Select DisplayName, Classification, ExternalDirectoryObjectId
$GroupsWithNoClassification

#Close the Exchange session
Remove-PSSession $Session

##################################################################################
#To reset "High" groups to empty string, run this script after running the demo
Set-UnifiedGroup -Identity "Kumudini's Group" -Classification “”
Write-Host “The group classification setting for Kumudini's Group" "was updated to blank."
Set-UnifiedGroup -Identity "Manager B Directs" -Classification “”
Write-Host “The group classification setting for Manager B Directs" "was updated to blank."
Set-UnifiedGroup -Identity "Legal" -Classification “”
Write-Host “The group classification setting for Legal" "was updated to blank."
Set-UnifiedGroup -Identity "Finance" -Classification “”
Write-Host “The group classification setting for Finance" "was updated to blank."

$GroupsToResetClassification = Get-UnifiedGroup | Where-Object {$_.Classification -Eq "High"} | Sort-Object DisplayName | Select DisplayName, Classification, ExternalDirectoryObjectId
ForEach ($G in $GroupsToResetClassification) {
    If ($G.Classification -Eq "High") {
        Set-UnifiedGroup -Identity $G.DisplayName -Classification “”
        Write-Host “The group classification setting for" $G.DisplayName "was updated to blank."}}