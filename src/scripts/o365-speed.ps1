<#
.SYNOPSIS
	SharePoint Online Speed Test - Measure how fast SPO will connect and provide current Web detail
.DESCRIPTION
	Run multiple repetitions of <<Connect/GetWeb/Disconnect>> to measure O365 connection response times.

	Comments and suggestions always welcome!  spjeff@spjeff.com or @spjeff
.NOTES
	File Name		: o365-speed-test.ps1
	Author			: Jeff Jones - @spjeff
	Version			: 0.10
	Last Modified	: 05-22-2017
.LINK
	Source Code
		http://www.github.com/spjeff/o365/o365-speed.ps1
	
	Download PowerShell Plugin

		* PNP - Patterns and Practices
		https://github.com/officedev/pnp-powershell
#>

# CONFIG - CHANGE THESE VALUES
$url = "https://spjeff.sharepoint.com"

# Prepare environment
Write-Host  "Office 365 - Speed Test"
$reps = 1..10

# Connect to target
$cred = Get-PnPStoredCredential -Name $url
if (!$cred) {
    Add-PnPStoredCredential -Name $url
    $cred = Get-PnPStoredCredential -Name $url
}

# Run test repetitions
$coll = @()
$reps |% {
    # Core command
    $sb = {
        Connect-PNPOnline -Url $url
        $web = Get-pnpweb -Includes AllProperties
        $web | ft
        Disconnect-PNPOnline
    }
    # Measure time
    $result = Measure-Command $sb
    # Collect times
    $coll += $result
}

# Display result table
$coll | ft -a