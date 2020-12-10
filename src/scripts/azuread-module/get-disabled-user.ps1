# Source: https://docs.microsoft.com/de-de/archive/blogs/chadcox/powershell-useful-azure-ad-queries-using-the-azuread-module

# Info
#  List all properties: (Get-AzureADUser)[0] | Select-Object -Property *

# Requirement:
# https://www.powershellgallery.com/packages/AzureAD/
# Install-Module -Name AzureAD

$_default_log = $env:userprofile + '\Documents\azuread_disabled_accounts.csv'
 get-azureaduser -all $true -filter 'accountEnabled eq false' | select DisplayName,`
     UserPrincipalName,Mail,Department,UserType,CreationType,RefreshTokensValidFromDateTime,AccountEnabled,`
     @{name='Licensed';expression={if($_.AssignedLicenses){$TRUE}else{$False}}},`
     @{name='Plan';expression={if($_.AssignedPlans){$TRUE}else{$False}}},ObjectId | export-csv $_default_log -NoTypeInformation