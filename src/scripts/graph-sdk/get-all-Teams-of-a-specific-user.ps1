# Source: https://svrooij.io/2022/09/13/replace-teams-owner/

# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser 
# Install-Module Microsoft.Graph.Teams -Scope CurrentUser 
# Install-Module Microsoft.Graph.Groups -Scope CurrentUser

# Change accordingly
$tenantId = "21009bcd-06df-4cdf-b114-e6a326ef3368";
$userId = "613f5b2e-4360-4665-956b-ffeaa0f3014b";
# Switch to $true for CSV output
$csv = $false;
# Connect to Graph with correct scopes
Connect-MgGraph -TenantId $tenantId -Scopes "User.Read.All","GroupMember.ReadWrite.All"

$teams = Get-MgUserJoinedTeam -UserId $userId;
if ($csv) {
  Write-Host "Team;TeamId;IsOwner;"
}
foreach($team in $teams) {
  # Check if the user is an owner.
  # Can the check be made more efficient?
  $owners = Get-MgGroupOwner -GroupId $team.Id
  $isOwner = $true;
  foreach ($owner in $owners) {
    if ($userId -eq $owner.Id) {
      $isOwner = $true;
      break;
    }
  }
  if ($false -eq $csv) {
    Write-Host "Team: $($team.DisplayName) ($($team.Id)) owner: $($isOwner)"
  } else {
    Write-Host "`"$($team.DisplayName)`";`"$($team.Id)`";$($isOwner);";
  }
}