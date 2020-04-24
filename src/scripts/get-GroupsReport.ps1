# Author: Niklas Jumlin (niklas.jumlin[at]atea.se)
# Version: 2019-03-11
#
# Requires connection to: Teams, ExchangeOnline, AzureAD
#
# Install-Module MicrosoftTeams -MinimumVersion 0.9.5
# The "Get-Team" cmdlet in 0.9.5 now lists ALL teams in the organization rather than just the teams we are a member of!
#
# Install-Module AzureADPreview -MinimumVersion 2.0.0.137
# Version 2.0.0.137 (preview) of the Azure Active Directory PowerShell module has the cmdlets to deal with the group expiration policy. Two sets of cmdlets are available. The first manipulates the settings of the expiration policy. These are the *-AzureADMSGroupLifecyclePolicy cmdlets. The second set, the *-AzureADMSLifecyclePolicyGroup cmdlets, is used when you want the expiration policy to process selected groups rather than every group in the tenant.
#
 
$timer=[system.diagnostics.stopwatch]::StartNew()
 
# Check if module requirements are fulfilled
if ( -not((Get-Module -ListAvailable AzureADPreview).Version -ge "2.0.0.137") ) { "Module: AzureADPreview is not installed or the version is not 2.0.0.137 or greater" ; exit }
if ( -not((Get-Module -ListAvailable MicrosoftTeams).Version -ge "0.9.5") ) { "Module: MicrosoftTeams is not installed or the version is not 0.9.5 or greater" ; exit }
 
# Verify/Start connection to ExchangeOnline, AzureAD and Teams
# Session variables will stay in the Global scope in order to re-execute this script from the same powershell session.
$ExchSession=Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"} | select-object ComputerName
if  ( (-not($ExchSession)) -or (-not($azureAD)) -or (-not($microsoftTeams)) ) {
 
    # check credentials
    if ($credentials) {
        Write-Host "Would you like to use already collected credentials: $($credentials.Username)?" -foregroundColor Cyan
        $Readhost = Read-Host "( y / n )" ; Write-Host "`r"
        Switch ($ReadHost) { 
            Y { $script:UserCredential = $credentials } 
            J { $script:UserCredential = $credentials } 
            N { $readagain=$True } 
            Default { $script:UserCredential = $credentials } 
        }
    }
    if ( (-not($credentials)) -or ($readagain -eq $True) ) {
        $script:username = Read-host "Username"
        $script:password = Read-host "Password for $username" -AsSecureString
        $script:credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password
        $script:UserCredential = $credentials
    }
 
    Write-Host "Connecting to ExchangeOnline, AzureAD and Teams . . ." -foregroundcolor Cyan
 
    if (-not($ExchSession)) {
        Try {
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
            $try=Import-PSSession $Session -DisableNameChecking -ErrorAction Stop
            Write-Host "ExchangeOnline connected successfully" -foregroundColor Green
        }
        Catch {
            Write-Host "$($_.Exception.Message)" -foregroundColor Red
            Exit
        }
    }
 
    if (-not($azureAD)) { 
        Try { 
            $global:azureAD=Connect-AzureAD -Credential $UserCredential -ErrorAction Stop
            Write-Host "AzureAD connected successfully" -foregroundColor Green
        }
        Catch {
            Write-Host "$($_.Exception.Message)" -foregroundColor Red
            Exit
        }
    }
 
    if (-not($microsoftTeams)) {
        Try {
            $global:microsoftTeams=Connect-MicrosoftTeams -Credential $UserCredential -ErrorAction Stop
            Write-Host "MicrosoftTeams connected successfully" -foregroundColor Green
        }
        Catch {
            Write-Host "$($_.Exception.Message)" -foregroundColor Red
            Exit
        }
    }
}
 
$File="GroupData.csv"
 
# Remove the CSV-file (starting fresh)
if (Test-Path $File) {
    Remove-Item $File -Force -ErrorAction Silentlycontinue
}
 
# Retrieve all groups/teams
Write-Host "`nRetrieving Groups/Teams . . . Please wait" -ForegroundColor Cyan
if (-not($teams)) { $teams=Get-Team | Select-Object DisplayName, GroupId }
if (-not($groups)) { $groups=Get-UnifiedGroup | Select-Object DisplayName, Alias, Id, ExternalDirectoryObjectId, WhenCreated, WhenCreatedUTC, WhenChanged, WhenChangedUTC, ManagedBy, GroupMemberCount, GroupExternalMemberCount, GroupType, IsMembershipDynamic, ExpirationTime, HiddenGroupMembershipEnabled, HiddenFromAddressListsEnabled, HiddenFromExchangeClientsEnabled, AutoSubscribeNewMembers, AlwaysSubscribeMembersToCalendarEvents, AccessType }
 
# Retrieve current Group Life Time in days from the Life Cycle Policy
$LifeCycle = (Get-AzureADMSGroupLifeCyclePolicy).GroupLifeTimeInDays
$Today = (Get-Date)
 
$Report = @()
 
$count = 1; $PercentComplete = 0; 
 
Write-Host "Processing group details . . . Please wait" -ForegroundColor Cyan
 
foreach ($Group in $groups) {
    $TeamBugged=$null
    #Progress message 
    $ActivityMessage = "Retrieving data for Team: $($Group.DisplayName). Please wait..."
    $StatusMessage = ("Processing {0} of {1}: {2}" -f $count, @($groups).count, $($Group.DisplayName))
    $PercentComplete = ($count / @($groups).count * 100) 
    Write-Progress -Activity $ActivityMessage -Status $StatusMessage -PercentComplete $PercentComplete
 
    # if the ExternalDirectoryObjectId matches a GroupID collected from Get-Team, this means the group is not bugged (not hidden from Teams Powershell or Teams &amp; Skype Admin Center)
    if ($Group.ExternalDirectoryObjectId -in $teams.GroupID) {
        $TeamBugged=$False
    }
    if ($Group.ExternalDirectoryObjectId -notin $teams.GroupID) {
        $TeamBugged=$True
    }
 
    # try to return Team Owners from the Teams powershell-module
    try {
        $teamOwners=Get-TeamUser -GroupId $Group.ExternalDirectoryObjectId -Role Owner
    }
    catch {
        # This catches teams that the Teams powershell-module has no permission to retrieve data from, this usually means that the Team belongs to SchoolDataSync
        if ($_.Exception.ErrorCode -eq "403") {
            $teamOwners=@{"user"="$null"}
            $teamOwners.User="No permission to retrieve data (SchoolDataSync?)"
        }
        else { 
            $ErrorMessage=$_.Exception.Message
            write-host "$ErrorMessage" -foregroundcolor red
        }
    }
    $ChatCheck = $Null
    $ChatCheck=(Get-MailboxFolderStatistics -Identity $Group.Id -FolderScope ConversationHistory -IncludeOldestAndNewestItems)
    # Check that we have a Teams compliance folder and some items are present
    if ($ChatCheck.FolderType[1] -eq "TeamChat" -and $ChatCheck.ItemsInFolder[1] -gt 0) {
        $Chats=$ChatCheck.ItemsInFolder[1]
        $DateLastItemAdded=($ChatCheck.NewestItemReceivedDate[1]).ToString("yyyy-MM-dd HH:mm:ss")
    }
    else {
        $Chats="N/A"
        $DateLastItemAdded="N/A"
    }   
 
    # Managers are shown with their Alias, we're retrieving their UPN instead.
    $ManagersUPN=@()
    foreach ($manager in $Group.ManagedBy) {
        $upn=($manager | Get-User).UserPrincipalName
        $ManagersUPN+=$upn
    }
 
    # reset variables before each iteration
    $Status = $Null
    $LastRenewed = $Null
    $NextRenewalDue = $Null
    $DaysLeft = $Null
 
    # calculate expiration times and last renewal date
    $Status = (Get-AzureADMSLifecyclePolicyGroup -Id $Group.ExternalDirectoryObjectId).ManagedGroupTypes
    If ($Status -ne $Null) {
        $LastRenewed = (Get-AzureADMSGroup -Id $Group.ExternalDirectoryObjectId).RenewedDateTime
        $NextRenewalDue = $LastRenewed.AddDays($Lifecycle)
        $DaysLeft = (New-TimeSpan -Start $Today -End $NextRenewalDue).Days
    }
 
    # HashTable
    $HT = [Ordered]@{
        "ExternalDirectoryObjectId"             =   "$($Group.ExternalDirectoryObjectId)"
        "Alias"                                 =   "$($Group.Alias)"
        "Group"                                 =   "$($Group.DisplayName)"
        "TeamOwners"                            =   "$(($teamOwners.User | ForEach-Object ToString) -join ', ')"
        "WhenCreatedUTC"                        =   "$(($Group.WhenCreatedUTC).ToString("yyyy-MM-dd HH:mm:ss"))"
        "WhenChangedUTC"                        =   "$(($Group.WhenChangedUTC).ToString("yyyy-MM-dd HH:mm:ss"))"
        "ManagedBy"                             =   "$(($ManagersUPN | ForEach-Object ToString) -join ', ')"
        "GroupMemberCount"                      =   "$($Group.GroupMemberCount)"
        "GroupExternalMemberCount"              =   "$($Group.GroupExternalMemberCount)"
        "GroupType"                             =   "$($Group.GroupType)"
        "IsMembershipDynamic"                   =   "$($Group.IsMembershipDynamic)"
        "ExpirationTime"                        =   "$(if ($Group.ExpirationTime) { ($Group.ExpirationTime).ToString("yyyy-MM-dd HH:mm:ss")} else { "N/A" })"
        "LastRenewed"                           =   "$($LastRenewed.ToString("yyyy-MM-dd HH:mm:ss"))"
        "NextRenewalDue"                        =   "$($NextRenewalDue.ToString("yyyy-MM-dd HH:mm:ss"))"
        "DaysLeft"                              =   "$DaysLeft"
        "Chats"                                 =   "$Chats"
        "DateLastItemAdded"                     =   "$DateLastItemAdded"
        "HiddenFromExchangeClientsEnabled"      =   "$($Group.HiddenFromExchangeClientsEnabled)"
        "HiddenFromAddressListsEnabled"         =   "$($Group.HiddenFromAddressListsEnabled)"
        "HiddenGroupMembershipEnabled"          =   "$($Group.HiddenGroupMembershipEnabled)"
        "AutoSubscribeNewMembers"               =   "$($Group.AutoSubscribeNewMembers)"
        "AlwaysSubscribeMembersToCalendarEvents"=   "$($Group.AlwaysSubscribeMembersToCalendarEvents)"
        "AccessType"                            =   "$($Group.AccessType)"
        "TeamBugged"                            =   "$TeamBugged"
    }
     
    $ReportLine = [PSCustomObject]$HT
    $Report += $ReportLine
 
    # Print some output (not all) while processing
    if ($Count -eq "1") {
        Write-host ("{0,-40}{1,-55}{2,-13}{3,-35}{4,-10}{5,-10}{6,-15}{7,-20}{8}" -f "ExternalDirectoryObjectId", "Group", "TeamBugged", "HiddenFromExchangeClientsEnabled", "Chats", "DaysLeft", "ManagersCount", "GroupMemberCount", "GroupExternalMemberCount" )
    }
    Write-host ("{0,-40}{1,-55}{2,-13}{3,-35}{4,-10}{5,-10}{6,-15}{7,-20}{8}" -f $($HT.ExternalDirectoryObjectId), $($HT.Group), $($HT.TeamBugged), $($HT.HiddenFromExchangeClientsEnabled), $($HT.Chats), $($HT.DaysLeft), $($ManagersUPN.Count), $($HT.GroupMemberCount), $($HT.GroupExternalMemberCount)  )
 
    $count++ 
}
# Export all collected group data to CSV
$Report | Export-Csv $File -Delimiter ";" -Encoding UTF8 -NoTypeInformation
Write-Host "`nScript took $($Timer.Elapsed.Hours)h $($Timer.Elapsed.Minutes)m $($Timer.Elapsed.Seconds)s $($Timer.Elapsed.MilliSeconds)ms to run." -foregroundColor Yellow
