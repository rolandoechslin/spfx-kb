# Source: http://sharepoint-tricks.com/apply-view-formatting-of-staff-with-powershell/
# Source: https://pnp.github.io/script-samples/spo-apply-column-format/README.html

$site     = "https://contoso.sharepoint.com" #Site where the list will be created.
$nameList = "Project Staff" # Name of the List
$JsonPath = "C:\Users\USER\Desktop\ViewFormatting.txt" #Path to the Json File

$JSONFile = Get-Content $JsonPath 

$JSONFile | ConvertFrom-Json |Out-Null
$fieldXml = '<Field Type="User" Name="Person" DisplayName="Person" ID="{4dbd3482-af24-4319-913d-31e94b33912d}" Group="" Required="FALSE" SourceID="{56606dc3-9123-4fcb-a8be-5b20378eee20}" StaticName="Person" ColName="int1" RowOrdinal="0" EnforceUniqueValues="FALSE" ShowField="NameWithPictureAndDetails" UserSelectionMode="PeopleAndGroups" UserSelectionScope="0" Version="1" />'

Connect-PnPOnline -Url $site -UseWebLogin 

New-PnPList -Title $nameList -Template GenericList
Add-PnPField -List $nameList -DisplayName "LinkedIn" -InternalName "LinkedIn" -Type URL
Add-PnPField -List $nameList -DisplayName "Job Title" -InternalName "JobTitle" -Type Text
Add-PnPField -List $nameList -DisplayName "Phone Number" -InternalName "PhoneNumber" -Type Text
Add-PnPFieldFromXml -List $nameList -FieldXml $fieldXml

Set-PnPView -List $nameList -Identity "All Items" -Fields "Title","LinkedIn","JobTitle","PhoneNumber","Person"

$view = Get-PnPView -List $nameList -Identity "All Items" -Includes "CustomFormatter"
$view.CustomFormatter = $JSONFile
$view.Update()
Invoke-PnPQuery -RetryWait 10