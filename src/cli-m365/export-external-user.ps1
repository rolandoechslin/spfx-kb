# Source: https://www.cloudappie.nl/migration-report-external-users/

$fileExportPath = "<PUTYOURPATHHERE.csv>"

$m365Status = m365 status

if ($m365Status -eq "Logged Out") {
  # Connection to Microsoft 365
  m365 login
}

$results = @()
Write-host "Retrieving all sites and check external users..."
$allSPOSites = m365 spo site classic list -o json | ConvertFrom-Json
$siteCount = $allSPOSites.Count

Write-Host "Processing $siteCount sites..."
#Loop through each site
$siteCounter = 0

foreach ($site in $allSPOSites) {
  $siteCounter++
  Write-Host "Processing $($site.Url)... ($siteCounter/$siteCount)"

  Write-host "Retrieving all external users ..."

  $users = m365 spo user list --webUrl $site.Url --output json --query "value[?contains(LoginName,'#ext#')]" | ConvertFrom-Json

  foreach ($user in $users) {
    $externalUserObject = m365 spo externaluser list --siteUrl $site.url -o json --query "[?AcceptedAs == '$($user.Email)']" | ConvertFrom-Json

    $results += [pscustomobject][ordered]@{
      UserPrincipalName = $user.UserPrincipalName
      Email             = $user.Email
      InvitedAs         = $externalUserObject.InvitedAs
      WhenCreated       = $externalUserObject.WhenCreated
      InvitedBy         = $externalUserObject.InvitedBy
      Url               = $site.Url
    }
  }
}

Write-Host "Exporting file to $fileExportPath..."
$results | Export-Csv -Path $fileExportPath -NoTypeInformation
Write-Host "Completed."