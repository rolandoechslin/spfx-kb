# Source: https://www.cloudappie.nl/using-powershell-to-get-audit-data-for-external-users/

$cred = Get-Credential

$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $session
Connect-MsolService -Credential $cred

$extUsers = Get-MsolUser | Where-Object {$_.UserPrincipalName -like "*#EXT#*" }

$extUsers | ForEach {
    $auditEventsForUser = Search-UnifiedAuditLog -EndDate $((Get-Date)) -StartDate $((Get-Date).AddDays(-7)) -UserIds $_.UserPrincipalName

    Write-Host "Events for" $_.DisplayName "created at" $_.WhenCreated

    $auditEventsForUser | FT
}

Remove-PSSession $session