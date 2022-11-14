# https://pnp.github.io/script-samples/spo-get-usage-from-audit-logs/README.html?tabs=pnpps

Connect-PnPOnline -Url "HTTPS://tenant-ADMIN.sharepoint.COM" -Interactive
$intervalminutes = 15 
$now = Get-Date
$outputArray = @()
for ($i = 60; $i -le 11000 ; $i = $i + $intervalminutes) {
    # 1 hour ago to a day ago
    $starttime = $now.AddMinutes(-$i - $intervalminutes)
    $endtime = $now.AddMinutes(-$i)
    $results = Get-PnPUnifiedAuditLog -ContentType "SharePoint" -StartTime $starttime -EndTime $endtime
    $OperationalExcellenceHub = $results | Where { $_.SiteUrl -eq "https://tenant.sharepoint.com/sites/OperationalExcellenceHub/" }
    $OperationalExcellence = $results | Where { $_.SiteUrl -eq "https://tenant.sharepoint.com/sites/OperationalExcellence/" }
    $user= $results | Where { $_.UserId -eq "some.user@domain.com" }
    Write-Host  "$i FROM $starttime TO $endtime  OperationalExcellenceHub:$($OperationalExcellenceHub.Count) OperationalExcellence:$($OperationalExcellence.Count) RobS:$($Sarracini.Count) TOTAL:$($results.Count)"
    $outputObject = [PSCustomObject]@{
        Count                    = $i
        StartTime                = $starttime
        EndTime                  = $endtime
        OperationalExcellenceHub = $OperationalExcellenceHub.Count
        OperationalExcellence    = $OperationalExcellence.Count
        Sarracini                = $Sarracini.Count
        Total                    = $results.Count
    }
    $outputArray += $outputObject
    
}

$outputArray | Export-Csv "c:\Temp\IOCounts.csv" -NoTypeInformation

    # End