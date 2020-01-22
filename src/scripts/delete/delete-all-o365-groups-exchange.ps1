$sparksjoy = "All Company", "TEMPLATE Project", "We have cats in this team! Join!"

$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential (Get-Credential) -Authentication  Basic -AllowRedirection

Import-PSSession $session

$groups = Get-UnifiedGroup | where {-not ($sparksjoy -contains $_.DisplayName)}

if ($groups.Count -eq 0) { break }

$groups | Format-Table DisplayName, SharePointSiteUrl

Read-Host -Prompt "Press Enter to start deleting (CTRL + C to exit)"

$progress = 0
$total = $groups.Count

foreach ($group in $groups) 
{
    $progress++
    write-host $progress / $total":" $group.DisplayName

    Remove-UnifiedGroup -identity $group.Id -Confirm:$false
}

Remove-PSSession $session