# Source: https://veenstra.me.uk/2016/04/20/office-365-sharepoint-online-collecting-all-user-profile-properties-using-pnp-powershell/

Clear-Host

$tenantadminurl = "admin-url"
$tenantname = "mytenant"
$username = "pieterveenstra@$tenantname.onmicrosoft.com"
 
$cred = Get-Credential -UserName $username -Message "Please supply password"
 
Connect-SPOService -Url "$tenantadminurl " -Credential $cred
$users = Get-SPOUser -Site $siteUrl
Connect-SPOnline $siteUrl -Credentials $cred
 
foreach ($user in $users)
{
   Write-Host -ForegroundColor Yellow $user.LoginName
   $profile = Get-SPOUserProfileProperty -Account $user.LoginName
   Write-Host $profile.UserProfileProperties
}