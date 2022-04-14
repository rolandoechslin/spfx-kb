# -----------------------------------------------------------
# SharePoint Archiving
# -----------------------------------------------------------
# Source: https://lennox-it.uk/archiving-large-sharepoint-libraries-using-powershell
#
# Arguments:
#
# -Calling with zero arguments will run from root of doc libray
# -Use additional arguments to run from sub directories e.g. ./ArchiveDocumentLibrary.ps1 Directory1 ChildDirectory2 GrandChildDirectory3
# Note. that directories must be specified individually, in order, and with a blank space between each one
#
# Notes:
#
# - Moves files older than $ArchiveDate out of the source location into the Archive location
# - Deletes empty folders in the source location if $CleanupDirectories is set
# - Files are stored under a folder with $ListName in the target list. In this way, you can archive multiple source lists to the same archive location so long as they have different names.
# Note. Be wary of common list names like "Shared Documents". You will want to ensure these are backed up to different target lists or else you could get in a mess.
# - Liable to throttling by Microsoft so be patient, it will get there in the end!
#

#Required Module for script. Uncomment to install this module if you don't have it already
#Install-Module -Name PnP.PowerShell

#-------------Setings----------------------

#Root Site Url
$SiteUrl = "https://mytenantname.sharepoint.com"
$username = "serviceaccount@mytenant.co.uk"
$password = "xxx"

#Source Settings
$RelativeUrl = "/sites/SourceSite"
$ListName = "Shared Documents"

#Archive Settings
$ArchiveRelativeUrl = "/sites/ArchiveSite"
$ArchiveListName = "Archive Documents"

#Job Settings
$ArchiveDate = get-date "2015-01-01" #Anything older than this will be archived
$FileLimit = -1 # Limits number of files processed at a time (useful for testing). use -1 to turn this off
$CleanupDirectories = $true #Whether to remove empty directories or not
$Debug = $false #For debugging / dry runs. Enables additional output and doesn't actually change anything in the source library

#-------------------------------------------

function Recurse-Files($Folder, $Stack)
{
#Write-Output $Folder
$items = Get-PnPFolderItem -FolderSiteRelativeUrl $Folder
if ($Debug -eq $true)
{
Write-Output ("Folder: " + $Folder)
Write-Output ("Count: " + $items.count)
}

foreach($item in $items)
{
if ($Debug -eq $true)
{
Write-Output ("Item: " + $item.Name)
}

if ($item.Name -eq "Forms") { continue }
if ($item.Name -eq "_catalogs") { continue }

if ($item.TypedObject.ToString() -ne 'Microsoft.SharePoint.Client.Folder')
{
$file = Get-PnPFile -AsListItem -Url $item.ServerRelativeUrl
if ((get-date $file.FieldValues.Modified) -lt $ArchiveDate)
{
Archive-File $item $file $Folder $Stack
$FileLimit = $FileLimit - 1
if ($FileLimit -eq 0) { Exit }
}
}
else {
$NewPath = ($Folder + "/" + $item.Name)

$TempStack = $Stack.PSObject.Copy()
$TempStack.Push($item.Name)

Recurse-Files $NewPath $TempStack
}
}

if ($CleanupDirectories)
{
$items = Get-PnPFolderItem -FolderSiteRelativeUrl $Folder
if ($items.count -gt 0) {} else {
Cleanup-Empty-Folder $Stack
}
}
}

function Archive-File($Item, $FileItem, $ParentFolder, $Stack)
{
Write-Output ("Archiving: " + $Item.Name + " - " + $FileItem.FieldValues.Modified)

#Build Destination Path
$temps = $Stack.PSObject.Copy()
$TargetUrl = ""
while ($temps.count -gt 0) { $TargetUrl = ("/" + $temps.Pop() + $TargetUrl) }
$TargetUrl = ($ArchiveListName + $TargetUrl)

#Generate Destination Folder if it doesn't exist
if ($Debug -eq $false)
{
Resolve-PnPFolder -SiteRelativePath $TargetUrl -Connection $ArchiveConnection | Out-Null
}

#Move the File to Archive
if ($Debug -eq $false)
{
Move-PnPFile -SourceUrl ($RelativeUrl + "/" + $ParentFolder + "/" + $Item.Name) -TargetUrl ($ArchiveRelativeUrl + "/" + $TargetUrl) -Overwrite -AllowSchemaMismatch -IgnoreVersionHistory -Force
}
}

function Cleanup-Empty-Folder($Stack)
{
$temps = $Stack.PSObject.Copy()

$Name = $temps.Pop()

$TargetUrl = ""
while ($temps.count -gt 1) { $TargetUrl = ("/" + $temps.Pop() + $TargetUrl) }
$TargetUrl = ($ListName + $TargetUrl)

Write-Output ("Clean-up: " + $Name + " in " + $TargetUrl)
if ($Debug -eq $false)
{
Remove-PnPFolder -Name $Name -Folder $TargetUrl -Force
}
}

$encpassword = convertto-securestring -String $password -AsPlainText -Force
$credentials = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $encpassword

#Get Connection for connecting to the archive (need to do this before the other connection as it also connects interactive)
$ArchiveConnection = Connect-PnPOnline -Url ($SiteUrl + $ArchiveRelativeUrl) -ReturnConnection -Credentials $credentials

#Start (Main Method)
Connect-PnPOnline -Url ($SiteUrl + $RelativeUrl) -Credentials $credentials

#Prep stack
$StartStack = new-object system.collections.stack
$StartStack.Push($ListName)

#Load Path from args
$StartPath = $ListName
for ( $i = 0; $i -lt $args.count; $i++ ) {
$StartPath = ($StartPath + "/" + $args[$i])
$StartStack.Push($args[$i])
}

if ($Debug -eq $true) { Get-PnPList }

#Go!
Recurse-Files $StartPath $StartStack