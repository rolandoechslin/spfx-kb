# SOurce: https://veronicageek.com/powershell/powershell-for-m365/get-teams-channels-tabs-and-privacy-settings-using-teams-pnp-powershell/2020/07/

## Connect to Teams PnP
Connect-PnPOnline -Scopes "Group.ReadWrite.All" -Credentials "msftdemo"
#Store variables
$results = @()
$allTeams = Get-PnPTeamsTeam
#Loop through each Team
foreach($team in $allTeams){
    $allChannels = Get-PnPTeamsChannel -Team $team.DisplayName
    
    #Loop through each Channel
    foreach($channel in $allChannels){
        $allTabs = Get-PnPTeamsTab -Team $team.DisplayName -Channel $channel
        
        #Loop through each Tab + get the info!
        foreach($tab in $allTabs){
            $results += [pscustomobject][ordered]@{
                Team = $team.DisplayName
                Visibility = $team.Visibility
                ChannelName = $channel.DisplayName
                tabName = $tab.DisplayName
            }
        }
    }
}
$results | Export-Csv -Path <YOUR_PATH> -NoTypeInformation
 