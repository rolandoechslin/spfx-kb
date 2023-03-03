# Source: https://office365itpros.com/2023/03/03/azure-ad-app-property-lock

$StartDate = (Get-Date).AddDays(-90)
$EndDate = Get-Date
[array]$Records = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate -Formatted -ResultSize 5000 -Operations "Update application – Certificates and secrets management "
$Report = [System.Collections.Generic.List[Object]]::new() 
ForEach ($Record in $Records) {
 $AuditData = $Record.AuditData | ConvertFrom-Json
  $Mods = $AuditData.modifiedproperties.NewValue
  $ReportLine  = [PSCustomObject] @{
     Timestamp        = $Record.CreationDate
     User             = $AuditData.UserId
     AppName          = $AuditData.Target[3].Id
     Modified         = $AuditData.modifiedproperties.NewValue }
 $Report.Add($ReportLine)
}