#Setup
$UserCredential = Get-Credential -Credential "admin@M365x291009.onmicrosoft.com"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-AzureAD -Credential $UserCredential

#Show the audience we have a mismatch of groups with "Highly Confidential" classification and "Public" access type
Get-UnifiedGroup | Sort-Object Classification, DisplayName | Select DisplayName, Classification, AccessType, ExternalDirectoryObjectId

#Run a query to narrow down just the groups with a mismatch
$classification03 = "Highly Confidential"
$GroupsWithMismatchClassification = Get-UnifiedGroup | Where-Object {$_.AccessType -eq ‘Public’ -and $_.Classification -eq $classification03 } | Select DisplayName, Classification, AccessType, ExternalDirectoryObjectId
$GroupsWithMismatchClassification

#Set the Access Type to Private for all "Highly Confidential" groups
ForEach ($G in $GroupsWithMismatchClassification) {
    Set-UnifiedGroup -Identity $G.DisplayName -AccessType ‘Private’
    Write-Host “The following group privacy setting was updated:” $G.DisplayName}

#Check that we no longer have a mismatch of groups with "Highly Confidential" classification and "Public" access type
Get-UnifiedGroup | Sort-Object Classification, DisplayName | Select DisplayName, Classification, AccessType, ExternalDirectoryObjectId

#Close the Exchange session
Remove-PSSession $Session

#######################################################################################################################
#To ensure there is a group with "High" classification and "Public" access type, run this script before and after demos
Set-UnifiedGroup -Identity "Finance" -Classification “” -AccessType "Public"
Set-UnifiedGroup -Identity "Manager B Directs" -Classification "" -AccessType "Public"
Set-UnifiedGroup -Identity "Kumudini's Group" -Classification “” -AccessType "Public"
Set-UnifiedGroup -Identity "Legal" -Classification "" -AccessType "Private"