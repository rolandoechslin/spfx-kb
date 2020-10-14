function Get-AllTeamsUserMembership {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "User Principal Name")] 
        [string]$UserUPN  
    )
    
    #Connect to Teams & Azure AD ---> INSERT YOUR OWN CREDS
    Connect-PnPOnline -Scopes "Group.Read.All" -Credentials "<YOUR-CREDS-NAME>"
    Connect-AzureAD -Credential (Get-PnPStoredCredential -Name "<YOUR-CREDS-NAME>" -Type PSCredential) | Out-Null
    #Store all the Teams 
    $allTeams = Get-PnPTeamsTeam
    $results = @()
    $userToFind = $UserUPN
    $userToFindInAD = Get-AzureADUser | Where-Object ({ $_.UserPrincipalName -match $userToFind })
    $userToFindID = $userToFindInAD.ObjectId
    #Loop through the TEAMS
    foreach ($team in $allTeams) {
        $allTeamsUsers = (Get-PnPTeamsUser -Team $team.DisplayName)
    
        #Loop through users TARGETING THE USER ID TO MATCH
        foreach ($teamUser in $allTeamsUsers) {
            if ($teamUser.Id -match $userToFindID) {
                Write-Host "Found a match: " $teamUser.Id
            
                $results += [pscustomobject][ordered]@{
                    userName        = $userToFindInAD.UserPrincipalName
                    userDisplayName = $userToFindInAD.DisplayName
                    userRole        = $teamUser.UserType
                    Team            = $team.DisplayName
                    teamVisibility  = $team.Visibility
                }
            }    
        }
    }
}
#$results
Get-AllTeamsUserMembership -UserUPN "user123@myDomain.com" | Export-Csv -Path "C:\users\$env:USERNAME\Desktop\UserMembershipInTeams.csv" -NoTypeInformation