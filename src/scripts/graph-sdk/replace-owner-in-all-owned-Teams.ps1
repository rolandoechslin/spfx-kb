# Source: https://svrooij.io/2022/09/13/replace-teams-owner/

# Change accordingly
$tenantId = "21009bcd-06df-4cdf-b114-e6a326ef3368";
$userId = "613f5b2e-4360-4665-956b-ffeaa0f3014b";
$altUser = "3c3b19fe-ea86-440a-a0ea-8fbce680a849";
# Connect to Graph with correct scopes
Connect-MgGraph -TenantId $tenantId -Scopes "User.Read.All","GroupMember.ReadWrite.All"

$teams = Get-MgUserJoinedTeam -UserId $userId;
foreach ($team in $teams) {
  # Check if the user is an owner.
  $owners = Get-MgGroupOwner -GroupId $team.Id
  $isOwner = $false;
  $altUserIsOwner = $false;
  foreach ($owner in $owners) {
    if ($userId -eq $owner.Id) {
      $isOwner = $true;
    }
    if ($altUser -eq $owner.Id) {
      $altUserIsOwner = $true;
    }
  }

  if ($isOwner) {
    if ($false -eq $altUserIsOwner) {
      Write-Host "Team: $($team.DisplayName) adding owner ($($altUser))";

      # First add the alternative user as Owner and Member (needed for Teams...)
      New-MgGroupOwner -GroupId $team.Id -DirectoryObjectId $altUser -ErrorAction SilentlyContinue
      New-MgGroupMember -GroupId $team.Id -DirectoryObjectId $altUser -ErrorAction SilentlyContinue
    } else {
      Write-Host "Team: $($team.DisplayName) alt. user ($($altUser)) already an owner";
    }

    Write-Host "Team: $($team.DisplayName) removing owner ($($userId))";
    # Then remove the user from the Team
    Remove-MgGroupOwnerByRef -DirectoryObjectId $userId -GroupId $team.Id -ErrorAction SilentlyContinue
    Remove-MgGroupMemberByRef -DirectoryObjectId $userId -GroupId $team.Id -ErrorAction SilentlyContinue
  }
}