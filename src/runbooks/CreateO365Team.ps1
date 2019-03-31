param
(
    [Parameter(Mandatory=$true)]
    [string]$displayName,
    [Parameter(Mandatory=$true)]
    [string]$teamDescription,
    [Parameter(Mandatory=$true)]
    [string]$teamOwner
)
$VerbosePreference = "Continue" # "SilentlyContinue"
$creds = Get-AutomationPSCredential -Name 'MM_AzureGraph'
$global:AppID = $creds.UserName
$global:AppSecret = $creds.GetNetworkCredential().Password
[xml]$global:tenantConfig = Get-AutomationVariable -Name 'TenantCOnfig'

# Call Team creation (sub)runbook which creates Team directly (using a Microsoft Template)
$teamID = .\New_Office365_Team_CreateTeam.ps1 `
            -DisplayName $displayName `
            -teamdescription $teamDescription `
            -TeamOwner $teamOwner

$team = Get-PnPUnifiedGroup -Identity $teamID

...