$TenantName = "YourTenant"
$TenantAdminUrl = "https://$TenantName-admin.sharepoint.com"

Write-Host "Connecting ..." -ForegroundColor Cyan
Connect-SPOService $TenantAdminUrl