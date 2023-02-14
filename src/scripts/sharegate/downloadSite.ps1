# Source: https://sympmarc.com/2023/02/13/using-sharegate-powershell-to-download-sharepoint-content/

Import-Module -Name ShareGate # Requires ShareGate to be installed on the machine
Import-Module "./PowerShell/downloadSiteFunctions.psm1" -Force

# Setup
$sourceSiteName = "Name for the downloaded folder"
$sourceSiteUrl = "https://FarmOrTenantName/siteName/"

# The downloads will end up in a folder here named $sourceSiteName
$destTop = "Z:\" # Be sure to include a trailing backslash

# Any list or library in this array will be excluded from the downloads
$exclusionLists = @(
    "Content and Structure Reports",
    "Master Page Gallery",
    "Reusable Content",
    "Style Library",
    "Web Part Gallery",
    "Workflow Tasks",
    "Microfeed",
    "Site Pages",
    "Site Assets"
)

# Process root web
#   Delete existing folder - we assume we want to start from scratch
Remove-Item `
    -Path "$($destTop)$($sourceSiteName)" `
    -Recurse `
    -Force

#   Create new top-level folder
$top = New-Item `
    -Path "$($destTop)$($sourceSiteName)" `
    -ItemType Directory -Force

#   Export lists
Export-SympLists `
    -ParentFolder "$($top.FullName)" `
    -WebUrl $sourceSiteUrl `
    -Versions $false `
    -ExclusionLists $exclusionLists `
    -KeepEmpty $false `
    -KeepLists $true

# Process subwebs
Get-SympSubwebs `
    -ParentFolder "$($top.FullName)" `
    -WebUrl $sourceSiteUrl `
    -Versions $false `
    -ExclusionLists $exclusionLists `
    -KeepEmpty $false `
    -KeepLists $true