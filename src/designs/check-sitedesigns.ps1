# Source: https://www.cloudappie.nl/list-failed-site-designs-tenantwide/


# Get Success
Get-SPOSite -Limit All | ForEach-Object {
    $failedRuns = Get-SPOSiteDesignRun $_.Url | Get-SPOSiteDesignRunStatus | Where-Object {$_.OutcomeCode -ne "Success"};
  
    if($failedRuns) {
      Write-Output $_.Url
      $failedRuns
    }
  }

  # Get Failure
  Get-SPOSite -Limit All | ForEach-Object {
    $failedRuns = Get-SPOSiteDesignRun $_.Url | Get-SPOSiteDesignRunStatus | Where-Object {$_.OutcomeCode -eq "Failure"};
  
    if($failedRuns) {
      Write-Output $_.Url
      $failedRuns
    }
  }