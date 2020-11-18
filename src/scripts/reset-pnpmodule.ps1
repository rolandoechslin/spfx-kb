# Source: https://www.helloitsliam.com/2020/11/17/note-to-self-pnp-powershell/

# $url = "https://[tenant].sharepoint.com"
# Connect-PnPOnline -Url $url -SPOManagementShell -ClearTokenCache

# Remove the SharePoint Online PnP Module (close any current PowerShell Windows)
Remove-Module -Name SharePointPnPPowerShellOnline

# Install a specific PnP Version
Install-Module -Name SharePointPnPPowerShellOnline -MinimumVersion 3.26.2010.0

# Register the correct PnP PowerShell Peermissions
$url = "https://[tenant].sharepoint.com"
Register-PnPManagementShellAccess -SiteUrl $url
