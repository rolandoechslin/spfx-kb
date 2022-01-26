<# .SYNOPSIS
    Create doc lib.

.DESCRIPTION
    You need to have the latest version of PnP PowerShell
    Create doc list.

.PARAMETER SiteCollection
    Specifies the site collection Url of the SharePoint Online environment.

.PARAMETER ListName
    Specifies the name of the SharePoint Online list.

.NOTES
    Author:
    roland oechslin

    Current Version:
    0.1

    Version History:
    0.1 - First minor version

.EXAMPLE
    PS> .\create-doc-lib.ps1 -SiteCollection "https://contoso.sharepoint.com/sites/demo" -ListName "Objects"
   
#>

param ([Parameter(Mandatory)]$SiteCollection,[Parameter(Mandatory)]$ListName)

Connect-PnPOnline -Url $SiteCollection -Interactive

New-PnPList -Title $ListName -Template DocumentLibrary -EnableContentTypes
Add-PnPField -List $ListName -DisplayName "Registration End Date" -InternalName "RegistrationEndDate" -Type DateTime
Add-PnPField -List $ListName -DisplayName "Course Date" -InternalName "CourseDate" -Type DateTime
Add-PnPField -List $ListName -DisplayName "Register" -InternalName "Register" -Type Text
Add-PnPField -List $ListName -DisplayName "Number of Available Places" -InternalName "NumberofPlaces" -Type Number
Add-PnPFieldFromXml -List $ListName -FieldXml '<Field Type="UserMulti" DisplayName="People Who Registered" UserSelectionMode="PeopleOnly" StaticName="PeopleWhoRegistered" Name="PeopleWhoRegistered" Mult="TRUE" />'
Add-PnPView -List $ListName -Title "All Courses" -Fields "Title","RegistrationEndDate","CourseDate","Register","NumberofPlaces","PeopleWhoRegistered"

Disconnect-PnPOnline

# Sample: https://blog.velingeorgiev.com/provision-custom-list-sharepoint-pnp-powershell

# Site columns 
Add-PnPField -DisplayName 'Bookmark Url' -InternalName BookmarkUrl -Type URL -Id a1ae949b-9177-44e0-8353-40238f55efe9 -Group 'DMSGroup' -Required -ErrorAction Continue
Add-PnPField -DisplayName 'Bookmark Icon' -InternalName BookmarkIcon -Id fecc7c78-0be9-49c7-8364-29b71420aca8 -Group 'DMSGroup' -Type Choice -Choices Clock,Money -Required -ErrorAction Continue

# Site content type (base documents: 0x0101)
Add-PnPContentType -Name 'Objects-ContentType' -ContentTypeId 0x010158089e1a505540408d369233d1193fcc -Group 'DMSGroup' -ErrorAction Continue
$objectBase = Get-PnPContentType -Identity 'Objects-ContentType'

Add-PnPFieldToContentType -Field BookmarkUrl -ContentType $objectBase
Add-PnPFieldToContentType -Field BookmarkIcon -ContentType $objectBase

# Document list
New-PnPList -Title 'Objects' -Template DocumentLibrary -Url "Objects" -ErrorAction Continue
$objectDocLib = Get-PnPList -Identity "Objects"

Set-PnPList -Identity 'Objects' -EnableContentTypes $true -EnableVersioning $true -MajorVersions 100
Add-PnPContentTypeToList -List $objectDocLib -ContentType $objectBase -DefaultContentType
Add-PnPView -List $objectDocLib -Title "All Objects" -SetAsDefault -Fields Title,BookmarkUrl,BookmarkIcon