<#
.SYNOPSIS
Switch SharePoint Online site experience between modern and classic.

.PARAMETER Credential
Standard PSCredential object.

.PARAMETER Identity
Identity (user@domain.com) of user to check.

.PARAMETER PermissionToCheck
Full list of permissions to check per site.  Default is ViewPages.  Additional
parameters include "All" and "AllViewPermissions."

.PARAMETER Tenant
Tenant name as either 'tenant.onmicrosoft.com' or 'tenant.'

.EXAMPLE
.\SharePoint-SiteAccessReport.ps1 -Credential (Get-Credential) -Identity user@contoso.com -Tenant mycontoso.onmicrosoft.com
Generate an access report for user@contoso.com in the tenant mycontoso.onmicrosoft.com,
with the default ViewPages access.

.EXAMPLE 
.\SharePoint-SiteAccessReport.ps1 -Credential (Get-Credential) -Identity user@contoso.com -Tenant mycontoso -PermissionToCheck ManageAlerts
Generate an access report for user@contoso.com where the user has the ManageAlerts permissions granted.

.NOTES
2019-07-09	Initial release.
#>

param (
	# Credential object
	[Parameter(Mandatory = $true)]
	[System.Management.Automation.PSCredential]$Credential,
	
	# Target user to report on
	$Identity,
	[ValidateSet('EmptyMask','ViewListItems','AddListItems','EditListItems',
			  'DeleteListItems', 'ApproveItems', 'OpenItems', 'ViewVersions', 'DeleteVersions',
			  'CancelCheckout', 'ManagePersonalViews', 'ManageLists', 'ViewFormPages', 'AnonymousSearchAccessList',
			  'Open', 'ViewPages', 'AddAndCustomizePages', 'ApplyThemeAndBorder', 'ApplyStyleSheets', 'ViewUsageData',
			  'CreateSSCSite', 'ManageSubwebs', 'CreateGroups', 'ManagePermissions', 'BrowseDirectories', 'BrowseUserInfo',
			  'AddDelPrivateWebParts', 'UpdatePersonalWebParts', 'ManageWeb', 'AnonymousSearchAccessWebLists', 'UseClientIntegration',
			  'UseRemoteAPIs', 'ManageAlerts', 'CreateAlerts', 'EditMyUserInfo', 'EnumeratePermissions', 'FullMask','All','AllViewPermissions')]
			  [array]$PermissionToCheck = "ViewPages",
	$LogFile = (Get-Date -Format yyyy-MM-dd) + "_SiteAccessReport.txt",
	[Parameter(mandatory = $true)]
	[String]$Tenant
)

function Write-Log([string[]]$Message, [string]$LogFile = $Script:LogFile, [switch]$ConsoleOutput)
{
	$Message = $Message + $Input
	If ($Message -ne $null -and $Message.Length -gt 0)
	{
		if ($LogFile -ne $null -and $LogFile -ne [System.String]::Empty)
		{
			Out-File -Append -FilePath $LogFile -InputObject "$Message"
		}
		if ($ConsoleOutput -eq $true)
		{
			Write-Host "$Message"
		}
	}
}

function LoadSharePointLibraries
{
	If (Test-Path 'c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll')
	{
		Write-Host -ForegroundColor Green "Found SharePoint Server Client Components installation."
		Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
		Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
		Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
		Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
	}
	ElseIf ($filename = (Get-ChildItem 'C:\Program Files' -Recurse -ea silentlycontinue | where { $_.name -eq 'Microsoft.SharePoint.Client.DocumentManagement.dll' })[0])
	{
		$Directory = ($filename.DirectoryName)[0]
		Write-Host -ForegroundColor Green "Found SharePoint Server Client Components at $Directory."
		Add-Type -Path "$Directory\Microsoft.SharePoint.Client.dll"
		Add-Type -Path "$Directory\Microsoft.SharePoint.Client.Runtime.dll"
		Add-Type -Path "$Directory\Microsoft.SharePoint.Client.Taxonomy.dll"
		Add-Type -Path "$Directory\Microsoft.SharePoint.Client.UserProfiles.dll"
	}
	
	ElseIf (!(Test-Path 'C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll'))
	{
		Write-Host -ForegroundColor Yellow "This script requires the SharePoint Server Client Components. Attempting to download and install."
		wget 'https://download.microsoft.com/download/E/1/9/E1987F6C-4D0A-4918-AEFE-12105B59FF6A/sharepointclientcomponents_15-4711-1001_x64_en-us.msi' -OutFile ./SharePointClientComponents_15.msi
		wget 'https://download.microsoft.com/download/F/A/3/FA3B7088-624A-49A6-826E-5EF2CE9095DA/sharepointclientcomponents_16-4351-1000_x64_en-us.msi' -OutFile ./SharePointClientComponents_16.msi
		msiexec /i SharePointClientComponents_15.msi /qb
		msiexec /i SharePointClientComponents_16.msi /qb
		Sleep 60
		If (Test-Path 'c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll')
		{
			Write-Host -ForegroundColor Green "Found SharePoint Server Client Components."
			Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
			Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
			Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
			Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
		}
		Else
		{
			Write-Host -NoNewLine -ForegroundColor Red "Please download the SharePoint Server Client Components from "
			Write-Host -NoNewLine -ForegroundColor Yellow "https://download.microsoft.com/download/F/A/3/FA3B7088-624A-49A6-826E-5EF2CE9095DA/sharepointclientcomponents_16-4351-1000_x64_en-us.msi "
			Write-Host -ForegroundColor Red "and try again."
			Break
		}
	}
	
	If (!(Get-Module -ListAvailable "*online.sharepoint*"))
	{
		Write-Host -ForegroundColor Yellow "This script requires the SharePoint Online Management Shell.  Attempting to download and install."
		wget 'https://download.microsoft.com/download/0/2/E/02E7E5BA-2190-44A8-B407-BC73CA0D6B87/SharePointOnlineManagementShell_6802-1200_x64_en-us.msi' -OutFile ./SharePointOnlineManagementShell.msi
		msiexec /i SharePointOnlineManagementShell.msi /qb
		Write-Host -ForegroundColor Yellow "Please close and reopen the Windows Azure PowerShell module and re-run this script."
	}
	If (!(Get-InstalledModule -MinimumVersion 3.11.1907.0 SharePointPnPPowerShellOnline -ea SilentlyContinue))
	{
		Install-Module SharePointPnPPowerShellOnline -MinimumVersion 3.0 -Force
	}
}

LoadSharePointLibraries

# Validate Permissions
switch -regex ($PermissionToCheck)
{
	'^(?i)all$' {
		$PermissionToCheck = [array]$PermissionToCheck = @('EmptyMask', 'ViewListItems', 'AddListItems', 'EditListItems',
			'DeleteListItems', 'ApproveItems', 'OpenItems', 'ViewVersions', 'DeleteVersions',
			'CancelCheckout', 'ManagePersonalViews', 'ManageLists', 'ViewFormPages', 'AnonymousSearchAccessList',
			'Open', 'ViewPages', 'AddAndCustomizePages', 'ApplyThemeAndBorder', 'ApplyStyleSheets', 'ViewUsageData',
			'CreateSSCSite', 'ManageSubwebs', 'CreateGroups', 'ManagePermissions', 'BrowseDirectories', 'BrowseUserInfo',
			'AddDelPrivateWebParts', 'UpdatePersonalWebParts', 'ManageWeb', 'AnonymousSearchAccessWebLists', 'UseClientIntegration',
			'UseRemoteAPIs', 'ManageAlerts', 'CreateAlerts', 'EditMyUserInfo', 'EnumeratePermissions', 'FullMask'); break
	}
	'^(?i)allviewpermissions$' {
		$PermissionToCheck = [array]$PermissionToCheck = @('ViewListItems', 'ViewVersions', 'ViewPages', 'ViewUsageData',
			'BrowseDirectories', 'BrowseUserInfo', 'EnumeratePermissions'); break
	}
	'^(?i)viewpages$' { $PermissionToCheck = 'ViewPages'; break}
	default
	{
		if ($PermissionToCheck) { }
		Else { $PermissionToCheck = $PSBoundParameters.Values | ? { $PSBoundParameters.Keys -eq "PermissionToCheck" } }
	}
}

# Validate identity submitted is a valid email address/upn format
Try { $Test = New-Object Net.Mail.MailAddress($Identity) -ea stop }
Catch { "ERROR: Not a valid identity address (user@domain.com)"; break }

# Validate tenant name
If ($tenant -like "*.onmicrosoft.com") { $tenant = $tenant.split(".")[0] }
$AdminURL = "https://$tenant-admin.sharepoint.com"

# Verify if log file exists; if not, create
If (!(Test-Path $LogFile))
	{
	Write-Log -Message "Identity,Url,Permissions" -LogFile $LogFile
	}

# Connect-PnpOnline only doesn't prompt for creds if you pass it to Invoke-Expression
$cmd = "Connect-PnpOnline -Url $($AdminUrl) -credentials `$Credential"
Invoke-Expression $cmd

# Establish user identity in SPO format
$user = "i:0#.f|membership|$($Identity)"


[array]$Urls = Get-PnPTenantSite | Select -ExpandProperty Url
$i = 1
foreach ($Url in $Urls)
{
	Write-Progress -Activity "SharePoint Site Permissions Report" -Percent (($i/$Urls.Count)*100) -CurrentOperation "Checking site $($Url)"
	Connect-PnPOnline -Url $Url -credentials $Credential
	$web = Get-PnPWeb
	$UserEffectivePermission = $web.GetUserEffectivePermissions($user)
	try { Invoke-PnPQuery -ea stop }
	catch { Write-Log -LogFile ErrorLog.txt -Message "Error running Invoke-PnP against $($Url)."}
	
	$EffectivePermissions = @()
	foreach ($Perm in $PermissionToCheck)
	{
		try { $HasAccess = $UserEffectivePermission.Value.Has($Perm) }
		catch { Write-Log -LogFile ErrorLog.txt -Message "Error evaluating permission $($perm) against $($Url)."}
		If ($HasAccess -eq $true) { $EffectivePermissions += $perm }
	}
	
	if ($EffectivePermissions)
	{
		$PermissionArray = $EffectivePermissions -join ";"
		Write-Log -Message "$($Identity),$($Url),$($PermissionArray)" -LogFile $LogFile
	}
	$i++
}