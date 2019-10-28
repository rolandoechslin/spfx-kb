param (
	$Credential,
	$OutputPath = ".",
	[string]$Match,
	$List,
	$Folder,
	[array]$Sites,
	[Parameter(Mandatory=$true)]$Tenant
)
$WarningPreference = 'SilentlyContinue'

# Source: https://gallery.technet.microsoft.com/All-SharePoint-Online-Files-adae7db1

function LoadSharePointLibraries
{
	Write-Progress -Activity "Locating SharePoint Server Client Components installation..." -Id 1
	If (Test-Path 'c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll')
	{
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
			Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
			Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
			Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
			Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"
		}
		Else
		{
			Write-Host -NoNewLine -ForegroundColor Red "Please download the SharePoint Server Client Components from "
			Write-Host -NoNewLine -ForegroundColor Red "https://download.microsoft.com/download/F/A/3/FA3B7088-624A-49A6-826E-5EF2CE9095DA/sharepointclientcomponents_16-4351-1000_x64_en-us.msi "
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
	If (!(Get-Module -ListAvailable SharePointPnPPowerShellOnline | ? { $_.Version -ge '3.4.1812.1' }))
	{
		Install-Module SharePointPnPPowerShellOnline -Force
	}
}

function ConnectToSPO
{
	If ($tenant -like "*.onmicrosoft.com") { $tenant = $tenant.split(".")[0] }
	$AdminURL = "https://$tenant-admin.sharepoint.com"
	Connect-SpoService -Credential $Credential -Url $AdminURL
	Import-Module SharePointPnPPowerShellOnline
}

If ($OutputPath) { $OutputPath = $OutputPath.TrimEnd("\") }

LoadSharePointLibraries
ConnectToSPO

If (!($Sites)) { $Sites = Get-SPOSite | Select -Expand Url }
$s = 0
Foreach ($Site in $Sites)
{
	Write-Progress -Activity "Connecting to site $($Site)" -Percent (($s/$Sites.Count) * 100) -Id 1
	$cmd = "Connect-PnpOnline -Url $($Site) -credentials `$Credential"
	Invoke-Expression $cmd
	
	Write-Progress -Activity "Gathering list of files in site $($Site)" -Percent (($s/$Sites.Count) * 100) -Id 1
	
	$FindParams = @{ }
	If ($Match)
	{
		#"Match is specified as $($Match)."
		$FindParams.Add("Match", $Match)
	}
	else
	{
		#"Match not specified";
		$FindParams.Add("Match", "*")
	}
	If ($List) { $FindParams.Add("List", $List) }
	If ($Folder) { $FindParams.Add("Folder",$Folder)}
	try { $global:files = Find-PnpFile @FindParams -ea stop}
	catch
	{
		$Message = $_.Exception.Message
		If ($Message -like "*object reference not set*")
		{
			Write-Output "Looks like the List $($List) or Folder $($Folder) isn't found in site $($Site)."
		}
		Else
		{
			Write-Output $Message
		}
		$s++
		continue # go to next folder
	}
	$f = 1
	$s++	
	Write-Progress -Activity "Downloading files from site $($Site)" -Percent (($s/$Sites.Count) * 100) -Id 1
	
	if ($files)
	{
		foreach ($file in $files)
		{
			#$fullpath = $file.ServerRelativeUrl.ToString()
			$fullpath = "/" + ($file[0].Path.Identity -split (":file:/"))[1]
			Write-Progress -Activity "Downloading" -status "File: $($fullpath)" -perc (($f/$files.Count) * 100) -parent 1 -Id 2
			try { $newdir = New-Item -Type Directory -Path "$($OutputPath)$($fullpath.ToString().Substring(0, (($fullpath.lastindexof("/") + 1))))".Replace("/", "\") -Force }
			catch { }
			Get-PnpFile -Url $file.ServerRelativeUrl -Path "$($OutputPath)$($fullpath.ToString().Substring(0, (($fullpath.lastindexof("/") + 1))))".Replace("/", "\") -FileName $fullpath.Substring((($fullpath.lastindexof("/") + 1))) -AsFile
			$f++
		}
		Write-Progress -Activity "Downloading" -id 2 -Completed
	}
}