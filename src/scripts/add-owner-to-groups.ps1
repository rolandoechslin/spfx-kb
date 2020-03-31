# Source : https://www.koskila.net/how-to-fix-a-teams-team-with-no-owners

$cred = Get-Credential
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
 
Import-PSSession $session
 
$groups = Get-UnifiedGroup | Where-Object {([array](Get-UnifiedGroupLinks -Identity $_.Id -LinkType Owners)).Count -eq 0} | Select Id, Alias, DisplayName, ManagedBy, WhenCreated
ForEach ($g in $groups) { 
	Add-UnifiedGroupLinks $g.Alias -Links $cred.UserName -LinkType Member
	Add-UnifiedGroupLinks $g.Alias -Links $cred.UserName -LinkType Owner
}