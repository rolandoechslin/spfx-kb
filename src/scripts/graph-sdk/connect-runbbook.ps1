# Source: https://practical365.com/managed-identity-powershell/

# Connect to Microsoft Graph with Azure Automation
Connect-AzAccount -Identity
$AccessToken = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com"
Connect-MgGraph -AccessToken $AccessToken.Token
# Get Tenant service domain using Get-MgOrganization
$TenantName = (Get-MgOrganization).VerifiedDomains | Where-Object {$_.IsInitial -eq $True} | Select-Object -ExpandProperty Name
# Connect to Exchange Online
Connect-ExchangeOnline -ManagedIdentity -Organization $TenantName 
Get-ExoMailbox -RecipientTypeDetails UserMailbox | Format-Table DisplayName, UserPrincipalName