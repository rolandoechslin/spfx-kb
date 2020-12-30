# Source: https://docs.microsoft.com/en-us/graph/powershell/app-only?tabs=azure-portal


# Connect-Graph -ClientId "YOUR_CLIENT_ID" `
#               -TenantId "YOUR_TENANT_ID" `
#               -CertificateThumbprint "YOUR_CERTIFICATE_Thumbprint"


# Switch to beta profile to use these samples.
# Select-MgProfile -Name beta

# $groups = Get-MgGroup
# $teams = $groups | Where-Object { $_.ResourceProvisioningOptions -Contains "Team" }
# $teams

Get-MgGroup -Property "id,displayName" -PageSize 50 | Format-Table DisplayName, Id

