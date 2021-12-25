# Source: https://www.cloudappie.nl/remove-orphaned-redirectsites/

Connect-SPOService -Url https://tenant-admin.sharepoint.com

Get-SPOSite -Template REDIRECTSITE#0 | ForEach-Object {
  $redirectSite = Invoke-WebRequest -Uri $_.Url -MaximumRedirection 0
  $body = $null

  Write-Host -f Green "Checking old URL for redirect" $_.Url

  if($redirectSite.StatusCode -eq 308) {
    Try {
      Write-Host -f Green " Redirects to: " $redirectSite.Headers.Location

      $body = Invoke-WebRequest -Uri $redirectSite.Headers.Location -MaximumRedirection 0 -ErrorAction SilentlyContinue
    }
    Catch{
     if($_.Exception.Response.StatusCode -eq "NotFound") {
      Write-Host -f Red "  Target location no longer exists, should be removed"
      Remove-SPOSite -Identity $redirectSite.Headers.Location -confirm:$false
     }
    }
    Finally {
      If($body.StatusCode -eq "302"){
       Write-host -f Yellow "  Target location still exists"
      }
    }
  }
}