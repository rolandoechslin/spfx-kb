# Get the authentication methods registered by all the users in the tenant
Get-MgBetaReportCredentialUserRegistrationDetail -All

# Get the authentication method details for a single user
Get-MgBetaReportCredentialUserRegistrationDetail -Filter "UserPrincipalName eq '<upn>'" -All

# Create a csv of all the users and their authentication methods 
Get-MgBetaReportCredentialUserRegistrationDetail -All | Select-Object Id, UserPrincipalName, UserDisplayName, IsCapable, IsEnabled, IsRegistered, IsMfaRegistered,@{n="AuthMethods";e={$_.AuthMethods -join ","}} | Export-Csv ./UserMfa.csv