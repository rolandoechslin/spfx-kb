# Source: https://docs.microsoft.com/en-us/microsoft-365/admin/add-users/set-password-to-never-expire?view=o365-worldwide

# Pre condition
# Install-Module AzureAD

Connect-AzureAD

# To set the password never expire in office 365 for single user, run the below command:

Set-AzureADUser -ObjectId "<user ID>" -PasswordPolicies DisablePasswordExpiration

# Example: Set-AzureADUser -ObjectId user@tenantname.onmicrosoft.com -PasswordPolicies DisablePasswordExpiration


# To set the password never expire in office 365 for all users in your organization, run the below command:

# Get-AzureADUser -All $true | Set-AzureADUser -PasswordPolicies DisablePasswordExpiration

