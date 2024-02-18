# https://www.menzel.it/post/2024/02/change-sharepoint-group-security-groups-powershell/

# Connect to the SharePoint site using PnP-PowerShell
Connect-PnPOnline -Url "https://<YourTenantName>.sharepoint.com/sites/<YourSiteName>" -Interactive

# Get all SharePoint Permission Groups for the site collection
$Groups = Get-PnPGroup | Where-Object { $_.Title -notlike '*SiteCollection Owners*' -and $_.Title -notlike '*SiteCollection Members*' -and $_.Title -notlike '*SiteCollection Visitors*' -and $_.Title -notlike '*SharingLinks*' -and $_.Title -notlike '*Limited Access*' }

# Go through all permission groups
foreach ($Group in $Groups) {
    # Get Users from the SharePoint Group
    $Users = Get-PnPGroupMember -Identity $Group.Title
    # Create a new EntraID Security Group
    $NewGroup = New-PnPAzureADGroup -DisplayName "<NewGroupName>" -MailNickname "<MailNickname>" -Description "<GroupDescription>" -IsSecurityEnabled

    # Add all Users from the SharePoint Group to the EntraID Security Group
    foreach ($User in $Users) {
        Add-PnPAzureADGroupMember -Identity $NewGroup.Id -Users $User.UserPrincipalName
    }

    # Remove all Users from the SharePoint Group
    foreach ($User in $Users) {
        Remove-PnPGroupMember -LoginName $User.LoginName -Identity $Group.Title
    }

    # Add the EntraID Security Group to the SharePoint Group
    # ... (rest of the loop and error handling)
}

Disconnect-PnPOnline
