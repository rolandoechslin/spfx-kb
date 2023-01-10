# Source: https://office365itpros.com/2023/01/09/azure-ad-user-country-settings

$Report = [System.Collections.Generic.List[Object]]::new()
[array]$Users = Get-MgUser -Filter "assignedLicenses/`$count ne 0 and userType eq 'Member'" -ConsistencyLevel eventual -CountVariable Records -All
ForEach ($User in $Users) {
  Write-Host ("Processing account {0}" -f $User.DisplayName)
  $RegionalSettings = $Null
  $RegionalSettings = Get-MailboxRegionalConfiguration -Identity $User.UserPrincipalName -ErrorAction SilentlyContinue
  $CountryOrRegion = (Get-User -Identity $User.UserPrincipalName -ErrorAction SilentlyContinue) | Select-Object -ExpandProperty CountryOrRegion
  If ($RegionalSettings) {
  $ReportLine = [PSCustomObject]@{ 
    User                   = $User.UserPrincipalName
    DisplayName            = $User.DisplayName
    Country                = $User.Country
    "Preferred Language"   = $User.PreferredLanguage
    "Usage Location"       = $User.UsageLocation
    "Country or region"    = $CountryOrRegion
    Language               = $RegionalSettings.Language.DisplayName
    DateFormat             = $RegionalSettings.DateFormat
    TimeFormat             = $RegionalSettings.TimeFormat
    TimeZone               = $RegionalSettings.TimeZone }
 $Report.Add($ReportLine) }
}